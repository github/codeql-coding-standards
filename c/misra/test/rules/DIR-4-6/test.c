typedef signed char int8_t;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned char uint8_t; // COMPLIANT: exception, typedefs are permitted

typedef signed short int16_t;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned short uint16_t; // COMPLIANT: exception, typedefs are permitted

typedef signed int int32_t;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned int uint32_t; // COMPLIANT: exception, typedefs are permitted

typedef signed long int64_t;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned long uint64_t; // COMPLIANT: exception, typedefs are permitted

typedef signed long long
    int4_t; // NON_COMPLIANT: typedef does not have its indicated size
typedef unsigned long long
    uint4_t; // NON_COMPLIANT: typedef does not have its indicated size

typedef float float32_t;        // COMPLIANT: exception, typedefs are permitted
typedef double float64_t;       // COMPLIANT: exception, typedefs are permitted
typedef long double float128_t; // COMPLIANT: exception, typedefs are permitted

typedef int8_t
    astronomical_number_t; // COMPLIANT: aliasing a fixed-width numeric typedef
typedef uint8_t u_astronomical_number_t; // COMPLIANT: aliasing a fixed-width
                                         // numeric typedef
typedef int
    _astronomical_number_t; // NON_COMPLIANT: aliasing a basic numeric type

int            // COMPLIANT: exception, main's return type can be plain int
main(int argc, // COMPLIANT: exception, argc's type can be plain int
     char *argv[]) { // COMPLIANT: char is not a basic numeric type

  char c1 = 1;          // COMPLIANT: char is not a basic numeric type
  signed char c2 = 1;   // NON_COMPLIANT: use typedef int8_t
  unsigned char c3 = 1; // NON_COMPLIANT: use typedef uint8_t
  int8_t c4 = 1;        // COMPLIANT: typedef used instead

  short s1 = 1;          // NON_COMPLIANT: short is a basic numeric type
  signed short s2 = 1;   // NON_COMPLIANT: use typedef int16_t
  unsigned short s3 = 1; // NON_COMPLIANT: use typedef uint16_t
  int16_t s4 = 1;        // COMPLIANT: typedef used instead

  int i1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed int i2 = 1;   // NON_COMPLIANT: use typedef int32_t
  unsigned int i3 = 1; // NON_COMPLIANT: use typedef uint32_t
  int32_t i4 = 1;      // COMPLIANT: typedef used instead

  long l1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed long l2 = 1;   // NON_COMPLIANT: use typedef int64_t
  unsigned long l3 = 1; // NON_COMPLIANT: use typedef uint64_t
  int64_t l4 = 1;       // COMPLIANT: typedef used instead

  long long ll1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed long long ll2 = 1;   // NON_COMPLIANT: use typedef int64_t
  unsigned long long ll3 = 1; // NON_COMPLIANT: use typedef uint64_t
  int64_t ll4 = 1;            // COMPLIANT: typedef used instead

  float f1 = 1; // NON_COMPLIANT: float is a basic numeric type, use a typedef
  float32_t f2 = 1; // COMPLIANT: typedef used instead

  double d1 = 1;    // NON_COMPLIANT: int is a basic numeric type
  float64_t d2 = 1; // COMPLIANT: typedef used instead

  long double ld1 = 1; // NON_COMPLIANT: int is a basic numeric type
  float128_t ld2 = 1;  // COMPLIANT: typedef used instead
}