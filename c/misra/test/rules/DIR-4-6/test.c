#include <stdint.h>

typedef signed char INT8;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned char UINT8; // COMPLIANT: exception, typedefs are permitted

typedef short _INT16;          // COMPLIANT: exception, typedefs are permitted
typedef signed short INT16;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned short UINT16; // COMPLIANT: exception, typedefs are permitted

typedef int _INT32;          // COMPLIANT: exception, typedefs are permitted
typedef signed int INT32;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned int UINT32; // COMPLIANT: exception, typedefs are permitted

typedef long _INT64;          // COMPLIANT: exception, typedefs are permitted
typedef signed long INT64;    // COMPLIANT: exception, typedefs are permitted
typedef unsigned long UINT64; // COMPLIANT: exception, typedefs are permitted

typedef long long _INT128;       // COMPLIANT: exception, typedefs are permitted
typedef signed long long INT128; // COMPLIANT: exception, typedefs are permitted
typedef unsigned long long
    UINT128; // COMPLIANT: exception, typedefs are permitted

typedef float FLOAT32;        // COMPLIANT: exception, typedefs are permitted
typedef double FLOAT64;       // COMPLIANT: exception, typedefs are permitted
typedef long double FLOAT128; // COMPLIANT: exception, typedefs are permitted

typedef int8_t
    astronomical_number_t; // COMPLIANT: aliasing a fixed-width numeric typedef
typedef uint8_t u_astronomical_number_t; // COMPLIANT: aliasing a fixed-width
                                         // numeric typedef
typedef int
    astronomical_number_t; // NON_COMPLIANT: aliasing a basic numeric type

int            // COMPLIANT: exception, main's return type can be plain int
main(int argc, // COMPLIANT: exception, argc's type can be plain int
     char *argv[]) { // COMPLIANT: char is not a basic numeric type

  char c1 = 1;          // COMPLIANT: char is not a basic numeric type
  signed char c2 = 1;   // NON_COMPLIANT: use typedef int8_t  in stdint
  unsigned char c3 = 1; // NON_COMPLIANT: use typedef uint8_t in stdint
  INT8 c4 = 1;          // COMPLIANT: typedef used instead

  short s1 = 1;          // NON_COMPLIANT: short is a basic numeric type
  signed short s2 = 1;   // NON_COMPLIANT: use typedef int16_t  in stdint
  unsigned short s3 = 1; // NON_COMPLIANT: use typedef uint16_t in stdint
  INT16 s4 = 1;          // COMPLIANT: typedef used instead

  int i1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed int i2 = 1;   // NON_COMPLIANT: use typedef int32_t  in stdint
  unsigned int i3 = 1; // NON_COMPLIANT: use typedef uint32_t in stdint
  INT32 s4 = 1;        // COMPLIANT: typedef used instead

  long l1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed long l2 = 1;   // NON_COMPLIANT: use typedef int64_t  in stdint
  unsigned long l3 = 1; // NON_COMPLIANT: use typedef uint64_t in stdint
  INT64 s4 = 1;         // COMPLIANT: typedef used instead

  long long l1 = 1;          // NON_COMPLIANT: int is a basic numeric type
  signed long long l2 = 1;   // NON_COMPLIANT: use typedef int128_t  in stdint
  unsigned long long l3 = 1; // NON_COMPLIANT: use typedef uint128_t in stdint
  INT128 s4 = 1;             // COMPLIANT: typedef used instead

  float f1 = 1;   // NON_COMPLIANT: float is a basic numeric type, use a typedef
  FLOAT32 f2 = 1; // COMPLIANT: typedef used instead

  double d1 = 1;  // NON_COMPLIANT: int is a basic numeric type
  FLOAT64 d2 = 1; // COMPLIANT: typedef used instead

  long double ld1 = 1; // NON_COMPLIANT: int is a basic numeric type
  FLOAT128 ld2 = 1;    // COMPLIANT: typedef used instead
}