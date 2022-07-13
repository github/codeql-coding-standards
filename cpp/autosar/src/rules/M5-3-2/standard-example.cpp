uint8_t  a = -1U;   // Non-compliant – a is assigned 255
int32_t  b = -a;    // Non-compliant – b is assigned -255
uint32_t c = 1U;
int64_t  d = -c;    // Non-compliant – d is assigned MAX_UINT