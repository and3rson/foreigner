# Yup, I have them riiight there.
GODOTCPP_PATH ?= ../godot-cpp
GODOT_PATH ?= ../godot
GODOT_BINARY ?= $(GODOT_PATH)/bin/godot.x11.tools.64

UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	PLATFORM := osx
	CXX := clang++
	LIB_SUFFIX := dylib
else
	PLATFORM := linux
	CXX := g++
	LIB_SUFFIX := so
endif

FOREIGNER_LIB := foreigner.$(LIB_SUFFIX)

FFI_INCLUDES = $(shell pkg-config --cflags --libs libffi)
INCLUDES= \
		  -I$(GODOTCPP_PATH)/godot_headers \
		  -I$(GODOTCPP_PATH)/include \
		  -I$(GODOTCPP_PATH)/include/core \
		  -I$(GODOTCPP_PATH)/include/gen \
		  -L$(GODOTCPP_PATH)/bin \
		  $(FFI_INCLUDES)

LIBS = -lgodot-cpp.linux.debug.64 -lstdc++ -lffi -static-libstdc++ -static-libgcc
FLAGS = -ggdb -fPIC

all: foreigner.so

foreigner.so: src/*.cpp src/*.h
	$(CXX) -shared src/*.cpp -o foreigner.so $(LIBS) $(INCLUDES) $(FLAGS)

testlib.so: testlib/*.cpp
	$(CXX) -shared testlib/*.cpp -o testlib.so

test: foreigner.so testlib.so
	$(GODOT_BINARY) --no-window -s test/test.gd

clean:
	rm -f *.so

.PHONY: test clean

