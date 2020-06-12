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
FLAGS = -ggdb -fPIC $(EXTRA_FLAGS) -Wl,-static

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

