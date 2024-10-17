#define TEST 1

void f(int n) {
  int a[1]; // COMPLIANT
  int x = 1;
  int a1[1 + x];  // NON_COMPLIANT - not integer constant expr
  int a2[n];      // NON_COMPLIANT
  int a3[1][n];   // NON_COMPLIANT
  int a4[] = {1}; // COMPLIANT - not a VLA
  int a5[TEST];   // COMPLIANT
  int a6[1 + 1];  // COMPLIANT
  int a7[n][1];   // NON_COMPLIANT
  int(*a8)[n];    // COMPLIANT - pointer to VLA, see RULE-18-10

  extern int e1[]; // COMPLIANT

  // A typedef is not a VLA. However, `VlaDeclStmt`s match the typedef.
  typedef int vlaTypedef[n]; // COMPLIANT[FALSE_POSITIVE]
  vlaTypedef t1;             // NON_COMPLIANT[FALSE_NEGATIVE]
}

void f1(int n,
        // Parameter array types are adjusted to pointers
        int p1[n], // COMPLIANT
        // Pointers to variably-modified types are not VLAs.
        int p2[n][n],
        int p3[],  // array of unknown length is converted to pointer
        int p4[][] // array of unknown length are not VLAs.
) {}

struct s {
  // Structs must have at least one non-flexible array member.
  int foo;

  // Flexible array members are not VLAs.
  int flexibleArrayMember[]; // COMPLIANT
};