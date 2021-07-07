module vulkan_windows;

public import core.sys.windows.windows;

import erupted.platform_extensions;
mixin Platform_Extensions!USE_PLATFORM_WIN32_KHR;