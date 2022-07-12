class BaseClass {};

class DerivedClass : public BaseClass {};

void test() {
  BaseClass *l1 = new DerivedClass[5];
  DerivedClass *l2 = new DerivedClass[5];

  delete[] l1; // NON_COMPLIANT - pointer to base class
  delete[] l2; // COMPLIANT - pointer to derived class
}