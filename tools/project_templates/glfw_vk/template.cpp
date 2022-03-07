#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

int main( int argc, char *argv[] )
{
    // Initialize glfw
	if( ! glfwInit() ) {
		return -1;
	}
	// Check if Vulkan is supported
	if( ! glfwVulkanSupported() ) {
		return -1;
	}
    // Create a non resizable window with no graphic context
	glfwWindowHint( GLFW_CLIENT_API, GLFW_NO_API );
	glfwWindowHint( GLFW_RESIZABLE, GLFW_FALSE );
	GLFWwindow* window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
    if( ! window ) {
        glfwTerminate();
        return -1;
    }

	// basic vulkan instance initialization
	VkApplicationInfo appInfo = { VK_STRUCTURE_TYPE_APPLICATION_INFO, nullptr, "GlfwVulkan", VK_MAKE_VERSION( 0, 0, 1 ), "No Engine" };
	VkInstanceCreateInfo instanceCreateInfo = { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, nullptr, {}, &appInfo, 0 };
	instanceCreateInfo.ppEnabledExtensionNames = glfwGetRequiredInstanceExtensions( &instanceCreateInfo.enabledExtensionCount );

	VkInstance instance;
	VkResult result = vkCreateInstance( &instanceCreateInfo, nullptr, &instance );
	if( result != VK_SUCCESS ) {
		return -1;
	}

	VkSurfaceKHR surface;
	VkResult err = glfwCreateWindowSurface( instance, window, NULL, &surface );

    // Loop until the user closes the window
    while ( !glfwWindowShouldClose( window ) ) {
        // Poll for and process events
        glfwPollEvents();
    }

	vkDestroyInstance( instance, nullptr );
	glfwDestroyWindow( window );
    glfwTerminate();
    return 0;
}