#include <cstdlib>

void f1(int *array) {
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

void f2(int *array) {
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

void f1_realloc(int *array) {
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

void f2_realloc(int *array) {
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 = array[0];   // COMPLIANT: pointer is within boundary
  int valid2 = array[1];   // COMPLIANT: pointer is within boundary
  int valid3 = array[2];   // COMPLIANT: pointer points one beyond the last
  int invalid1 = array[3]; // NON_COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid2 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element
  int invalid3 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

int main(int argc, char *argv[]) {
  /* 1. Array initialized on the stack */
  int array[3] = {0, 1, 2};

  f1(array);
  f2(array);

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

  f1(array_malloc);
  f2(array_malloc);

  f1(array_calloc);
  f2(array_calloc);

  f1_realloc(array_realloc);
  f2_realloc(array_realloc);

  return 0;
}
