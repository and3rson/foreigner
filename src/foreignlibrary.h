#ifndef FOREIGNLIBRARY_H
#define FOREIGNLIBRARY_H

#include <Godot.hpp>
#include <Reference.hpp>
#include <String.hpp>

namespace godot {

class ForeignLibrary : public Reference {
    GODOT_CLASS(ForeignLibrary, Reference)

private:
    void *handle = 0;

public:
    static void _register_methods();

    static inline const char *___get_class_name() {
        return (const char *) "ForeignLibrary";
    }

    ForeignLibrary();
    ~ForeignLibrary();

    void _init();

    void setHandle(void *handle);
    int invoke(String method);
    String invoke_str(String method);
    bool invoke_bool(String method);

    void _process(float delta);
};

}

#endif
