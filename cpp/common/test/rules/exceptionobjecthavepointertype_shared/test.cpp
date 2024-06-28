class ClassA {};

void test_throwing_pointer_type(int i) {
  ClassA a = ClassA();
  ClassA *a2 = new ClassA;
  if (i < 10) {
    throw ClassA(); // COMPLIANT
  } else if (i < 20) {
    throw &a; // NON_COMPLIANT
  } else if (i < 30) {
    throw a2; // NON_COMPLIANT
  }
}