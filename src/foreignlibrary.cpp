#include <dlfcn.h>

#include "foreignlibrary.h"

using namespace godot;

void ForeignLibrary::_register_methods() {
    register_method("invoke", &ForeignLibrary::invoke);
    register_method("invoke_str", &ForeignLibrary::invoke_str);
    register_method("invoke_bool", &ForeignLibrary::invoke_bool);
    register_method("_process", &ForeignLibrary::_process);
}

ForeignLibrary::ForeignLibrary() {
}

ForeignLibrary::~ForeignLibrary() {
}

void ForeignLibrary::_init() {
}

void ForeignLibrary::setHandle(void *handle) {
    this->handle = handle;
}

int ForeignLibrary::invoke(String method) {
    if (!this->handle) {
        Godot::print_error(
                "ForeignLibrary: no library loaded, cannot invoke method " + method,
                __FUNCTION__, __FILE__, __LINE__
        );
        return -1;
    }
    int (*func)();
    *(void **) (&func) = dlsym(this->handle, method.alloc_c_string());
    return func();
}

String ForeignLibrary::invoke_str(String method) {
    char* (*func)();
    *(void **) (&func) = dlsym(this->handle, method.alloc_c_string());
    return func();
}

bool ForeignLibrary::invoke_bool(String method) {
    bool (*func)();
    *(void **) (&func) = dlsym(this->handle, method.alloc_c_string());
    return func();
}

void ForeignLibrary::_process(float delta) {
}
