#include <stddef.h>

extern int a1; // COMPLIANT

#define EE extern int a2
EE; // COMPLIANT

typedef long LL;
typedef int LI;

extern LL a3; // NON_COMPLIANT

extern int a4; // NON_COMPLIANT

extern long a5; // NON_COMPLIANT

#define EE1 extern int a6

EE1; // NON_COMPLIANT

extern LL a7; // NON_COMPLIANT

extern int a9[100];  // COMPLIANT
LI a10[100];         // NON_COMPLIANT
extern int a11[101]; // NON_COMPLIANT - different sizes
signed a12;          // COMPLIANT

extern int *a13; // NON_COMPLIANT

struct NamedStruct0 {
  int val[10];
  unsigned char size; // NON_COMPLIANT - different type
} s0;                 // NON_COMPLIANT - different member type

struct NamedStruct1 {
  int val[10];
  size_t mysize;
} s1; // NON_COMPLIANT - different member name

struct {
  int val[10];
  size_t size;
} s2; // COMPLIANT
