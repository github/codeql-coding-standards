class A {
  class B *impl;

  void test() { delete impl; } // NON_COMPLAINT
};

class D {};

class C {
  class D *impl1;

  void test() { delete impl1; } // COMPLAINT
};