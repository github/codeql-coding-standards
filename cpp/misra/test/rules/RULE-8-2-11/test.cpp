// Trivial class - no virtual functions, trivial special members
struct TrivialClass {
  int m1;
};

// Class with virtual member function
struct VirtualMemberClass {
  int m1;
  virtual void f1() {}
};

// Class with virtual destructor
struct VirtualDestructorClass {
  int m1;
  virtual ~VirtualDestructorClass() = default;
};

// Class with user-defined (non-trivial) copy constructor
struct NonTrivialCopyClass {
  int m1;
  NonTrivialCopyClass() = default;
  NonTrivialCopyClass(const NonTrivialCopyClass &other) {}
};

// Class with user-defined (non-trivial) move constructor
struct NonTrivialMoveClass {
  int m1;
  NonTrivialMoveClass() = default;
  NonTrivialMoveClass(NonTrivialMoveClass &&other) {}
};

// Class with user-defined (non-trivial) copy assignment operator
struct NonTrivialCopyAssignClass {
  int m1;
  NonTrivialCopyAssignClass &operator=(const NonTrivialCopyAssignClass &other) {
  }
};

// Class with user-defined (non-trivial) move assignment operator
struct NonTrivialMoveAssignClass {
  int m1;
  NonTrivialMoveAssignClass &operator=(NonTrivialMoveAssignClass &&other) {}
};

// Class with user-defined (non-trivial) destructor
struct NonTrivialDestructorClass {
  ~NonTrivialDestructorClass() {}
};

// Derived class inheriting virtual
struct DerivedFromVirtual : public VirtualMemberClass {
  void f1() override {}
};

// Class with multiple inappropriate properties
struct MultipleIssuesClass {
  virtual void f1() {}
  MultipleIssuesClass() = default;
  MultipleIssuesClass(const MultipleIssuesClass &) {}
  ~MultipleIssuesClass() {}
};

// Class with defaulted special members (trivial)
struct DefaultedClass {
  int m1;
  DefaultedClass() = default;
  DefaultedClass(const DefaultedClass &) = default;
  DefaultedClass(DefaultedClass &&) = default;
  DefaultedClass &operator=(const DefaultedClass &) = default;
  DefaultedClass &operator=(DefaultedClass &&) = default;
  ~DefaultedClass() = default;
};

// A typedef for an inappropriate type
using VirtualAlias = VirtualMemberClass;

// User-defined variadic function
void variadic_func(int p1, ...) {}

void f() {
  variadic_func(0, 42);              // COMPLIANT
  variadic_func(0, 3.14);            // COMPLIANT
  variadic_func(0, (void *)nullptr); // COMPLIANT

  variadic_func(0, TrivialClass());              // COMPLIANT
  variadic_func(0, DefaultedClass());            // COMPLIANT
  variadic_func(0, VirtualMemberClass());        // NON_COMPLIANT
  variadic_func(0, VirtualDestructorClass());    // NON_COMPLIANT
  variadic_func(0, NonTrivialCopyClass());       // NON_COMPLIANT
  variadic_func(0, NonTrivialMoveClass());       // NON_COMPLIANT
  variadic_func(0, NonTrivialCopyAssignClass()); // NON_COMPLIANT
  variadic_func(0, NonTrivialMoveAssignClass()); // NON_COMPLIANT
  variadic_func(0, NonTrivialDestructorClass()); // NON_COMPLIANT
  variadic_func(0, DerivedFromVirtual());        // NON_COMPLIANT
  variadic_func(0, MultipleIssuesClass());       // NON_COMPLIANT
  variadic_func(0, VirtualAlias());              // NON_COMPLIANT
  variadic_func(0, VirtualMemberClass());        // NON_COMPLIANT

  variadic_func(0, TrivialClass(), VirtualMemberClass()); // NON_COMPLIANT
}

void test_unevaluated_context() {
  sizeof(variadic_func(0, VirtualMemberClass())); // COMPLIANT
}

// Parameter pack is not ellipsis
template <typename... Args> void parameter_pack_func(Args... p1) {}

void test_parameter_pack() {
  VirtualMemberClass l1;
  NonTrivialCopyClass l2;
  parameter_pack_func(l1, l2); // COMPLIANT
}

void variadic_take_objects(VirtualMemberClass v, ...);
void test_named_parameter_of_variadic_function() {
  variadic_take_objects(VirtualMemberClass()); // COMPLIANT
  variadic_take_objects(VirtualMemberClass(),
                        VirtualMemberClass()); // NON_COMPLIANT
}
