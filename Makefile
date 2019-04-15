# Yup, I have them riiight there.
GODOTCPP_PATH ?= ../../../../godot-cpp
GODOT_PATH ?= ../../../../godot

all: foreigner.so

foreigner.so: src/*.cpp src/*.h
	gcc -shared src/*.cpp -o foreigner.so -fPIC -lstdc++ -lgodot-cpp.linux.debug.64 -ggdb \
		-I$(GODOT_PATH)/modules/gdnative/include \
		-I$(GODOTCPP_PATH)/include \
		-I$(GODOTCPP_PATH)/include/core \
		-I$(GODOTCPP_PATH)/include/gen \
		-L$(GODOTCPP_PATH)/bin
	#nm -D foreigner.so
