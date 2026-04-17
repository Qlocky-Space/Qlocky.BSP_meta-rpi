#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <dbus/dbus.h>

#include <wayland-server-core.h>
#include <wayland-util.h>

#include <libweston/libweston.h>
#include <libweston/shell-utils.h>

#define QLOCKY_DISPLAY_POWER_BUS_NAME "ch.qlocky.DisplayPower"
#define QLOCKY_DISPLAY_POWER_OBJECT_PATH "/ch/qlocky/DisplayPower"
#define QLOCKY_DISPLAY_POWER_INTERFACE "ch.qlocky.DisplayPower1"

struct qlocky_dbus_watch {
    struct qlocky_display_power_service *service;
    DBusWatch *watch;
    struct wl_event_source *source;
};

struct qlocky_dim_overlay {
    struct wl_list link;
    struct weston_output *output;
    struct weston_curtain *curtain;
    struct wl_listener output_destroy_listener;
    int previous_disable_planes;
    bool disable_planes_forced;
    uint32_t current_level;
};

struct qlocky_display_power_service {
    struct weston_compositor *compositor;
    DBusConnection *bus;
    struct wl_listener compositor_destroy_listener;
    struct weston_layer dim_layer;
    struct wl_list dim_overlays;
};

static struct weston_output *
find_output_by_name(struct weston_compositor *compositor, const char *name)
{
    struct weston_output *output;

    wl_list_for_each(output, &compositor->output_list, link) {
        if (output->name && strcmp(output->name, name) == 0)
            return output;
    }

    return NULL;
}

static void
destroy_dim_overlay(struct qlocky_dim_overlay *overlay)
{
    if (!overlay)
        return;

    if (overlay->output_destroy_listener.link.next)
        wl_list_remove(&overlay->output_destroy_listener.link);

    if (overlay->curtain) {
        weston_layer_entry_remove(&overlay->curtain->view->layer_link);
        weston_shell_utils_curtain_destroy(overlay->curtain);
    }

    wl_list_remove(&overlay->link);
    free(overlay);
}

static void
on_output_destroy_for_overlay(struct wl_listener *listener, void *data)
{
    struct qlocky_dim_overlay *overlay;

    (void)data;

    overlay = wl_container_of(listener, overlay, output_destroy_listener);
    overlay->output = NULL;
    destroy_dim_overlay(overlay);
}

static struct qlocky_dim_overlay *
find_or_create_overlay(struct qlocky_display_power_service *service,
                       struct weston_output *output)
{
    struct qlocky_dim_overlay *overlay;
    struct weston_curtain_params params;

    /* Find existing overlay for this output */
    wl_list_for_each(overlay, &service->dim_overlays, link) {
        if (overlay->output == output)
            return overlay;
    }

    /* Create new overlay tracking entry */
    overlay = calloc(1, sizeof(*overlay));
    if (!overlay)
        return NULL;

    overlay->output = output;
    overlay->current_level = 0;
    overlay->previous_disable_planes = output->disable_planes;
    overlay->disable_planes_forced = false;
    overlay->output_destroy_listener.notify = on_output_destroy_for_overlay;
    wl_signal_add(&output->destroy_signal, &overlay->output_destroy_listener);

    params.get_label = NULL;
    params.surface_committed = NULL;
    params.surface_private = NULL;
    params.r = 0.0f;
    params.g = 0.0f;
    params.b = 0.0f;
    params.a = 1.0f;
    params.pos = output->pos;
    params.width = output->width;
    params.height = output->height;
    params.capture_input = false;

    overlay->curtain = weston_shell_utils_curtain_create(service->compositor, &params);
    if (!overlay->curtain) {
        wl_list_remove(&overlay->output_destroy_listener.link);
        free(overlay);
        return NULL;
    }

    /* A view must be mapped to be considered during rendering. */
    overlay->curtain->view->is_mapped = true;

    weston_layer_entry_insert(&service->dim_layer.view_list,
                              &overlay->curtain->view->layer_link);
    weston_view_set_output(overlay->curtain->view, output);
    weston_view_set_alpha(overlay->curtain->view, 0.0f);

    wl_list_insert(&service->dim_overlays, &overlay->link);

    weston_log("qlocky-display-power: created dim overlay for output %s\n",
               output->name);

    return overlay;
}

