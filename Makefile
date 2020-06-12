# Yup, I have them riiight there.
GODOTCPP_PATH ?= ../godot-cpp
GODOT_PATH ?= ../godot
GODOT_BINARY ?= $(GODOT_PATH)/bin/godot.x11.tools.64
CROSS_COMPILE_PLATFORM ?=

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
		EXTRA_LIBS := -lstdc++ -static-libstdc++ -static-libgcc
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
FLAGS = -ggdb -fPIC $(EXTRA_FLAGS)

all: $(FOREIGNER_LIB)

$(FOREIGNER_LIB): src/*.cpp src/*.h
	$(CXX) -shared src/*.cpp -o $(FOREIGNER_LIB) $(LIBS) $(INCLUDES) $(FLAGS)

testlib.$(LIB_SUFFIX): testlib/*.cpp
	$(CXX) -shared testlib/*.cpp -o testlib.$(LIB_SUFFIX) $(EXTRA_FLAGS) $(EXTRA_LIBS)

test: $(FOREIGNER_LIB) testlib.$(LIB_SUFFIX)
	$(GODOT_BINARY) --no-window -s test/test.gd

clean:
	rm -f *.so

.PHONY: test clean

