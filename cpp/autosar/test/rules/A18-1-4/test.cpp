#include <memory>

int *allocate_int_array() { return new int[2]; }

int *allocate_int_ptr() { return new int(0); }

int *get_bad_ptr() { return *(int **)0x1; }

void up_f1() {
  std::unique_ptr<int[]> v1 = std::make_unique<int[]>(2); // COMPLIANT
  std::unique_ptr<int[]> v2(v1.release());                // COMPLIANT
  std::unique_ptr<int> v3(v2.release());                  // NON_COMPLIANT
}

void up_f2() {

  int *int_array = allocate_int_array();
  std::unique_ptr<int[]> v1(int_array);               // COMPLIANT
  std::unique_ptr<int> v2(allocate_int_array());      // NON_COMPLIANT
  std::unique_ptr<int> v3 = std::make_unique<int>(1); // COMPLIANT
  v3.reset(allocate_int_ptr());                       // COMPLIANT
  v3.reset(get_bad_ptr());                            // COMPLIANT
  v3.reset(allocate_int_array());                     // NON_COMPLIANT
}

void sp_f1() {
  int *int_array = allocate_int_array();
  int *bad_ptr = get_bad_ptr();
  int *int_ptr = allocate_int_ptr();

  std::shared_ptr<int> v1 = std::make_shared<int>(2); // COMPLIANT
  v1.reset(int_array);                                // NON_COMPLIANT
  std::shared_ptr<int> v2(int_ptr);                   // COMPLIANT
  v2.reset(bad_ptr);                                  // COMPLIANT
}