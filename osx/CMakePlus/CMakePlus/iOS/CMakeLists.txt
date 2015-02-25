# CMakeLists.txt
# required version
cmake_minimum_required (VERSION 3.0)

set(OGRE_SDK_URL "http://sourceforge.net/projects/ogre/files/ogre/1.9/1.9/OgreSDK_iOS_v1-9-0.dmg/download")
set(OGRE_SDK_FILENAME "${CMAKE_CURRENT_BINARY_DIR}/OgreSDK_iOS_v1-9-0.dmg")
set(OGRE_SDK_MOUNT_PATH "${CMAKE_CURRENT_BINARY_DIR}/OgreSDKDMG")
set(OGRE_SDK_DIR "${CMAKE_CURRENT_BINARY_DIR}/OgreSDK")

# download the Ogre3D SDK if it doesn't exist
if(NOT EXISTS "${OGRE_SDK_DIR}")
if(NOT EXISTS "${OGRE_SDK_FILENAME}")
file(DOWNLOAD "${OGRE_SDK_URL}" "${OGRE_SDK_FILENAME}" SHOW_PROGRESS)
endif()

execute_process(COMMAND hdiutil attach "${OGRE_SDK_FILENAME}"  -mountpoint "${OGRE_SDK_MOUNT_PATH}" -nobrowse)

file(COPY "${OGRE_SDK_MOUNT_PATH}/OgreSDK" DESTINATION "${OGRE_SDK_DIR}")

execute_process(COMMAND hdiutil detach "${OGRE_SDK_MOUNT_PATH}")

# remove the dmg
# file(REMOVE "${OGRE_SDK_FILENAME}")

endif()

# create an Ogre iOS project

cmake_minimum_required(VERSION 2.8)

cmake_policy(SET CMP0015 NEW)
cmake_policy(SET CMP0016 NEW)

project(testapp)
set(NAME testapp)

### Emulate toolchain
set(CMAKE_OSX_SYSROOT "iphoneos")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
### -- end

if(NOT XCODE_VERSION)
message(FATAL_ERROR "Xcode only")
endif()

#set(CMAKE_MODULE_PATH
#"${OGRE_SDK_DIR}/CMake"
#"${OGRE_SDK_DIR}/OgreSDK/CMake"
#)

#set(OGRE_HOME "${OGRE_SDK_DIR}/OgreSDK")
#set(OGRE_STATIC TRUE)
#set(OIS_INC_SEARCH_PATH "${OGRE_SDK_DIR}/OgreSDK/include/OIS")
#set(OIS_LIB_SEARCH_PATH "${OGRE_SDK_DIR}/OgreSDK/lib/Release")
#find_package(OIS REQUIRED)
#find_package(OGRE REQUIRED)
#find_package(Boost QUIET)
#
#set(FreeImage_INCLUDE_DIRS "${OGRE_SDK_DIR}/OgreSDK/include")
#set(FreeImage_LIBRARIES "${OGRE_SDK_DIR}/OgreSDK/lib/Release")
#set(FreeImage_FOUND TRUE)
#
#set(FREETYPE_INCLUDE_DIRS "${OGRE_SDK_DIR}/OgreSDK/include")
#set(FREETYPE_LIBRARIES "${OGRE_SDK_DIR}/OgreSDK/lib/Release")
#set(FREETYPE_FOUND TRUE)
#
#set(OGRE_LIBRARIES ${OGRE_LIBRARIES} ${Boost_LIBRARIES})

set(
SOURCES
sources/AppDelegate.h
sources/AppDelegate.mm
sources/main.mm
)

add_executable(
testapp
${SOURCES}
)

#${OGRE_LIBRARIES}
target_link_libraries(
testapp
"-framework Foundation"
"-framework CoreGraphics"
"-framework UIKit"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOIS.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOgreMainStatic.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOgreOverlayStatic.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libRenderSystem_GLES2Static.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOgreRTShaderSystemStatic.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/libboost_system.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/libboost_chrono.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/libboost_date_time.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/libboost_system.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/libboost_thread.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libFreeType.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libFreeImage.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libzzip.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOgrePagingStatic.a"
"${OGRE_SDK_DIR}/OgreSDK/lib/Release/libOgreTerrainStatic.a"
"-lz"
)

include_directories(
"OgreSDK/OgreSDK/include/OGRE"
"OgreSDK/OgreSDK/include/OGRE/iOS"
"OgreSDK/OgreSDK/include/OGRE/Overlay"
"OgreSDK/OgreSDK/include/OGRE/RenderSystems/GLES2"
"OgreSDK/OgreSDK/include/OGRE/RTShaderSystem"
"OgreSDK/OgreSDK/include"
"OgreSDK/OgreSDK/include/OIS"
"OgreSDK/OgreSDK/include/OGRE/Plugins/PCZSceneManager"
"OgreSDK/OgreSDK/include/OGRE/Plugins/OctreeSceneManager"
"OgreSDK/OgreSDK/include/OGRE/Plugins/OctreeZone"
"OgreSDK/OgreSDK/include/OGRE/Paging"
"OgreSDK/OgreSDK/include/OGRE/Terrain"
)

set_target_properties(
testapp
PROPERTIES
MACOSX_BUNDLE YES
XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
XCODE_ATTRIBUTE_INSTALL_PATH "${CMAKE_BINARY_DIR}/ProductRelease"
XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO"
XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER YES
XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET 8.1
)

SET(MACOSX_BUNDLE_GUI_IDENTIFIER "com.company.testapp")

# MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/plist.in"
# XCODE_ATTRIBUTE_GCC_PREFIX_HEADER ${CMAKE_CURRENT_LIST_DIR}/Prefix.pch
# RESOURCE "${IMAGES};${STORYBOARDS};${ICONS}"

set_target_properties(
testapp
PROPERTIES
XCODE_ATTRIBUTE_PRODUCT_NAME
"TestApp"
XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER
"com.company.testapp"
)

set_target_properties(
testapp
PROPERTIES
XCODE_ATTRIBUTE_PRODUCT_NAME[variant=Debug]
"TestApp-Dbg"
XCODE_ATTRIBUTE_BUNDLE_IDENTIFIER[variant=Debug]
"com.company.testapp.debug"
)

