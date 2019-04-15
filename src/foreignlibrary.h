#ifndef FOREIGNLIBRARY_H
#define FOREIGNLIBRARY_H

#include <ffi.h>
#include <unordered_map>

#include <Godot.hpp>
#include <Reference.hpp>
#include <Array.hpp>
#include <Variant.hpp>
#include <String.hpp>

namespace godot {

class ForeignLibrary : public Reference {
    GODOT_CLASS(ForeignLibrary, Reference)

private:
    void *handle = 0;
    std::unordered_map<uint64_t, ffi_cif*> cif_map;
    ffi_type* get_ffi_type(String name);

public:
    static void _register_methods();

    static inline const char *___get_class_name() {
        return (const char *) "ForeignLibrary";
    }

    ForeignLibrary();
    ~ForeignLibrary();

    void _init();

    void setHandle(void *handle);
    void prepare(String method, String retType, Array argTypes);
    Variant invoke(String method, Array args);

    void _process(float delta);
};

}

#endif
