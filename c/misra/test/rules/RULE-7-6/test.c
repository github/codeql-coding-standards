#include "stdint.h"

int8_t g1 = INT8_C(0x12);       // NON-COMPLIANT
uint8_t g2 = UINT8_C(0x12);     // NON-COMPLIANT
int16_t g3 = INT16_C(0x1234);   // NON-COMPLIANT
uint16_t g4 = UINT16_C(0x1234); // NON-COMPLIANT
int32_t g5 = INT32_C(0x1234);   // COMPLIANT
uint32_t g6 = UINT32_C(0x1234); // COMPLIANT
int64_t g7 = INT64_C(0x1234);   // COMPLIANT
uint64_t g8 = UINT64_C(0x1234); // COMPLIANT