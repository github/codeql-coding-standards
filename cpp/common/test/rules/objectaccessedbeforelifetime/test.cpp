class ClassA {
public:
  void test();
};

void test_uninit() {
  int x;
  int *y;
  *y; // NON_COMPLIANT - use before lifetime starts
  y = &x;
  *y; // COMPLIANT - use after lifetime has started
  ClassA *a;
  a->test(); // NON_COMPLIANT - use before lifetime starts
  a = new ClassA;
  a->test(); // COMPLIANT - lifetime has started
}