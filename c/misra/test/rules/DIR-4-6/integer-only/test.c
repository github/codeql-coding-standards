typedef signed char int8_t;         // COMPLIANT
typedef unsigned char uint8_t;      // COMPLIANT
typedef signed short int16_t;       // COMPLIANT
typedef unsigned short uint16_t;    // COMPLIANT
typedef signed int int32_t;         // COMPLIANT
typedef unsigned int uint32_t;      // COMPLIANT
typedef signed long int64_t;        // COMPLIANT
typedef unsigned long uint64_t;     // COMPLIANT
typedef signed long long int4_t;    // NON_COMPLIANT - wrong indicated size
typedef unsigned long long uint4_t; // NON_COMPLIANT - wrong indicated size

typedef int8_t count_t;      // COMPLIANT
typedef int plain_int_alias; // NON_COMPLIANT - aliases a plain integer type

typedef float real_type;             // COMPLIANT - floating-point excluded
typedef real_type real_alias;        // COMPLIANT - floating-point excluded
typedef double _Complex float64_t;   // COMPLIANT - floating-point excluded
typedef float cfloat32_t;            // COMPLIANT - floating-point excluded
typedef double _Complex cfloat128_t; // COMPLIANT - floating-point excluded

int main(int argc, char *argv[]) { // COMPLIANT - main signature exception
  char c1 = 1;                     // COMPLIANT - plain char excluded
  signed char c2 = 1;              // NON_COMPLIANT
  unsigned char c3 = 1;            // NON_COMPLIANT
  int8_t c4 = 1;                   // COMPLIANT

  short s1 = 1;          // NON_COMPLIANT
  signed short s2 = 1;   // NON_COMPLIANT
  unsigned short s3 = 1; // NON_COMPLIANT
  int16_t s4 = 1;        // COMPLIANT

  int i1 = 1;          // NON_COMPLIANT
  signed int i2 = 1;   // NON_COMPLIANT
  unsigned int i3 = 1; // NON_COMPLIANT
  int32_t i4 = 1;      // COMPLIANT

  long l1 = 1;          // NON_COMPLIANT
  signed long l2 = 1;   // NON_COMPLIANT
  unsigned long l3 = 1; // NON_COMPLIANT
  int64_t l4 = 1;       // COMPLIANT

  long long ll1 = 1;          // NON_COMPLIANT
  signed long long ll2 = 1;   // NON_COMPLIANT
  unsigned long long ll3 = 1; // NON_COMPLIANT

  float f1 = 1.0f;           // COMPLIANT - floating-point excluded
  double d1 = 1.0;           // COMPLIANT - floating-point excluded
  long double ld1 = 1.0L;    // COMPLIANT - floating-point excluded
  float _Complex cf1 = 1.0f; // COMPLIANT - floating-point excluded
  return 0;
}

void test_complex_names(void) {
  typedef int cfloat32_t; // NON_COMPLIANT - matching width, but not complex
  typedef int cfloat16_t; // NON_COMPLIANT - mismatched width, but not complex
}
