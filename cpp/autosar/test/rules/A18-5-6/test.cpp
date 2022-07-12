#include <new>

void *malloc1(int b) __attribute__((malloc));

void *malloc1(int b) { return nullptr; } // NON_COMPLIANT

void *malloc3(int b) __attribute__((no_caller_saved_registers, __malloc__));
void *malloc3(int b) { return nullptr; } // NON_COMPLIANT

void h1() {} // NON_COMPLIANT

void f1() { std::set_new_handler(h1); }