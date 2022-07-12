void test_null_checked(
    int *p1) { // COMPLIANT - null checked, therefore it can be null
  if (p1) {
    *p1;
  }
}

void test_null_checked_non_local(
    int *p1) { // COMPLIANT - indirectly null checked
  test_null_checked(p1);
}

void test_direct_deref(int *p1) { *p1; } // NON_COMPLIANT

class ClassA {
public:
  int f1;
  void m1();
};

void test_field_access_deref(ClassA *p1) { p1->f1; } // NON_COMPLIANT

void test_method_call_deref(ClassA *p1) { p1->m1(); } // NON_COMPLIANT

void test_non_local_deref(ClassA *p1) { // NON_COMPLIANT
  test_field_access_deref(p1);
}