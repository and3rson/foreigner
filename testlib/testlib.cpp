#include <cstdint>
#include <cstring>
#include <stdio.h>

extern "C" int32_t getNumber() {
    printf("Called getNumber()\n");
    return 42;
}

extern "C" int32_t sqr(int32_t n) {
    printf("Called sqr(%d)\n", n);
    return n * n;
}

extern "C" int32_t add2i(int32_t a, int32_t b) {
    printf("Called add2i(%d, %d)\n", a, b);
    return a + b;
}

extern "C" double add3d(double a, double b, double c) {
    printf("Called add3d(%f, %f, %f)\n", a, b, c);
    return a + b + c;
}

extern "C" bool isEqual(int32_t a, int32_t b) {
    printf("Called isEqual(%d, %d)\n", a, b);
    return a == b;
}

extern "C" const char* getMessage() {
    return "Hello world!";
}

extern "C" char* joinStrings(const char *a, const char *b) {
    printf("%s + %s\n", a, b);
    char *c = new char[strlen(a) + strlen(b) + 1];
    strncpy(c, a, strlen(a));
    strncpy(c + strlen(a), b, strlen(b));
    c[strlen(a) + strlen(b)] = 0;
    return c;
}

extern "C" int32_t* allocateInt(int32_t value) {
    return new int32_t(value);
}

extern "C" int32_t retrieveInt(int32_t *ptr) {
    return *ptr;
}