static int
set_output_dim_level(struct qlocky_display_power_service *service,
                     struct weston_output *output,
                     uint32_t level)
{
    struct qlocky_dim_overlay *overlay;
    float alpha;

    if (level > 100)
        level = 100;

    /* Software dimming through a fullscreen black curtain on this output. */
    overlay = find_or_create_overlay(service, output);
    if (!overlay)
        return -1;

    if (!overlay->curtain)
        return -1;

    if (level > 0 && !overlay->disable_planes_forced) {
        overlay->previous_disable_planes = output->disable_planes;
        output->disable_planes = 1;
        overlay->disable_planes_forced = true;
    }

    if (level == 0 && overlay->disable_planes_forced) {
        output->disable_planes = overlay->previous_disable_planes;
        overlay->disable_planes_forced = false;
    }

    weston_view_set_position(overlay->curtain->view, output->pos);
    weston_surface_set_size(overlay->curtain->view->surface,
                            output->width,
                            output->height);

    alpha = (float)level / 100.0f;
    weston_view_set_alpha(overlay->curtain->view, alpha);
    weston_surface_damage(overlay->curtain->view->surface);
    weston_view_schedule_repaint(overlay->curtain->view);
    weston_output_schedule_repaint(output);

    overlay->current_level = level;

    weston_log("qlocky-display-power: set dim level %u for output %s\n",
               level, output->name);

    return 0;
}

static int
dispatch_bus(struct qlocky_display_power_service *service)
{
    while (dbus_connection_dispatch(service->bus) == DBUS_DISPATCH_DATA_REMAINS)
        ;

    return 0;
}

static int
on_bus_fd_event(int fd, uint32_t mask, void *data)
{
    struct qlocky_dbus_watch *watch_data = data;
    unsigned int dbus_flags = 0;

    (void)fd;

    if (!dbus_watch_get_enabled(watch_data->watch))
        return 0;

    if (mask & WL_EVENT_READABLE)
        dbus_flags |= DBUS_WATCH_READABLE;

    if (mask & WL_EVENT_WRITABLE)
        dbus_flags |= DBUS_WATCH_WRITABLE;

    if (mask & WL_EVENT_HANGUP)
        dbus_flags |= DBUS_WATCH_HANGUP;

    if (mask & WL_EVENT_ERROR)
        dbus_flags |= DBUS_WATCH_ERROR;

    if (dbus_flags)
        dbus_watch_handle(watch_data->watch, dbus_flags);

    return dispatch_bus(watch_data->service);
}

static void
destroy_watch_data(void *data)
{
    struct qlocky_dbus_watch *watch_data = data;

    if (!watch_data)
        return;

    if (watch_data->source)
        wl_event_source_remove(watch_data->source);

    free(watch_data);
}

static uint32_t
to_wl_event_mask(unsigned int dbus_flags)
{
    uint32_t mask = 0;

    if (dbus_flags & DBUS_WATCH_READABLE)
        mask |= WL_EVENT_READABLE;

    if (dbus_flags & DBUS_WATCH_WRITABLE)
        mask |= WL_EVENT_WRITABLE;

    if (dbus_flags & DBUS_WATCH_HANGUP)
        mask |= WL_EVENT_HANGUP;

    if (dbus_flags & DBUS_WATCH_ERROR)
        mask |= WL_EVENT_ERROR;

    return mask;
}

static dbus_bool_t
add_dbus_watch(DBusWatch *watch, void *data)
{
    struct qlocky_display_power_service *service = data;
    struct qlocky_dbus_watch *watch_data;
    struct wl_event_loop *loop;
    uint32_t mask;
    int fd;

    if (!dbus_watch_get_enabled(watch))
        return TRUE;

    fd = dbus_watch_get_unix_fd(watch);
    if (fd < 0)
        return FALSE;

    mask = to_wl_event_mask(dbus_watch_get_flags(watch));
    if (!mask)
        return TRUE;

    watch_data = calloc(1, sizeof(*watch_data));
    if (!watch_data)
        return FALSE;

    watch_data->service = service;
    watch_data->watch = watch;

    loop = wl_display_get_event_loop(service->compositor->wl_display);
    watch_data->source = wl_event_loop_add_fd(loop, fd, mask, on_bus_fd_event, watch_data);
    if (!watch_data->source) {
        free(watch_data);
        return FALSE;
    }

    dbus_watch_set_data(watch, watch_data, destroy_watch_data);

    return TRUE;
}

