template <class T> struct s { T t; };

template <typename T> void f() { T t; }

// COMPLIANT
template <> void f<int>() { int t; }

struct B {};