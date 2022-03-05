#define SOKOL_IMPL
#define SOKOL_GLCORE33

#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"

static sg_pass_action pass_action;

void init()
{
    // setup sokol-gfx, sokol-time
    sg_desc desc = {};
    desc.context = sapp_sgcontext();
    sg_setup( &desc );

    // initial clear color
    pass_action.colors[0].action = SG_ACTION_CLEAR;
    pass_action.colors[0].value = { 0.0f, 0.5f, 0.7f, 1.0f };
}

void frame()
{
    const int width = sapp_width();
    const int height = sapp_height();

    // the sokol_gfx draw pass
    sg_begin_default_pass( &pass_action, width, height );
    sg_end_pass();
    sg_commit();
}

void cleanup()
{
    sg_shutdown();
}

void input( const sapp_event* event )
{
}

sapp_desc sokol_main( int argc, char* argv[] )
{
    sapp_desc desc = {};
    desc.init_cb = init;
    desc.frame_cb = frame;
    desc.cleanup_cb = cleanup;
    desc.event_cb = input;
    desc.gl_force_gles2 = true;
    desc.window_title = "";
    desc.ios_keyboard_resizes_canvas = false;
    desc.icon.sokol_default = true;
    return desc;
}