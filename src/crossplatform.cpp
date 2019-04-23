#include "crossplatform.h"

HANDLE open_library(char *path) {
#ifdef IS_UNIX
    return dlopen(path, RTLD_LAZY);  // TODO: Is RTLD_LAZY the best?
#else
    return LoadLibrary(path);
#endif
}

char* open_library_error() {
#ifdef IS_UNIX
    return dlerror();
#else
    return GetLastError();
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

