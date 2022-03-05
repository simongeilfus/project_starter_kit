#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"

#include "cinder/gl/gl.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class TEMPLATE : public App {
public:
    TEMPLATE();
    void setup() override;
    void update() override;
    void draw() override;
};

TEMPLATE::TEMPLATE()
{
#if defined( ASSETS_DIR )
	addAssetDirectory( ASSETS_DIR );
#endif
}

void TEMPLATE::setup()
{
}

void TEMPLATE::update() 
{
}

void TEMPLATE::draw()
{
    // Clear the back buffer
    gl::clear( ColorA( 0.05f, 0.06f, 0.09f, 1.0f ) );
}

void prepareSettings( App::Settings* settings )
{
    settings->setWindowSize( 1280, 720 );
    settings->setWindowPos( 60, 60 );
}

CINDER_APP( TEMPLATE, RendererGl, prepareSettings )