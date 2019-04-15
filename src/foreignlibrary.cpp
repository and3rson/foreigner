#include <dlfcn.h>

#include "foreignlibrary.h"

using namespace godot;

ffi_type* ForeignLibrary::get_ffi_type(String name) {
    if (name == "uchar") {
        return &ffi_type_uchar;
    } else if (name == "schar") {
        return &ffi_type_schar;
    } else if (name == "uint16") {
        return &ffi_type_uint16;
    } else if (name == "int16") {
        return &ffi_type_sint16;
    } else if (name == "uint32") {
        return &ffi_type_uint64;
    } else if (name == "int32") {
        return &ffi_type_sint64;
    } else if (name == "uint64") {
        return &ffi_type_uint64;
    } else if (name == "int64") {
        return &ffi_type_sint64;
    } else if (name == "float") {
        return &ffi_type_float;
    } else if (name == "void") {
        return &ffi_type_void;
    } else if (name == "pointer") {
        return &ffi_type_pointer;
    } else {
        Godot::print_error(
                "ForeignLibrary: unknown arg type - " + name,
                __FUNCTION__, __FILE__, __LINE__
        );
        return &ffi_type_void;
    }
}

void ForeignLibrary::_register_methods() {
    register_method("prepare", &ForeignLibrary::prepare);
    register_method("invoke", &ForeignLibrary::invoke);
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

void ForeignLibrary::prepare(String method, String retType, Array argTypes) {
    // TODO: Memory leaks
    ffi_cif *cif = new ffi_cif();
    ffi_type *arg_types[argTypes.size()];
    ffi_status status;

    for (int i = 0; i < argTypes.size(); i++) {
        arg_types[i] = this->get_ffi_type(argTypes[i]);
    }
    ffi_prep_cif(cif, FFI_DEFAULT_ABI, argTypes.size(), this->get_ffi_type(retType), arg_types);
    this->cif_map[method.hash()] = cif;
}

Variant ForeignLibrary::invoke(String method, Array args) {
    if (!this->handle) {
        Godot::print_error(
                "ForeignLibrary: no library loaded, cannot invoke method " + method,
                __FUNCTION__, __FILE__, __LINE__
        );
        return 0;
    }

    void *sym = dlsym(this->handle, method.alloc_c_string());

    if (!sym) {
        Godot::print_error(
                "ForeignLibrary: unresolved symbol - " + method,
                __FUNCTION__, __FILE__, __LINE__
        );
        return 0;
    }

    if (!this->cif_map.count(method.hash())) {
        Godot::print_error(
                "ForeignLibrary: method " + method + " not prepared yet, cannot call",
                __FUNCTION__, __FILE__, __LINE__
        );
        return 0;
    }

    ffi_cif *cif = this->cif_map[method.hash()];

    void *arg_values[cif->nargs];
    // TODO: Pass args
    ffi_arg result;

    ffi_call(cif, (void(*)())sym, &result, arg_values);

    if (cif->rtype == &ffi_type_uchar) {
        return Variant((uint8_t) result);
    } else if (cif->rtype == &ffi_type_schar) {
        return Variant((int8_t) result);
    } else if (cif->rtype == &ffi_type_uint16) {
        return Variant((uint16_t) result);
    } else if (cif->rtype == &ffi_type_sint16) {
        return Variant((int16_t) result);
    } else if (cif->rtype == &ffi_type_uint32) {
        return Variant((uint32_t) result);
    } else if (cif->rtype == &ffi_type_sint32) {
        return Variant((int32_t) result);
    } else if (cif->rtype == &ffi_type_uint64) {
        return Variant((uint64_t) result);
    } else if (cif->rtype == &ffi_type_sint64) {
        return Variant((int64_t) result);
    } else if (cif->rtype == &ffi_type_float) {
        return Variant((float) result);
    } else if (cif->rtype == &ffi_type_void) {
        return Variant((uint64_t) result);
    } else if (cif->rtype == &ffi_type_pointer) {
        return Variant((uint64_t) result);
    } else {
        return 0;
    }
}

void ForeignLibrary::_process(float delta) {
}
