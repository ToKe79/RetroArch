# increase to 3.1 once all major distributions
# include a version of CMake >= 3.1
cmake_minimum_required(VERSION 2.8.12)
if (POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif()
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Adhere to GNU filesystem layout conventions
include(GNUInstallDirs)

option(BUILD_SHARED_LIBS "Build Shared Libraries" OFF)

set(LIB_TYPE STATIC)

if(BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
endif()

option(SKIP_GLSLANG_INSTALL "Skip installation" ${SKIP_GLSLANG_INSTALL})
if(NOT ${SKIP_GLSLANG_INSTALL})
  set(ENABLE_GLSLANG_INSTALL ON)
endif()

option(ENABLE_AMD_EXTENSIONS "Enables support of AMD-specific extensions" ON)
option(ENABLE_GLSLANG_BINARIES "Builds glslangValidator and spirv-remap" ON)

option(ENABLE_NV_EXTENSIONS "Enables support of Nvidia-specific extensions" ON)

option(ENABLE_OPT "Enables spirv-opt capability if present" ON)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND WIN32)
    set(CMAKE_INSTALL_PREFIX "install" CACHE STRING "..." FORCE)
endif()

project(glslang)
# make testing optional
include(CTest)

if(ENABLE_AMD_EXTENSIONS)
    add_definitions(-DAMD_EXTENSIONS)
endif(ENABLE_AMD_EXTENSIONS)

if(ENABLE_NV_EXTENSIONS)
    add_definitions(-DNV_EXTENSIONS)
endif(ENABLE_NV_EXTENSIONS)

if(WIN32)
    set(CMAKE_DEBUG_POSTFIX "d")
    if(MSVC)
        include(ChooseMSVCCRT.cmake)
    endif(MSVC)
    add_definitions(-DGLSLANG_OSINCLUDE_WIN32)
elseif(UNIX)
    add_definitions(-DGLSLANG_OSINCLUDE_UNIX)
else(WIN32)
    message("unknown platform")
endif(WIN32)

if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
    add_compile_options(-Wall -Wmaybe-uninitialized -Wuninitialized -Wunused -Wunused-local-typedefs
                        -Wunused-parameter -Wunused-value  -Wunused-variable -Wunused-but-set-parameter -Wunused-but-set-variable -fno-exceptions)
    add_compile_options(-Wno-reorder)  # disable this from -Wall, since it happens all over.
elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    add_compile_options(-Wall -Wuninitialized -Wunused -Wunused-local-typedefs
                        -Wunused-parameter -Wunused-value  -Wunused-variable)
    add_compile_options(-Wno-reorder)  # disable this from -Wall, since it happens all over.
endif()

# Request C++11
if(${CMAKE_VERSION} VERSION_LESS 3.1)
    # CMake versions before 3.1 do not understand CMAKE_CXX_STANDARD
    # remove this block once CMake >=3.1 has fixated in the ecosystem
    add_compile_options(-std=c++11)
else()
    set(CMAKE_CXX_STANDARD 11)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

function(glslang_set_link_args TARGET)
    # For MinGW compiles, statically link against the GCC and C++ runtimes.
    # This avoids the need to ship those runtimes as DLLs.
    if(WIN32 AND ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
        set_target_properties(${TARGET} PROPERTIES
                              LINK_FLAGS "-static -static-libgcc -static-libstdc++")
    endif()
endfunction(glslang_set_link_args)

if(NOT TARGET SPIRV-Tools-opt)
    set(ENABLE_OPT OFF)
endif()

if(ENABLE_OPT)
    message(STATUS "optimizer enabled")
    add_definitions(-DENABLE_OPT=1)
else()
    add_definitions(-DENABLE_OPT=0)
endif()

add_subdirectory(glslang)
add_subdirectory(OGLCompilersDLL)
add_subdirectory(SPIRV)
