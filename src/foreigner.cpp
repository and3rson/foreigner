#include <dlfcn.h>

#include "foreigner.h"

using namespace godot;

void Foreigner::_register_methods() {
    register_method("open", &Foreigner::open);
    register_method("_process", &Foreigner::_process);
}

Foreigner::Foreigner() {
}

Foreigner::~Foreigner() {
}

void Foreigner::_init() {
}

ForeignLibrary* Foreigner::open(String path) {
    //if (this->handle) {
    //    // Another shared library is already open, close it
    //    dlclose(this->handle);
    //    Godot::print("Foreigner: Unloading shared library " + loadedPath);
    //    this->handle = 0;
    //}

    // Attempt to open shared library
    Godot::print("Foreigner: Loading shared library " + path);
    // TODO: Windows/Linux/Mac
    void *handle = dlopen(path.alloc_c_string(), RTLD_LAZY);
    if (dlerror()) {
        // Opening failed
        Godot::print_error(
                String("Foreigner: Failed to load " + path),
                __FUNCTION__, __FILE__, __LINE__
        );
        return 0;
    }

    ForeignLibrary *library = ForeignLibrary::_new();
    library->setHandle(handle);
    return library;
}

void Foreigner::_process(float delta) {
}
