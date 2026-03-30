#include <typeinfo>

struct NonPolymorphic {
  void foo() {}
};

struct PolymorphicStruct {
  virtual void foo() {}
};

struct DerivedPolymorphic : public PolymorphicStruct {
  void foo() override {}
};

class PolymorphicClass {
public:
  virtual ~PolymorphicClass() = default;
  virtual void method() {}
};

void test_typeid_with_type_id() {
  const std::type_info &l1 = typeid(NonPolymorphic);    // COMPLIANT
  const std::type_info &l2 = typeid(PolymorphicStruct); // COMPLIANT
  const std::type_info &l3 = typeid(PolymorphicClass);  // COMPLIANT
}

void test_typeid_with_non_polymorphic_expression() {
  NonPolymorphic l1;
  NonPolymorphic *l2 = &l1;

  const std::type_info &l3 = typeid(l1);  // COMPLIANT
  const std::type_info &l4 = typeid(*l2); // COMPLIANT
}

void test_typeid_with_polymorphic_expression() {
  PolymorphicStruct l1;
  PolymorphicStruct *l2 = &l1;
  DerivedPolymorphic l3;
  PolymorphicClass l4;

  const std::type_info &l5 = typeid(l1);  // NON_COMPLIANT
  const std::type_info &l6 = typeid(*l2); // NON_COMPLIANT
  const std::type_info &l7 = typeid(l3);  // NON_COMPLIANT
  const std::type_info &l8 = typeid(l4);  // NON_COMPLIANT
}

void test_typeid_with_polymorphic_function_call() {
  PolymorphicStruct l1;

  const std::type_info &l2 = typeid(l1.foo()); // COMPLIANT
}

void test_typeid_with_reference_to_polymorphic() {
  PolymorphicStruct l1;
  PolymorphicStruct &l2 = l1;

  const std::type_info &l3 = typeid(l2); // NON_COMPLIANT
}

void test_typeid_with_polymorphic_temporary() {
  const std::type_info &l1 = typeid(PolymorphicStruct{}); // NON_COMPLIANT
}

void test_typeid_with_polymorphic_pointer() {
  NonPolymorphic *l1 = new NonPolymorphic();
  PolymorphicStruct *l2 = new PolymorphicStruct();
  DerivedPolymorphic *l3 = new DerivedPolymorphic();
  PolymorphicClass *l4 = new PolymorphicClass();

  // Pointer types are not polymorphic themselves
  const std::type_info &l5 = typeid(l1); // COMPLIANT
  const std::type_info &l6 = typeid(l2); // COMPLIANT
  const std::type_info &l7 = typeid(l3); // COMPLIANT
  const std::type_info &l8 = typeid(l4); // COMPLIANT
}