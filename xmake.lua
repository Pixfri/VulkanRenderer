set_xmakever("2.9.3")

set_project("VulkanRenderer")

add_rules("mode.debug", "mode.release")
set_languages("cxx20")

includes("xmake/**.lua")

option("override_runtime", {description = "Override VS runtime to MD in release and MDd in debug.", default = true})
option("libx11", { description = "Enable LibX11 support (requires the libx11 package).", default = true })
option("libxcb", { description = "Enable LibXCB support (requires the libxcb package).", default = false })
option("wayland", { description = "Enable Wayland support (requires the wayland package).", default = false })

add_includedirs("Include")

add_rules("plugin.vsxmake.autoupdate")

if is_mode("release") then
  set_fpmodels("fast")
  set_optimize("fastest")
  set_symbols("debug", "hidden")
else
  add_defines("VKR_DEBUG")
end

set_encodings("utf-8")
set_exceptions("cxx")
set_languages("cxx20")
set_rundir("./bin/$(plat)_$(arch)_$(mode)")
set_targetdir("./bin/$(plat)_$(arch)_$(mode)")
set_warnings("allextra")

if is_plat("windows") then
  if has_config("override_runtime") then
    set_runtimes(is_mode("debug") and "MDd" or "MD")
  end
end

if is_plat("windows", "mingw") then
  add_syslinks("user32", "kernel32")
  add_defines("VK_USE_PLATFORM_WIN32_KHR")
elseif is_plat("linux") then
  add_syslinks("dl")
  if has_config("libx11") then
    add_defines("VK_USE_PLATFORM_XLIB_KHR")
    add_requires("libx11")
  end

  if has_config("libxcb") then
    add_defines("VK_USE_PLATFORM_XCB_KHR")
    add_requires("libxcb")
  end

  if has_config("wayland") then
    add_defines("VK_USE_PLATFORM_WAYLAND_KHR")
    add_requires("wayland")
  end
end

add_defines("VK_NO_PROTOTYPES")

add_cxflags("-Wno-missing-field-initializers -Werror=vla", {tools = {"clang", "gcc"}})

add_requires("vulkan-headers")

target("VulkanRenderer")
  set_kind("binary")
  
  add_files("Source/**.cpp")
  
  for _, ext in ipairs({".hpp", ".inl"}) do
    add_headerfiles("Include/**" .. ext)
  end
  
  add_rpathdirs("$ORIGIN")

  if is_plat("linux") then
    if has_config("libx11") then
      add_defines("VK_USE_PLATFORM_XLIB_KHR")
      add_requires("libx11")
    end

    if has_config("libxcb") then
      add_defines("VK_USE_PLATFORM_XCB_KHR")
      add_requires("libxcb")
    end

    if has_config("wayland") then
      add_defines("VK_USE_PLATFORM_WAYLAND_KHR")
      add_requires("wayland")
    end
  end

  add_packages("vulkan-headers")