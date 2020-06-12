#
#
## HOWTO: Cross-compiling for Win64 on Linux (Ubuntu/Elementary)
#
# Requires:
#
#  * Install cross-compilation tool chain:
#
#      sudo apt install g++-mingw-w64-x86-64
#
#  * Build the `godot-cpp` bindings to produce `libgodot-cpp.windows.debug.64.a`:
#
#      scons platform=windows bits=64 generate_bindings=yes -j4
#
#    (Cross-compilation is already supported in the
#     `godot-cpp` scons configuration. I tested with
#     Godot 3.1 branch @e4ad265339f17042a86227bfb44f9d5d7dee5ba4.)
#
# * Cross compile `libffi` from `libffi-3.3.tar.gz`:
#
#      ./configure --host x86_64-w64-mingw32
#      make
#      sudo make install # (semi-optional)
#
#  (Once I figured out *how* to configure the cross-
#  compilation it was very straight-forward but it's
#  not well documented.)
#
# * Use this `Makefile` to cross-compile `Foreigner`
#   and produce `foreigner.dll`:
#
#      make CROSS_COMPILE_PLATFORM=win64
#
#   Additionally, if you have `wine64` & a
#   Godot win64 executable you can test with:
#
#      make test CROSS_COMPILE_PLATFORM=win64 GODOT_BINARY="wine ~/<path>/Godot_v3.2.1-stable_win64.exe"
#

# Yup, I have them riiight there.
GODOTCPP_PATH ?= ../godot-cpp
GODOT_PATH ?= ../godot
GODOT_BINARY ?= $(GODOT_PATH)/bin/godot.x11.tools.64
CROSS_COMPILE_PLATFORM ?=

#
# Note: Certain combinations/orders of `-lstdc++`,
#       `-static-libstdc++ -static-libgcc`, `-Wl,-static`
#       & `-static` options can cancel each other
#       out, leading to a dynamically linked `libstdc++`
#       instead of it being statically linked.
#
#       If `-lstdc++` comes *before* `-static-libstdc++ -static-libgcc`
#       *without* there also being `-static` the result will
#       be a dynamically linked `libstdc++` in spite of the
#       `-static-libstdc++` option.
#
#      This is all *excellently* explained in this post:
#
#         <https://stackoverflow.com/questions/44488972/static-libstdc-works-on-g-but-not-on-pure-gcc#44527954>
#
#      The dynamic/static link status can be verified via
#      the output of:
#
#         ldd foreinger.so
#

# Uncomment this for additional linker log output
# which can be helpful for diagnosing static vs dynamic
# linking issues.
#
#VERBOSE_LINK := -Wl,-v

UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	PLATFORM := osx
	CXX := clang++
	LIB_SUFFIX := dylib
	EXTRA_FLAGS := -Og
	EXTRA_LIBS :=
else ifeq ($(UNAME),Linux)
	ifeq ($(CROSS_COMPILE_PLATFORM),)
		PLATFORM := linux
		CXX := g++
		LIB_SUFFIX := so
		EXTRA_FLAGS :=
		EXTRA_LIBS := -static-libstdc++ -static-libgcc
	else ifeq ($(CROSS_COMPILE_PLATFORM),win64)
		PLATFORM := windows
		BITS := 64
		CXX := x86_64-w64-mingw32-g++
		LIB_SUFFIX := dll
		EXTRA_FLAGS := -std=c++11
		EXTRA_LIBS := -static-libstdc++ -static-libgcc
		PKG_CONFIG_ENV_VARS := PKG_CONFIG_LIBDIR=/usr/x86_64-w64-mingw32/lib/pkgconfig PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
	else
$(error Unrecognized cross compilation platform name.)
	endif
else
$(error Unrecognized platform name.)
endif

FOREIGNER_LIB := foreigner.$(LIB_SUFFIX)

FFI_INCLUDES = $(shell $(PKG_CONFIG_ENV_VARS) pkg-config --static --cflags --libs  libffi)

INCLUDES= \
		  -I$(GODOTCPP_PATH)/godot_headers \
		  -I$(GODOTCPP_PATH)/include \
		  -I$(GODOTCPP_PATH)/include/core \
		  -I$(GODOTCPP_PATH)/include/gen \
		  -L$(GODOTCPP_PATH)/bin \
		  $(FFI_INCLUDES)

LIBS = -lgodot-cpp.$(PLATFORM).debug.64 $(EXTRA_LIBS)
FLAGS = -ggdb -fPIC $(EXTRA_FLAGS) -Wl,-static -Wall

all: $(FOREIGNER_LIB)

$(FOREIGNER_LIB): src/*.cpp src/*.h
	$(CXX) $(VERBOSE_LINK) -shared src/*.cpp -o $(FOREIGNER_LIB) $(FLAGS) $(LIBS) $(INCLUDES)

testlib.$(LIB_SUFFIX): testlib/*.cpp
	$(CXX) $(VERBOSE_LINK) -shared testlib/*.cpp -o testlib.$(LIB_SUFFIX) $(EXTRA_FLAGS) $(EXTRA_LIBS)

test: $(FOREIGNER_LIB) testlib.$(LIB_SUFFIX)
	$(GODOT_BINARY) --no-window -s test/test.gd

clean:
	rm -f *.so

.PHONY: test clean