static void
remove_dbus_watch(DBusWatch *watch, void *data)
{
    (void)data;

    dbus_watch_set_data(watch, NULL, NULL);
}

static void
toggle_dbus_watch(DBusWatch *watch, void *data)
{
    struct qlocky_display_power_service *service = data;
    struct qlocky_dbus_watch *watch_data = dbus_watch_get_data(watch);

    if (!watch_data) {
        if (dbus_watch_get_enabled(watch))
            add_dbus_watch(watch, service);
        return;
    }

    if (!dbus_watch_get_enabled(watch)) {
        remove_dbus_watch(watch, service);
        return;
    }

    wl_event_source_fd_update(watch_data->source,
                              to_wl_event_mask(dbus_watch_get_flags(watch)));
}

static int
drain_initial_bus_messages(struct qlocky_display_power_service *service)
{
    dbus_connection_read_write(service->bus, 0);

    return dispatch_bus(service);
}

static DBusHandlerResult
set_output_power(struct qlocky_display_power_service *service,
                 DBusConnection *connection,
                 DBusMessage *message,
                 bool on)
{
    struct weston_output *output;
    DBusMessage *reply;
    DBusError derror;
    const char *output_name;

    dbus_error_init(&derror);
    if (!dbus_message_get_args(message,
                               &derror,
                               DBUS_TYPE_STRING,
                               &output_name,
                               DBUS_TYPE_INVALID)) {
        reply = dbus_message_new_error(message,
                                       DBUS_ERROR_INVALID_ARGS,
                                       derror.message ? derror.message : "Invalid arguments");
        if (reply) {
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        }
        dbus_error_free(&derror);
        return DBUS_HANDLER_RESULT_HANDLED;
    }

    output = find_output_by_name(service->compositor, output_name);
    if (!output) {
        reply = dbus_message_new_error(message,
                                       DBUS_ERROR_INVALID_ARGS,
                                       "Unknown output name");
        if (reply) {
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        }
        return DBUS_HANDLER_RESULT_HANDLED;
    }

    if (on)
        weston_output_power_on(output);
    else
        weston_output_power_off(output);

    weston_log("qlocky-display-power: %s output %s\\n",
               on ? "powered on" : "powered off",
               output_name);

    reply = dbus_message_new_method_return(message);
    if (reply) {
        dbus_connection_send(connection, reply, NULL);
        dbus_message_unref(reply);
    }

    return DBUS_HANDLER_RESULT_HANDLED;
}

static DBusHandlerResult
handle_set_dim_level(struct qlocky_display_power_service *service,
                     DBusConnection *connection,
                     DBusMessage *message)
{
    struct weston_output *output;
    DBusMessage *reply;
    DBusError derror;
    const char *output_name;
    uint32_t level;

    dbus_error_init(&derror);
    if (!dbus_message_get_args(message,
                               &derror,
                               DBUS_TYPE_STRING,
                               &output_name,
                               DBUS_TYPE_UINT32,
                               &level,
                               DBUS_TYPE_INVALID)) {
        reply = dbus_message_new_error(message,
                                       DBUS_ERROR_INVALID_ARGS,
                                       derror.message ? derror.message : "Invalid arguments");
        if (reply) {
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        }
        dbus_error_free(&derror);
        return DBUS_HANDLER_RESULT_HANDLED;
    }

    output = find_output_by_name(service->compositor, output_name);
    if (!output) {
        reply = dbus_message_new_error(message,
                                       DBUS_ERROR_INVALID_ARGS,
                                       "Unknown output name");
        if (reply) {
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        }
        return DBUS_HANDLER_RESULT_HANDLED;
    }

    if (set_output_dim_level(service, output, level) < 0) {
        reply = dbus_message_new_error(message,
                                       DBUS_ERROR_FAILED,
                                       "Failed to set dim level");
        if (reply) {
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        }
        return DBUS_HANDLER_RESULT_HANDLED;
    }

    reply = dbus_message_new_method_return(message);
    if (reply) {
        dbus_connection_send(connection, reply, NULL);
        dbus_message_unref(reply);
    }

    return DBUS_HANDLER_RESULT_HANDLED;
}

