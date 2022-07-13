class ClassA {};

class ClassB : ClassA {};

void test_shadowed_copy() {
  try {
  } catch (ClassA a) { // COMPLIANT - not shadowed
  } catch (ClassB b) { // NON_COMPLIANT - shadowed by a
  }
}

void test_shadowed_ref() {
  try {
  } catch (ClassA &a) { // COMPLIANT - not shadowed
  } catch (ClassB &b) { // NON_COMPLIANT - shadowed by a
  }
}

void test_not_shadowed_copy() {
  try {
  } catch (ClassB b) { // COMPLIANT - not shadowed by a
  } catch (ClassA a) { // COMPLIANT
  }
}

void test_not_shadowed_ref() {
  try {
  } catch (ClassB &b) { // COMPLIANT - not shadowed by a
  } catch (ClassA &a) { // COMPLIANT
  }
}