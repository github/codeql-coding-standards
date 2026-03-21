#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cwchar>

void stack_allocated_multi_dimensional_array_access(int array[2][3]) {
  int valid11 = array[0][0];  // COMPLIANT: pointer is within boundary
  int valid12 = array[0][1];  // COMPLIANT: pointer is within boundary
  int valid13 = array[0][2];  // COMPLIANT: pointer is within boundary
  int valid14 = array[0][3];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid1 = array[0][4]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid21 = array[1][0];  // COMPLIANT: pointer is within boundary
  int valid22 = array[1][1];  // COMPLIANT: pointer is within boundary
  int valid23 = array[1][2];  // COMPLIANT: pointer is within boundary
  int valid24 = array[1][3];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid2 = array[1][4]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid31 = array[2][0]; // COMPLIANT: pointer points one beyond the last
                             // element, but non-compliant to Rule 4.1.3

  int invalid3 = array[3][0]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element
}

void stack_allocated_multi_dimensional_pointer_arithmetic(int array[2][3]) {
  int valid111 = *(*(array + 0) + 0); // COMPLIANT: pointer is within boundary
  int valid112 = *(
      *(array +
        0)); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid113 = **array; // COMPLIANT: pointer is within boundary (equivalent
                          // to the above)
  int valid121 = *(*(array + 0) + 1); // COMPLIANT: pointer is within boundary
  int valid122 =
      *(*array +
        1); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid131 = *(*(array + 0) + 2); // COMPLIANT: pointer is within boundary
  int valid132 = *(*array + 2);       // COMPLIANT: pointer is within boundary
  int valid141 = *(*(array + 0) + 3); // COMPLIANT: pointer points to one beyond
                                      // the last element
  int valid142 = *(*array + 3); // COMPLIANT: pointer points to one beyond the
                                // last element (equivalent to the above)
  int invalid11 = *(*(array + 0) + 4); // NON_COMPLIANT: pointer points more
                                       // than one beyond the last element
  int invalid12 =
      *(*array + 4); // NON_COMPLIANT: pointer points more than
                     // one beyond the last element (equivalent to the above)

  int valid211 = *(*(array + 1) + 0); // COMPLIANT: pointer is within boundary
  int valid212 = *(
      *(array +
        1)); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid22 = *(*(array + 1) + 1); // COMPLIANT: pointer is within boundary
  int valid23 = *(*(array + 1) + 2); // COMPLIANT: pointer points one beyond the
                                     // last element
  int valid24 =
      *(*(array + 1) +
        3); // COMPLIANT: pointer points to one beyond the last element
  int invalid2 = *(*(array + 1) + 4); // NON_COMPLIANT: pointer points more than
                                      // one beyond the last element

  int valid311 = *(*(array + 2) + 0); // COMPLIANT: pointer points one beyond
                                      // the last element
  int valid312 = *(*(array + 2)); // COMPLIANT: pointer points one beyond the
                                  // last element (equivalent to the above)
  int invalid31 = *(*(array + 3) + 0); // NON_COMPLIANT: pointer points more
                                       // than one beyond the last element
  int invalid32 =
      *(*(array + 3)); // NON_COMPLIANT: pointer points more than
                       // one beyond the last element (equivalent to the above)
}

int main(int argc, char *argv[]) {
  int stack_multi_dimensional_array[2][3] = {{1, 2, 3}, {4, 5, 6}};

  stack_allocated_multi_dimensional_array_access(stack_multi_dimensional_array);
  stack_allocated_multi_dimensional_pointer_arithmetic(
      stack_multi_dimensional_array);

  return 0;
}
