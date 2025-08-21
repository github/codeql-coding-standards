class C0 {
public:
  virtual ~C0() {}
};

class C1 : public C0 {
public:
  virtual ~C1() {}
};

class C2 : public virtual C1 {
public:
  C2() {}
  ~C2() {}
};

typedef C1 Base;
typedef C2 Derived;

void test_dynamic_cast_pointer_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  C2 *p2 = dynamic_cast<C2 *>(p1); // COMPLIANT
}

void test_dynamic_cast_reference_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  C2 &l2 = dynamic_cast<C2 &>(*p1); // COMPLIANT
}

void test_dynamic_cast_reference_compliant_typedefs() {
  Derived l1;
  Base *p1 = &l1;
  Derived &l2 = dynamic_cast<Derived &>(*p1); // COMPLIANT
}

void test_reinterpret_cast_pointer_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  C2 *p2 = reinterpret_cast<C2 *>(p1); // NON_COMPLIANT
}

void test_reinterpret_cast_reference_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  C2 &l2 = reinterpret_cast<C2 &>(*p1); // NON_COMPLIANT
}

void test_reinterpret_cast_typedefs_non_compliant() {
  Derived l1;
  Base *p1 = &l1;
  Derived &l2 = reinterpret_cast<Derived &>(*p1); // NON_COMPLIANT
}

void test_c_style_cast_pointer_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  // C2 *p2 = (C2 *)p1; // NON_COMPLIANT - prohibited by the compiler
}

void test_c_style_cast_reference_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  // C2 &l2 = (C2 &)*p1; // NON_COMPLIANT - prohibited by the compiler
}

void test_static_cast_pointer_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  // C2 *p2 = static_cast<C2 *>(p1); // NON_COMPLIANT - prohibited by the
  // compiler
}

void test_static_cast_reference_non_compliant() {
  C2 l1;
  C1 *p1 = &l1;
  // C2 &l2 = static_cast<C2 &>(*p1); // NON_COMPLIANT - prohibited by the
  // compiler
}

void test_skipped_base_class() {
  C2 l1;
  C0 *p1 = &l1;
  C2 *l2 = dynamic_cast<C2 *>(p1);     // COMPLIANT
  C2 *p2 = reinterpret_cast<C2 *>(p1); // NON_COMPLIANT
}