static DBusHandlerResult
handle_display_power_call(DBusConnection *connection,
                          DBusMessage *message,
                          void *userdata)
{
    struct qlocky_display_power_service *service = userdata;

    if (!dbus_message_has_path(message, QLOCKY_DISPLAY_POWER_OBJECT_PATH))
        return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;

    if (dbus_message_is_method_call(message, QLOCKY_DISPLAY_POWER_INTERFACE, "TurnOn"))
        return set_output_power(service, connection, message, true);

    if (dbus_message_is_method_call(message, QLOCKY_DISPLAY_POWER_INTERFACE, "TurnOff"))
        return set_output_power(service, connection, message, false);

    if (dbus_message_is_method_call(message, QLOCKY_DISPLAY_POWER_INTERFACE, "SetDimLevel"))
        return handle_set_dim_level(service, connection, message);

    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

static void
handle_compositor_destroy(struct wl_listener *listener, void *data)
{
    struct qlocky_display_power_service *service;
    struct qlocky_dim_overlay *overlay, *tmp;

    (void)data;

    service = wl_container_of(listener, service, compositor_destroy_listener);

    /* Clean up all overlays */
    wl_list_for_each_safe(overlay, tmp, &service->dim_overlays, link) {
        destroy_dim_overlay(overlay);
    }

    weston_layer_fini(&service->dim_layer);

    if (service->bus) {
        dbus_connection_set_watch_functions(service->bus, NULL, NULL, NULL, NULL, NULL);
        dbus_connection_remove_filter(service->bus, handle_display_power_call, service);
        dbus_connection_unref(service->bus);
    }

    wl_list_remove(&service->compositor_destroy_listener.link);
    free(service);
}

WL_EXPORT int
wet_module_init(struct weston_compositor *compositor, int *argc, char *argv[])
{
    struct qlocky_display_power_service *service;
    struct wl_event_loop *loop;
    DBusError derror;
    int r;

    (void)argc;
    (void)argv;

    service = calloc(1, sizeof(*service));
    if (!service)
        return -1;

    service->compositor = compositor;
    weston_layer_init(&service->dim_layer, compositor);
    weston_layer_set_position(&service->dim_layer, WESTON_LAYER_POSITION_FADE);
    wl_list_init(&service->dim_overlays);

    service->compositor_destroy_listener.notify = handle_compositor_destroy;
    wl_signal_add(&compositor->destroy_signal, &service->compositor_destroy_listener);

    dbus_error_init(&derror);
    service->bus = dbus_bus_get(DBUS_BUS_SYSTEM, &derror);
    if (!service->bus) {
        weston_log("qlocky-display-power: dbus_bus_get failed: %s\\n",
                   derror.message ? derror.message : "unknown error");
        dbus_error_free(&derror);
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return -1;
    }

    if (!dbus_connection_add_filter(service->bus,
                                    handle_display_power_call,
                                    service,
                                    NULL)) {
        weston_log("qlocky-display-power: dbus_connection_add_filter failed\\n");
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return -1;
    }

    r = dbus_bus_request_name(service->bus,
                              QLOCKY_DISPLAY_POWER_BUS_NAME,
                              DBUS_NAME_FLAG_DO_NOT_QUEUE,
                              &derror);
    if (dbus_error_is_set(&derror)) {
        weston_log("qlocky-display-power: dbus_bus_request_name error: %s\\n",
                   derror.message ? derror.message : "unknown error");
        dbus_error_free(&derror);
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return -1;
    }

    if (r == DBUS_REQUEST_NAME_REPLY_ALREADY_OWNER) {
        weston_log("qlocky-display-power: dbus name already owned, keeping existing owner\\n");
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return 0;
    }

    if (r != DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER) {
        weston_log("qlocky-display-power: dbus_bus_request_name unexpected reply: %d\\n", r);
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return -1;
    }

    if (!dbus_connection_set_watch_functions(service->bus,
                                             add_dbus_watch,
                                             remove_dbus_watch,
                                             toggle_dbus_watch,
                                             service,
                                             NULL)) {
        weston_log("qlocky-display-power: dbus_connection_set_watch_functions failed\\n");
        handle_compositor_destroy(&service->compositor_destroy_listener, NULL);
        return -1;
    }

    if (drain_initial_bus_messages(service) < 0)
        weston_log("qlocky-display-power: initial dbus dispatch failed\\n");

    weston_log("qlocky-display-power: registered %s on system bus\\n",
               QLOCKY_DISPLAY_POWER_BUS_NAME);

    return 0;
}
