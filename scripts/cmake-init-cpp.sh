#!/usr/bin/env bash

#################################################################
#	 ||				||
# 	 ||	C++ CMake Init script	||
#        ||				||
################################################################	
#!/usr/bin/env bash

set -euo pipefail

targetDir="${1:-}"
if [[ -z "$targetDir" ]]; then
  read -rp "Enter project folder name or path ('-' allowed): " targetDir
fi

mkdir -p -- "$targetDir"
cd -- "$targetDir"

projectName="$(basename "$targetDir")"

mkdir -p bin/Debug bin/Release build/Debug build/Release config include lib src/Sources src/Headers

cat > src/Sources/__dummy.cpp <<'EOF'
// Intentionally empty.
// This file exists so CMake always has at least one source file for mySources.
EOF

cat > src/main.cpp <<'EOF'
#include <cstdio>
#include "Config.h"

int main(int argc, char* argv[]) {
    printf("Running: %s\nVersion: %i.%i\n", argv[argc-argc],
        VERSION_MAJOR, VERSION_MINOR);

    printf("Hello, CMake!\n");
    return 0;
}
EOF

defaultCmakeVersion="$(
  cmake --version | awk 'NR==1{ if (match($0, /[0-9]+(\.[0-9]+)*/)) { print substr($0, RSTART, RLENGTH); exit } }'
)"
defaultCmakeVersion="${defaultCmakeVersion:-3.8}"

read -rp "Minimum required CMake version (ENTER defaults to current ${defaultCmakeVersion}): " cmakeVersion
cmakeVersion="${cmakeVersion:-$defaultCmakeVersion}"

while [[ ! "$cmakeVersion" =~ ^[0-9]+(\.[0-9]+)*$ ]]; do
  read -rp "Invalid version. Enter a float-style number like 3.2: " cmakeVersion
  cmakeVersion="${cmakeVersion:-$defaultCmakeVersion}"
done

read -rp "Enter the C++ standard version(11, 14, 17, 20, 23, 26): " cstVersion
while [[ ! "$cstVersion" =~ ^(11|14|17|20|23|2[0-9])$ ]]; do
  read -rp "Invalid C++ standard. Try 11, 14, 17, 20, 23, 26: " cstVersion
done

cat > include/Config.h.in <<EOF
#pragma once
#define VERSION_MAJOR @${projectName}_VERSION_MAJOR@
#define VERSION_MINOR @${projectName}_VERSION_MINOR@
EOF

cat > CMakeLists.txt <<EOF
cmake_minimum_required(VERSION ${cmakeVersion})

project(${projectName} VERSION 1.0)

set(CMAKE_CXX_STANDARD ${cstVersion})
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SRC_SOURCES CONFIGURE_DEPENDS
  "\${CMAKE_CURRENT_SOURCE_DIR}/src/Sources/*.cpp"
)

if(NOT SRC_SOURCES)
  set(SRC_SOURCES "\${CMAKE_CURRENT_SOURCE_DIR}/src/Sources/__dummy.cpp")
endif()

add_library(mySources \${SRC_SOURCES})

target_include_directories(mySources
  PUBLIC "\${CMAKE_CURRENT_SOURCE_DIR}/src/Headers"
)

add_executable(${projectName}
  "\${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
)

target_link_libraries(${projectName} PRIVATE mySources)

set_target_properties(${projectName}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "\${PROJECT_SOURCE_DIR}/bin/\$<CONFIG>"
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

configure_file(include/Config.h.in
    "\${CMAKE_CURRENT_SOURCE_DIR}/include/Config.h"
)

target_include_directories(${projectName}
    PUBLIC  "\${CMAKE_CURRENT_SOURCE_DIR}/include"
    PRIVATE "\${CMAKE_CURRENT_SOURCE_DIR}/src/Headers"
)

set(gcc_cxx "\$<COMPILE_LANG_AND_ID:CXX,GNU>")
set(clang_cxx "\$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang>")
set(gcc_or_clang_cxx "\$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU>")
set(msvc_cxx "\$<COMPILE_LANG_AND_ID:CXX,MSVC>")

set(clang_gcc_common_flags "-pedantic-errors;-Wshadow")
set(gcc_only_flags "-Wall;-Weffc++;-Wextra;-Wconversion;-Wsign-conversion;-Werror")

set(debug_flags "-ggdb")
set(release_flags "-O2" "-DNDEBUG")

target_compile_options(${projectName} PRIVATE
  "\$<\${clang_cxx}:\${clang_gcc_common_flags}>"
  "\$<\${gcc_cxx}:\${clang_gcc_common_flags}>"
  "\$<\${gcc_cxx}:\${gcc_only_flags}>"
  "\$<\${msvc_cxx}:-W3>"
  "\$<\${gcc_or_clang_cxx}:\$<\$<CONFIG:Debug>:\${debug_flags}>>"
  "\$<\${gcc_or_clang_cxx}:\$<\$<CONFIG:Release>:\${release_flags}>>"
)
EOF

cd build/Debug && cmake -DCMAKE_BUILD_TYPE=Debug ../.. && cmake --build .
cd ../..

cd build/Release && cmake -DCMAKE_BUILD_TYPE=Release ../.. && cmake --build .
cd ../..

echo "
=================================================================
=================================================================

Project initiated successfully!
Run:

--------------------
cd ${targetDir}
vim .
--------------------
to start working"

