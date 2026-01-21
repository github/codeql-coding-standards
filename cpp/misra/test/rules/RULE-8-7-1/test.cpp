#include <cstdlib>

void stack_allocation_pointer_arithmetic(int *array) {
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

void stack_allocation_array_access(int *array) {
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

void malloc_pointer_arithmetic(int *array) { // [1, 4]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 1)
  int *valid2 = array + 1; // COMPLIANT: pointer points more than one beyond the
                           // last element (lower bound: 1)
  int *valid3 = array + 2; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int *valid4 = array + 3; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 1)
  int *invalid2 = array + 5; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 1)
  int *invalid3 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void malloc_array_access(int *array) { // [1, 4]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 =
      array[0]; // COMPLIANT: pointer is within boundary (lower bound: 1)
  int valid2 = array[1]; // COMPLIANT: pointer points more than one beyond the
                         // last element, but non-compliant to Rule 4.1.3 (lower
                         // bound: 1)
  int valid3 = array[2]; // NON_COMPLIANT: pointer points more than one beyond
                         // the last element (lower bound: 1)
  int valid4 = array[3]; // NON_COMPLIANT: pointer points more than one beyond
                         // the last element (lower bound: 1)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void calloc_pointer_arithmetic(int *array) { // [2, 5]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 2)
  int *valid2 =
      array + 1; // COMPLIANT: pointer is within boundary (lower bound: 2)
  int *valid3 = array + 2; // COMPLIANT: pointer points more than one beyond the
                           // last element, but non-compliant to Rule 4.1.3
                           // (lower bound: 2)
  int *valid4 = array + 3; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 2)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 2)
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void calloc_array_access(int *array) { // [2, 5]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 = array[0];   // COMPLIANT: pointer is within boundary
  int valid2 = array[1];   // COMPLIANT: pointer is within boundary
  int valid3 = array[2];   // COMPLIANT: pointer points more than one beyond the
                           // last element, but non-compliant to Rule 4.1.3
                           // (lower bound: 2)
  int valid4 = array[3];   // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 2)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one
                           // beyond the last element (lower bound: 2)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void realloc_pointer_arithmetic(int *array) { // [3, 6]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid2 =
      array + 1; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid3 =
      array + 2; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid4 = array + 3;   // COMPLIANT: pointer points one beyond the last
                             // element (lower bound: 3)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 3)
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void realloc_array_access(int *array) { // [3, 6]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 =
      array[0]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid2 =
      array[1]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid3 =
      array[2]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid4 =
      array[3]; // COMPLIANT: pointer points one beyond the last
                // element, but non-compliant to Rule 4.1.3 (lower bound: 3)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 3)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

int main(int argc, char *argv[]) {
  /* 1. Array initialized on the stack */
  int array[3] = {0, 1, 2};

  stack_allocation_pointer_arithmetic(array);
  stack_allocation_array_access(array);

  /* 2. Array initialized on the heap */
  int num_of_elements_malloc;
  int num_of_elements_calloc;
  int num_of_elements_realloc;

  if (argc) {
    num_of_elements_malloc = 1;
    num_of_elements_calloc = 2;
    num_of_elements_realloc = 3;
  } else {
    num_of_elements_malloc = 4;
    num_of_elements_calloc = 5;
    num_of_elements_realloc = 6;
  }

  int *array_malloc = (int *)malloc(num_of_elements_malloc * sizeof(int));
  int *array_calloc = (int *)calloc(num_of_elements_calloc, sizeof(int));

  int *array_realloc =
      (int *)realloc(array_malloc, num_of_elements_realloc * sizeof(int));

  malloc_pointer_arithmetic(array_malloc);
  malloc_array_access(array_malloc);

  calloc_pointer_arithmetic(array_calloc);
  calloc_array_access(array_calloc);

  realloc_pointer_arithmetic(array_realloc);
  realloc_array_access(array_realloc);

  return 0;
}
