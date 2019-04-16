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
    } else if (name == "sint16") {
        return &ffi_type_sint16;
    } else if (name == "uint32") {
        return &ffi_type_uint32;
    } else if (name == "sint32") {
        return &ffi_type_sint32;
    } else if (name == "uint64") {
        return &ffi_type_uint64;
    } else if (name == "sint64") {
        return &ffi_type_sint64;
    } else if (name == "float") {
        return &ffi_type_float;
    } else if (name == "double") {
        return &ffi_type_double;
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
    register_method("define", &ForeignLibrary::define);
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

void ForeignLibrary::define(String method, String retType, PoolStringArray argTypes) {
    // TODO: Memory leaks
    ffi_cif *cif = new ffi_cif();
    ffi_type **arg_types = new ffi_type*[argTypes.size()];
    ffi_status status;

    String argString = "";

    for (int i = 0; i < argTypes.size(); i++) {
        arg_types[i] = this->get_ffi_type(argTypes[i]);
        argString += (argString.length() ? ", " : "") + argTypes[i];
    }
    ffi_prep_cif(cif, FFI_DEFAULT_ABI, argTypes.size(), this->get_ffi_type(retType), arg_types);
    this->cif_map[method.hash()] = cif;

    Godot::print("Defined function " + method + "(" + argString + ") -> " + retType);
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
    uint64_t *arg_values_data[cif->nargs];
    // TODO: Suport more arg types
    for (int i = 0; i < args.size(); i++) {
        switch(args[i].get_type()) {
            case Variant::Type::NIL:
                arg_values[i] = 0;
                break;
            case Variant::Type::INT:
                arg_values[i] = new uint64_t(args[i]);
                break;
            case Variant::Type::REAL:
                arg_values[i] = new double(args[i]);
                break;
            case Variant::Type::BOOL:
                arg_values[i] = new bool(&args[i]);
                break;
            default:
                // Variant::___get_type_name(args[i].get_type())
                Godot::print_error(
                        String("ForeignLibrary: argument of type ") + \
                            String::num(args[i].get_type()) + \
                            " not yet supported",
                        __FUNCTION__, __FILE__, __LINE__
                );
                arg_values[i] = 0;
        }
    }
    //uint64_t result;
    unsigned char result[8];

    ffi_call(cif, FFI_FN(sym), result, arg_values);

    // Release memory of allocated variables
    for (int i = 0; i < cif->nargs; i++) {
        // TODO: Fix this
        delete arg_values[i];
    }

    if (cif->rtype == &ffi_type_uchar) {
        return Variant(*(uint8_t*) result);
    } else if (cif->rtype == &ffi_type_schar) {
        return Variant(*(int8_t*) result);
    } else if (cif->rtype == &ffi_type_uint16) {
        return Variant(*(uint16_t*) result);
    } else if (cif->rtype == &ffi_type_sint16) {
        return Variant(*(int16_t*) result);
    } else if (cif->rtype == &ffi_type_uint32) {
        return Variant(*(uint32_t*) result);
    } else if (cif->rtype == &ffi_type_sint32) {
        return Variant(*(int32_t*) result);
    } else if (cif->rtype == &ffi_type_uint64) {
        return Variant(*(uint64_t*) result);
    } else if (cif->rtype == &ffi_type_sint64) {
        return Variant(*(int64_t*) result);
    } else if (cif->rtype == &ffi_type_float) {
        return Variant(*(float*) result);
    } else if (cif->rtype == &ffi_type_double) {
        return Variant(*(double*)result);
    } else if (cif->rtype == &ffi_type_void) {
        return Variant(*(uint64_t*) result);
    } else if (cif->rtype == &ffi_type_pointer) {
        return Variant(*(uint64_t*) result);
    } else {
        return 0;
    }
}

void ForeignLibrary::_process(float delta) {
}
