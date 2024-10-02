#include "stdbool.h"
#include "stdint.h"

#define NULL 0
#define NULLPTR ((void *)NULL)

uint_least8_t g1[] = {
    // Basic valid
    UINT8_C(0),    // COMPLIANT
    UINT8_C(1),    // COMPLIANT
    UINT8_C(8),    // COMPLIANT
    UINT8_C(0x23), // COMPLIANT
    UINT8_C(034),  // COMPLIANT

    // Incorrect literal types
    UINT8_C(1.0),    // NON-COMPLIANT
    UINT8_C(-1.0),   // NON-COMPLIANT
    UINT8_C(0b111),  // NON-COMPLIANT
    UINT8_C(-0b111), // NON-COMPLIANT
    UINT8_C('a'),    // NON-COMPLIANT
    UINT8_C(-'$'),   // NON-COMPLIANT
    UINT8_C('\n'),   // NON-COMPLIANT

    // Suffixes disallowed
    UINT8_C(1u),   // NON-COMPLIANT
    UINT8_C(2U),   // NON-COMPLIANT
    UINT8_C(3l),   // NON-COMPLIANT
    UINT8_C(4L),   // NON-COMPLIANT
    UINT8_C(5ul),  // NON-COMPLIANT
    UINT8_C(5ll),  // NON-COMPLIANT
    UINT8_C(5ull), // NON-COMPLIANT

    // Range tests
    UINT8_C(255),   // COMPLIANT
    UINT8_C(0xFF),  // COMPLIANT
    UINT8_C(0377),  // COMPLIANT
    UINT8_C(256),   // NON-COMPLIANT
    UINT8_C(0400),  // NON-COMPLIANT
    UINT8_C(0x100), // NON-COMPLIANT

    // Signage tests
    UINT8_C(-1),    // NON-COMPLIANT
    UINT8_C(-20),   // NON-COMPLIANT
    UINT8_C(-33),   // NON-COMPLIANT
    UINT8_C(-0x44), // NON-COMPLIANT

    // Invalid nonliteral expressions
    UINT8_C(0 + 0),     // NON-COMPLIANT
    UINT8_C("a"[0]),    // NON-COMPLIANT
    UINT8_C(0 ["a"]),   // NON-COMPLIANT
    UINT8_C(UINT8_MAX), // COMPLIANT
    UINT8_C(true),      // NON-COMPLIANT[False Negative]
    UINT8_C(false),     // NON-COMPLIANT[False Negative]
    UINT8_C(NULL),      // NON-COMPLIANT[False Negative]
    UINT8_C(NULLPTR),   // NON-COMPLIANT[False Negative]
};

int_least8_t g2[] = {
    // Basic valid
    INT8_C(0),    // COMPLIANT
    INT8_C(1),    // COMPLIANT
    INT8_C(8),    // COMPLIANT
    INT8_C(0x23), // COMPLIANT
    INT8_C(034),  // COMPLIANT

    // Range tests
    INT8_C(127),   // COMPLIANT
    INT8_C(0x79),  // COMPLIANT
    INT8_C(0177),  // COMPLIANT
    INT8_C(128),   // NON-COMPLIANT
    INT8_C(0200),  // NON-COMPLIANT
    INT8_C(0x80),  // NON-COMPLIANT
    INT8_C(-128),  // COMPLIANT
    INT8_C(-0x80), // COMPLIANT
    INT8_C(-0200), // COMPLIANT
    INT8_C(-129),  // NON-COMPLIANT
    INT8_C(-0201), // NON-COMPLIANT
    INT8_C(-0x81), // NON-COMPLIANT
};

uint_least16_t g3[] = {
    // Basic valid
    UINT16_C(0),    // COMPLIANT
    UINT16_C(0x23), // COMPLIANT
    UINT16_C(034),  // COMPLIANT

    // Range tests
    UINT16_C(65535),   // COMPLIANT
    UINT16_C(0xFFFF),  // COMPLIANT
    UINT16_C(0177777), // COMPLIANT
    UINT16_C(65536),   // NON-COMPLIANT
    UINT16_C(0200000), // NON-COMPLIANT
    UINT16_C(0x10000), // NON-COMPLIANT
};

