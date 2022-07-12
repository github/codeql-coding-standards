class A {
public:
  int m1;
};

void init_by_ref(int &ref_param);
void init_by_pointer(int *pointer_param);

template <typename T> void use(T t){};

void test_basic_init() {
  int l1 = 0;
  use(l1); // COMPLIANT
  int l2{};
  use(l2); // COMPLIANT
  A l3{};
  use(l3); // COMPLIANT
  int l4;
  init_by_ref(l4);
  use(l4); // COMPLIANT
  int l5;
  init_by_pointer(&l5);
  use(l5); // COMPLIANT
  A l6;
  l6.m1 = 1; // COMPLIANT
  use(l6);   // COMPLIANT
  int l7[10] = {1, 0};
  use(l7); // COMPLIANT
  A l8;
  use(l8); // COMPLIANT - default initialized
}

void test_basic_uninit() {
  int l1;
  use(l1); // NON_COMPLIANT
  int *l2;
  use(l2); // NON_COMPLIANT
  A *l3;
  use(l3); // NON_COMPLIANT
  A l4;
  use(l4.m1); // NON_COMPLIANT[FALSE_NEGATIVE] - field is not initialized
  int l5[10];
  use(l5[0]); // NON_COMPLIANT[FALSE_NEGATIVE] - array entry is not initialized
}

bool cond_init_by_ref(int &ref_param);
bool run1();

void test_conditional(bool x) {

  int l1; // l1 is defined and used only when x is true
  if (x) {
    l1 = 0;
  }
  if (x) {
    use(l1); // COMPLIANT
  }

  int l2; // l2 is defined and used only when x is false
  if (!x) {
    l2 = 0;
  }
  if (!x) {
    use(l2); // COMPLIANT
  }

  bool l3 = false;
  int l4;
  if (x) {
    l3 = true;
    l4 = 1;
  }

  if (l3) {  // l3 true indicates l4 is initialized
    use(l4); // COMPLIANT
  }

  int numElements = 0;
  int *arrayPtr;
  if (x) {
    numElements = 5;
    arrayPtr = new int[5]{};
  }

  if (numElements > 0) { // numElements > 0 indicates arrayPtr is initialized
    use(arrayPtr);       // COMPLIANT[FALSE_POSITIVE]
  }

  int l5;
  bool result = run1() && cond_init_by_ref(l5);

  if (result) { // result indicates l5 is initialized
    use(l5);    // COMPLIANT[FALSE_POSITIVE]
  }

  int l6;
  if (run1() && cond_init_by_ref(l6)) { // result indicates l6 is initialized
    use(l6);                            // COMPLIANT
  }

  int l7;
  if (!run1() || !cond_init_by_ref(l7)) { // result indicates l7 is initialized
    return;
  }
  use(l7); // COMPLIANT

  int l8;
  if (__builtin_expect(!run1() || !cond_init_by_ref(l8),
                       0)) { // result indicates l8 is initialized
    return;
  }
  use(l8); // COMPLIANT[FALSE_NEGATIVE]
}

void test_non_default_init() {
  static int sl;
  use(sl); // COMPLIANT - static variables are zero initialized
  thread_local int tl;
  use(tl); // COMPLIANT - thread local variables are zero initialized
  static int *slp;
  use(slp); // COMPLIANT - static variables are zero initialized
  thread_local int *tlp;
  use(tlp); // COMPLIANT - thread local variables are zero initialized
}