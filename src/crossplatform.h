#ifndef CROSSPLATFORM_H
#define CROSSPLATFORM_H

#if defined __linux__ || defined __APPLE__
#include <dlfcn.h>
typedef void* HANDLE;
#define IS_UNIX
#endif

#ifdef _WIN32
#include <windows.h>
#define IS_WINDOWS
#endif

#endif

typedef void* SYMBOL;

HANDLE open_library(char *path);
const char *open_library_error();
int close_library(HANDLE handle);
SYMBOL get_symbol(HANDLE handle, char *symbol);

