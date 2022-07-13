#include <csignal>

static void h1(int sig) {}
extern "C" void h2(int sig) {}

static void f() noexcept(false) {}

extern "C" void h3(int sig) {
  try {
    f();
  } catch (...) {
  }
}

extern "C" void h4(int sig) { throw; }

extern "C" void h5(int sig) { throw "Err"; }

class A {
  virtual void a() {}
};

class A1 : public A {
  void a() {}
};

extern "C" void h6(int sig) {

  A1 a;

  A *aa = dynamic_cast<A *>(&a);
}

void m1() {
  std::signal(SIGTERM, h1); // NON_COMPLIANT
  std::signal(SIGTERM, h2); // COMPLIANT
  std::signal(SIGTERM, h3); // NON_COMPLIANT
  std::signal(SIGTERM, h4); // NON_COMPLIANT
  std::signal(SIGTERM, h5); // NON_COMPLIANT
  std::signal(SIGTERM, h6); // NON_COMPLIANT
}
