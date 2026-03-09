#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cwchar>

void stack_allocated_single_dimensional_pointer_arithmetic(int *array) {
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array;     // COMPLIANT: pointer is within boundary
  int *valid2 = array + 1; // COMPLIANT: pointer is within boundary
  int *valid3 = array + 2; // COMPLIANT: pointer is within boundary
  int *valid4 =
      array + 3; // COMPLIANT: pointer points one beyond the last element
  int *invalid1 =
      array +
      4; // NON_COMPLIANT: pointer points more than one beyond the last element
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void stack_allocated_single_dimensional_array_access(int *array) {
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 = array[0];   // COMPLIANT: pointer is within boundary
  int valid2 = array[1];   // COMPLIANT: pointer is within boundary
  int valid3 = array[2];   // COMPLIANT: pointer is within boundary
  int valid4 = array[3];   // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

int main(int argc, char *argv[]) {
  /* 1. Single-dimensional array initialized on the stack */
  int stack_single_dimensional_array[3] = {0, 1, 2};

  stack_allocated_single_dimensional_pointer_arithmetic(
      stack_single_dimensional_array);
  stack_allocated_single_dimensional_array_access(
      stack_single_dimensional_array);

  return 0;
}
