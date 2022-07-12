struct S1 {
  void f1() {}
  int m1;
};

static void (S1::*gptr1)(); // Not explicitly initialized, defaults to nullptr.
static void (S1::*gptr2)() = nullptr;
static void (S1::*gptr3)() = &S1::f1;

static int S1::*gptr4; // Not explicitly initialized, defaults to nullptr.
static int S1::*gptr5 = nullptr;
static int S1::*gptr6 = &S1::m1;

void f1(S1 *p1) { (p1->*gptr1)(); } // NON_COMPLIANT
void f2(S1 *p1) { (p1->*gptr1)(); } // COMPLIANT
void f3(S1 *p1) { (p1->*gptr2)(); } // NON_COMPLIANT
void f4(S1 *p1) { (p1->*gptr3)(); } // COMPLIANT

void f5(S1 *p1) { p1->*gptr4; } // NON_COMPLIANT
void f6(S1 *p1) { p1->*gptr4; } // COMPLIANT
void f7(S1 *p1) { p1->*gptr5; } // NON_COMPLIANT
void f8(S1 *p1) { p1->*gptr6; } // COMPLIANT

void f9() {
  S1 *l1 = new S1;

  f1(l1);
  f3(l1);
  f4(l1);
  f5(l1);
  f7(l1);

  gptr1 = &S1::f1;
  gptr4 = &S1::m1;

  f2(l1);
  f6(l1);

  delete l1;
}
typedef void (S1::*pointer_to_member_function)();
typedef int S1::*pointer_to_member_data;

pointer_to_member_function f10();
pointer_to_member_data f11();
void f12() {
  static void (S1::*l1)() = &S1::f1;
  static void (S1::*l2)() = nullptr;
  static void (S1::*l3)(); // Not explicitly initialized, defaults to nullptr.

  static int S1::*l4 = &S1::m1;
  static int S1::*l5 = nullptr;
  static int S1::*l6; // Not explicitly initialized, defaults to nullptr.

  S1 *l7 = new S1;

  (l7->*l1)(); // COMPLIANT
  (l7->*l2)(); // NON_COMPLIANT
  (l7->*l3)(); // NON_COMPLIANT

  l7->*l4; // COMPLIANT
  l7->*l5; // NON_COMPLIANT
  l7->*l6; // NON_COMPLIANT
  l3 = l1;
  (l7->*l3)(); // COMPLIANT
  l6 = l4;
  l7->*l6; // COMPLIANT

  l2 = gptr1;
  (l7->*l2)(); // COMPLIANT; gptr1 is initialized in f9()

  l5 = gptr4;
  l7->*l5; // COMPLIANT; gptr4 is initialized in f9()

  l2 = gptr2;
  (l7->*l2)(); // NON_COMPLIANT; gptr2 is null initialized

  l5 = gptr5;
  l7->*l5; // NON_COMPLIANT; gptr5 is null initialized

  void (S1::*l8)() = f10();
  gptr2 = l8;
  l2 = gptr2;
  (l7->*l2)(); // NON_COMPLIANT; gptr2 is null assigned

  int S1::*l9 = f11();
  gptr5 = l9;
  l5 = gptr5;
  l7->*l5; // NON_COMPLIANT; gptr5 is null assigned

  delete l7;
}

pointer_to_member_function f10() { return nullptr; }
pointer_to_member_data f11() { return nullptr; }

int main() {
  f9();
  f12();
  return 0;
}
