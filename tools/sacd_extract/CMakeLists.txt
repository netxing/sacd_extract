# CMake build file for SACD Extract

cmake_minimum_required(VERSION 2.6...4.0)

# Mingw-w64 support
OPTION(MINGW64 "Mingw-w64" NO)
if (MINGW64 MATCHES "YES")
    MESSAGE(STATUS "Mingw-w64 mode enabled")
    SET(CMAKE_SYSTEM_NAME Windows)
    SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
    SET(TOOLCHAIN_PREFIX x86_64-w64-mingw32)
    SET(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
    SET(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})
endif (MINGW64 MATCHES "YES")

project(sacd_extract C)

# Load some macros.
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules;${CMAKE_MODULE_PATH}")

# Macros we'll need
include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckTypeSize)
include(FindThreads)

# Include directory paths
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${sacd_extract_SOURCE_DIR})

include_directories("../../libs/libcommon")
include_directories("../../libs/libdstdec")
include_directories("../../libs/libid3")
include_directories("../../libs/libsacd")

# Speed-optimized, size-aware, compatible with baseline x86-64 (SSE2+)
if (CMAKE_COMPILER_IS_GNUCC OR (CMAKE_C_COMPILER_ID MATCHES "Clang"))
  set(CMAKE_C_FLAGS_RELEASE "-O3 -march=x86-64 -flto -fomit-frame-pointer -fno-math-errno -ffunction-sections -fdata-sections")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -flto -O3 -s -Wl,--gc-sections")
  add_definitions(
      -pipe
      -Wall -Wextra -Wcast-align -Wpointer-arith
      -Wno-unused-parameter)
endif (CMAKE_COMPILER_IS_GNUCC OR (CMAKE_C_COMPILER_ID MATCHES "Clang"))

if(WIN32)
    set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES} -lpthread -lws2_32 -liconv -static")
elseif(APPLE)
  set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_CXX_STANDARD_LIRARIES} -liconv -lpthread")
else()
  add_definitions(-D_FILE_OFFSET_BITS=64)
  set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_CXX_STANDARD_LIRARIES} -lpthread")
endif()

file(GLOB libcommon_headers ../../libs/libcommon/*.h)
file(GLOB libcommon_sources ../../libs/libcommon/*.c)
source_group(libcommon FILES ${libcommon_headers} ${libcommon_sources})

file(GLOB libdstdec_headers ../../libs/libdstdec/*.h)
file(GLOB libdstdec_sources ../../libs/libdstdec/*.c)
source_group(libdstdec FILES ${libdstdec_headers} ${libdstdec_sources})

file(GLOB libid3_headers ../../libs/libid3/*.h)
file(GLOB libid3_sources ../../libs/libid3/*.c)
source_group(libid3 FILES ${libid3_headers} ${libid3_sources})

file(GLOB libsacd_headers ../../libs/libsacd/*.h)
file(GLOB libsacd_sources ../../libs/libsacd/*.c)
source_group(libsacd FILES ${libsacd_headers} ${libsacd_sources})

file(GLOB main_headers ./*.h)
file(GLOB main_sources ./*.c)
source_group(main FILES ${main_headers} ${main_sources})

add_executable(sacd_extract 
    ${main_headers} ${main_sources}
    ${libcommon_headers} ${libcommon_sources}
    ${libdstdec_headers} ${libdstdec_sources}
    ${libid3_headers} ${libid3_sources}
    ${libsacd_headers} ${libsacd_sources}
    )
