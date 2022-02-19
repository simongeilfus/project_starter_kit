#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"

#include "cinder/gl/gl.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class TemplateApp : public App {
public:
    TemplateApp();
    void setup() override;
    void update() override;
    void draw() override;
};

TemplateApp::TemplateApp()
{
#if defined( ASSETS_DIR )
	addAssetDirectory( ASSETS_DIR );
#endif
}

void TemplateApp::setup()
{
}

void TemplateApp::update() 
{
}

void TemplateApp::draw()
{
    // Clear the back buffer
    gl::clear( ColorA( 0.05f, 0.06f, 0.09f, 1.0f ) );
}

void prepareSettings( App::Settings* settings )
{
    settings->setWindowSize( 1280, 720 );
    settings->setWindowPos( 60, 60 );
}

CINDER_APP( TemplateApp, RendererGl, prepareSettings )