#define TEST 1

// globals - external linkage
int a[1]; // COMPLIANT
int x = 1;
// int a1[1 + x];  // NON_COMPLIANT - compiler checked
// int a2[x];      //NON_COMPLIANT - compiler checked
// int a3[1][x];   // NON_COMPLIANT - compiler checked
int a4[] = {1}; // COMPLIANT - size explicitly provided
// int a5[];       // NON_COMPLIANT - compiler checked
int a6[1 + 1]; // COMPLIANT - size explicitly provided
// int a7[x][1];   // NON_COMPLIANT - compiler checked
// int (*a8)[x];   // NON_COMPLIANT - compiler checked

void f(int n) {
  int a1[] = {1}; // COMPLIANT - not external linkage
  int a2[1];      // COMPLIANT - not external linkage

  extern int e1[]; // NON_COMPLIANT
}

struct s {
  // Structs must have at least one non-flexible array member.
  int foo;

  // static data members have external linkage - but not currently detected in
  // our external linkage lib - also FAMs are not in scope for this rule
  static const int flexibleArrayMember[]; // COMPLIANT
};