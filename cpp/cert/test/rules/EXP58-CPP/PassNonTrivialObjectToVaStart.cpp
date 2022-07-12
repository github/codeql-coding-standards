#include <cstdarg>

class Foo {
public:
  Foo() { p = new int(0); }
  ~Foo() { delete p; }

private:
  int *p;
};

class Bar {
public:
  Bar(int i) : _i(i) { ; }

private:
  const int _i;
};

void test_Foo(Foo f, ...) {
  std::va_list args;
  va_start(args, f); // NON_COMPLIANT
  va_end(args);
}

void test_Bar(Bar b, ...) {
  std::va_list args;
  va_start(args, b); // COMPLIANT
  va_end(args);
}
