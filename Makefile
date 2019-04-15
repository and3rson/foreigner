# Yup, I have them riiight there.
GODOTCPP_PATH ?= ../../../../godot-cpp
GODOT_PATH ?= ../../../../godot

FFI_INCLUDES = $(shell pkg-config --cflags libffi)
INCLUDES= \
		  -I$(GODOT_PATH)/modules/gdnative/include \
		  -I$(GODOTCPP_PATH)/include \
		  -I$(GODOTCPP_PATH)/include/core \
		  -I$(GODOTCPP_PATH)/include/gen \
		  -L$(GODOTCPP_PATH)/bin \
		  $(FFI_INCLUDES)

LIBS = -lgodot-cpp.linux.debug.64 -lstdc++ -lffi
FLAGS = -ggdb -fPIC

all: foreigner.so

foreigner.so: src/*.cpp src/*.h
	gcc -shared src/*.cpp -o foreigner.so $(LIBS) $(INCLUDES) $(FLAGS)
	#nm -D foreigner.so
