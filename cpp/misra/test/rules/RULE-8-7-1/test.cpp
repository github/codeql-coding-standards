#include <cstdlib>

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

void malloc_single_dimensional_pointer_arithmetic(int *array) { // [1, 4]
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

void malloc_single_dimensional_array_access(int *array) { // [1, 4]
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

void calloc_single_dimensional_pointer_arithmetic(int *array) { // [2, 5]
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

void calloc_single_dimensional_array_access(int *array) { // [2, 5]
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

void realloc_single_dimensional_pointer_arithmetic(int *array) { // [3, 6]
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

void realloc_single_dimensional_array_access(int *array) { // [3, 6]
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

void stack_allocated_multi_dimensional_array_access(int array[2][3]) {
  int valid11 = array[0][0];  // COMPLIANT: pointer is within boundary
  int valid12 = array[0][1];  // COMPLIANT: pointer is within boundary
  int valid13 = array[0][2];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid1 = array[0][3]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid21 = array[1][0]; // COMPLIANT: pointer is within boundary
  int valid22 = array[1][1]; // COMPLIANT: pointer is within boundary
  int valid23 = array[1][2]; // COMPLIANT: pointer points one beyond the last
                             // element, but non-compliant to Rule 4.1.3

  int invalid2 = array[1][3]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid31 = array[2][0];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid3 = array[3][0]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element
}

void stack_allocated_multi_dimensional_pointer_arithmetic(int array[2][3]) {
  int valid11 = *(*(array + 0) + 0); // COMPLIANT: pointer is within boundary
  int valid12 = *(*(array + 0) + 1); // COMPLIANT: pointer is within boundary
  int valid13 =
      *(*(array + 0) + 2); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid1 = *(*(array + 0) + 3); // NON_COMPLIANT: pointer points more than
                                      // one beyond the last element

  int valid21 = *(*(array + 1) + 0); // COMPLIANT: pointer is within boundary
  int valid22 = *(*(array + 1) + 1); // COMPLIANT: pointer is within boundary
  int valid23 =
      *(*(array + 1) + 2); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid2 = *(*(array + 1) + 3); // NON_COMPLIANT: pointer points more than
                                      // one beyond the last element

  int valid31 =
      *(*(array + 2) + 0); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid3 = *(*(array + 3) + 0); // NON_COMPLIANT: pointer points more than
                                      // one beyond the last element
}

int main(int argc, char *argv[]) {
  /* 1. Single-dimensional array initialized on the stack */
  int stack_single_dimensional_array[3] = {0, 1, 2};

  stack_allocated_single_dimensional_pointer_arithmetic(
      stack_single_dimensional_array);
  stack_allocated_single_dimensional_array_access(
      stack_single_dimensional_array);

  /* 2. Single-dimensional array initialized on the heap */
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

  int *single_dimensional_array_malloc =
      (int *)malloc(num_of_elements_malloc * sizeof(int));
  int *single_dimensional_array_calloc =
      (int *)calloc(num_of_elements_calloc, sizeof(int));

  int *single_dimensional_array_realloc = (int *)realloc(
      single_dimensional_array_malloc, num_of_elements_realloc * sizeof(int));

  malloc_single_dimensional_pointer_arithmetic(single_dimensional_array_malloc);
  malloc_single_dimensional_array_access(single_dimensional_array_malloc);

  calloc_single_dimensional_pointer_arithmetic(single_dimensional_array_calloc);
  calloc_single_dimensional_array_access(single_dimensional_array_calloc);

  realloc_single_dimensional_pointer_arithmetic(
      single_dimensional_array_realloc);
  realloc_single_dimensional_array_access(single_dimensional_array_realloc);

  /* 3. Multi-dimensional array initialized on the stack */
  int stack_multi_dimensional_array[2][3] = {{1, 2, 3}, {4, 5, 6}};

  /* 4. Multi-dimensional array initialized on the heap */
  int (*heap_multi_dimensional_array)[3] =
      (int (*)[3])malloc(sizeof(int[2][3]));

  stack_allocated_multi_dimensional_array_access(stack_multi_dimensional_array);
  stack_allocated_multi_dimensional_pointer_arithmetic(
      stack_multi_dimensional_array);

  return 0;
}
