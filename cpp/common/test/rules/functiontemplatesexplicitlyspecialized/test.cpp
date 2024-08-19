template <typename T> void f(T t) {}

template <> void f(int i) {} // NON_COMPLIANT

template <typename T> void f(T *p) {} // COMPLIANT

void f(int g) {} // COMPLIANT