int_least16_t g4[] = {
    // Basic valid
    INT16_C(0),    // COMPLIANT
    INT16_C(0x23), // COMPLIANT
    INT16_C(034),  // COMPLIANT

    // Range tests
    INT16_C(32767),    // COMPLIANT
    INT16_C(0x7FFF),   // COMPLIANT
    INT16_C(077777),   // COMPLIANT
    INT16_C(32768),    // NON-COMPLIANT
    INT16_C(0100000),  // NON-COMPLIANT
    INT16_C(0x8000),   // NON-COMPLIANT
    INT16_C(-32768),   // COMPLIANT
    INT16_C(-0100000), // COMPLIANT
    INT16_C(-0x8000),  // COMPLIANT
    INT16_C(-32769),   // NON-COMPLIANT
    INT16_C(-0100001), // NON-COMPLIANT
    INT16_C(-0x8001),  // NON-COMPLIANT
};

uint_least32_t g5[] = {
    // Basic valid
    UINT32_C(0), // COMPLIANT

    // Range tests
    UINT32_C(4294967295),  // COMPLIANT
    UINT32_C(0xFFFFFFFF),  // COMPLIANT
    UINT32_C(4294967296),  // NON-COMPLIANT
    UINT32_C(0x100000000), // NON-COMPLIANT
};

int_least32_t g6[] = {
    // Basic valid
    INT32_C(0), // COMPLIANT

    // Range tests
    INT32_C(2147483647),  // COMPLIANT
    INT32_C(0x7FFFFFFF),  // COMPLIANT
    INT32_C(2147483648),  // NON-COMPLIANT
    INT32_C(0x80000000),  // NON-COMPLIANT
    INT32_C(-2147483648), // COMPLIANT
    INT32_C(-0x80000000), // COMPLIANT
    INT32_C(-2147483649), // NON-COMPLIANT
    INT32_C(-0x80000001), // NON-COMPLIANT
};

uint_least64_t g7[] = {
    // Basic valid
    UINT64_C(0), // COMPLIANT

    // Range tests
    UINT64_C(18446744073709551615), // COMPLIANT
    UINT64_C(0xFFFFFFFFFFFFFFFF),   // COMPLIANT
    // Compile time error if we try to create integer literals beyond this.
};

int_least64_t g8[] = {
    // Basic valid
    INT64_C(0), // COMPLIANT

    // Range tests
    INT64_C(9223372036854775807), // COMPLIANT
    // INT64_C(9223372036854775808) is a compile-time error

    // -9223372036854775808 allowed, but cannot be created via unary- without
    // compile time errors.
    INT64_C(-9223372036854775807),     // COMPLIANT
    INT64_C(-9223372036854775807 - 1), // COMPLIANT
    // -9223372036854775809 is not allowed, and cannot be created via unary-
    // without compile time errors.
    INT64_C(-9223372036854775807 - 2),           // NON-COMPLIANT
    INT64_C(-9223372036854775807 - 20000000000), // NON-COMPLIANT

    INT64_C(0x7FFFFFFFFFFFFFFF),  // COMPLIANT
    INT64_C(0x8000000000000000),  // NON-COMPLIANT[FALSE NEGATIVE]
    INT64_C(-0x8000000000000000), // COMPLIANT
    INT64_C(-0x8000000000000001), // NON-COMPLIANT[FALSE NEGATIVE]
    INT64_C(-0x8001000000000000), // NON-COMPLIANT
};

// Other edge cases:
void f(void) {
  uint32_t l1 = 1;
  // `UnrecognizedNumericLiteral` case:
  int64_t l2 = ((int32_t)UINT64_C(0x1b2) * (l1)); // COMPLIANT
}