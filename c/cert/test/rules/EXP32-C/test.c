volatile int *volatile_f();

void test_cast_away_volatile() {
  volatile int *l1 = volatile_f(); // COMPLIANT
  int *l2 = (int *)l1;             // NON_COMPLIANT
  int *l3 = (int *)volatile_f();   // NON_COMPLIANT
  *l2; // Volatile object is accessed through a non-volatile pointer
}

void test_volatile_lost_by_assignment() {
  static volatile int val = 0;
  static int *non_compliant_pointer;
  static volatile int **compliant_pointer_to_pointer;
  compliant_pointer_to_pointer = &non_compliant_pointer; // NON_COMPLIANT
  *compliant_pointer_to_pointer = &val;
  *non_compliant_pointer; // Volatile object is accessed through a non-volatile
                          // pointer
}

void test_volatile_lost_by_assignment_and_cast() {
  static volatile int val = 0;
  static int *non_compliant_pointer;
  static volatile int **compliant_pointer_to_pointer;
  compliant_pointer_to_pointer =
      (int **)&non_compliant_pointer; // NON_COMPLIANT
  *compliant_pointer_to_pointer = &val;
  *non_compliant_pointer; // Volatile object is accessed through a non-volatile
                          // pointer
}

void test_volatile_not_lost_by_assignment_and_cast() {
  static volatile int val = 0;
  static volatile int *compliant_pointer;
  static volatile int **compliant_pointer_to_pointer;
  compliant_pointer_to_pointer = &compliant_pointer; // COMPLIANT
  *compliant_pointer_to_pointer = &val;
  *compliant_pointer; // Volatile object is accessed through a volatile pointer
}

void test_volatile_lost_by_assignment_and_cast_2() {
  volatile int *ptr = 0;
  int *volatile ptr2 = (int *volatile)ptr; // NON_COMPLIANT
  *ptr2; // Volatile object dereferenced through volatile pointer to
         // non-volatile object
}