#include <stddef.h>

int a1;  // COMPLIANT
int a2;  // COMPLIANT
long a3; // NON_COMPLIANT
long a4; // NON_COMPLIANT
int a5;  // NON_COMPLIANT
long a6; // NON_COMPLIANT
int a7;  // NON_COMPLIANT

int a8;        // COMPLIANT
extern int a8; // COMPLIANT

int a9[100];  // COMPLIANT
int a10[100]; // NON_COMPLIANT
int a11[100]; // NON_COMPLIANT - different sizes
int a12;      // COMPLIANT

int *const a13; // NON_COMPLIANT

struct NamedStruct0 {
  int val[10];
  size_t size; // NON_COMPLIANT - different type
} s0;          // NON_COMPLIANT - different member type

struct NamedStruct1 {
  int val[10];
  size_t size;
} s1; // NON_COMPLIANT - different member name

struct {
  int val[10];
  size_t size;
} s2; // COMPLIANT

struct OuterStruct {
  struct {
    int val[10]; // COMPLIANT
    size_t size;
  } firstArray;

  struct {
    int val[10][2]; // COMPLIANT
    size_t size;
  } secondArray;
};
