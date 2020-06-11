#include "crossplatform.h"

#ifdef IS_WINDOWS
#include <string>
std::string error_number_as_string;
#endif

HANDLE open_library(char *path) {
#ifdef IS_UNIX
    return dlopen(path, RTLD_LAZY);  // TODO: Is RTLD_LAZY the best?
#else
    return LoadLibrary(path);
#endif
}

const char *open_library_error() {
#ifdef IS_UNIX
    return dlerror();
#else
    // TODO: Use standard approach to convert GetLastError() to message.
    error_number_as_string = std::to_string(GetLastError());
    return error_number_as_string.c_str();
 #endif
}

int close_library(HANDLE handle) {
#ifdef IS_UNIX
    return dlclose(handle);
#else
    return FreeLibrary((HMODULE) handle);
#endif
}

SYMBOL get_symbol(HANDLE handle, char *symbol) {
#ifdef IS_UNIX
    return dlsym(handle, symbol);
#else
    return (void *)GetProcAddress((HMODULE) handle, symbol);
#endif
}

