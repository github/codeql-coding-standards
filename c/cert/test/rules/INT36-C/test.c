#include <stdint.h>

int main() {
  /* Compliant declarations and assignments */
  int integer1 = 1;        // COMPLIANT: declaring integer as integer
  int integer2 = integer1; // COMPLIANT: declaring integer as integer
  integer1 =
      integer2; // COMPLIANT: assigning integer rvalue to integer variable
  int *int_pointer1 =
      &integer1; // COMPLIANT: declaring pointer variable as an address
  int *int_pointer2 = int_pointer1; // COMPLIANT: declaring pointer variable as
                                    // an address rvalue
  int_pointer1 =
      int_pointer2; // COMPLIANT: assigning pointer rvalue to a pointer variable

  /* Integer to pointer */
  int *int_pointer3 = 0x01abcdef; // NON_COMPLIANT: declaring pointer variable
                                  // with raw hex integer
  int_pointer3 =
      0x01abcdef; // NON_COMPLIANT: assigning raw hex to pointer variable
  int *int_pointer4 =
      integer1; // NON_COMPLIANT: declaring pointer variable with integer value
  int_pointer4 =
      integer1 +
      1; // NON_COMPLIANT: assigning integer rvalue to pointer variable
  int *integer_address5 =
      (int *)0x01abcdef; // NON_COMPLIANT: casting raw hex to pointer type
  int *integer_address6 =
      (int *)integer1; // NON_COMPLIANT: casting integer value to pointer type

  /* Pointer to integer */
  int *integer_address7 =
      &integer1; // COMPLIANT: declaring pointer variable as an address
  int integer_address8 = &integer1; // NON_COMPLIANT: declaring integer
                                    // variable with pointer type value
  integer_address8 = &integer1; // NON_COMPLIANT: assigning pointer type rvalue
                                // to integer variable
  int integer_address =
      (int)&integer1; // NON_COMPLIANT: casting pointer value to integer type

  /* Exceptions that are COMPLIANT */
  int *null_pointer1 =
      0; // COMPLIANT: integer 0 converted to pointer becomes null pointer
  int *null_pointer2 = (int *)0; // COMPLIANT: integer 0 is converted to pointer
                                 // becomes null pointer
  null_pointer2 =
      0; // COMPLIANT: integer 0 converted to pointer becomes null pointer

  void *void_pointer = &integer1;
  intptr_t void_pointer_integer1 =
      void_pointer; // COMPLIANT: void pointer can be converted to intptr_t
  uintptr_t void_pointer_integer2 =
      void_pointer; // COMPLIANT: void pointer can be converted to uintptr_t
  void *void_pointer1 = (void *)
      void_pointer_integer1; // COMPLIANT: intptr_t can be converted to void*
  void *void_pointer2 = (void *)
      void_pointer_integer2; // COMPLIANT: uintptr_t can be converted to void*

  return 0;
}