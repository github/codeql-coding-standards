void testWiderAssignment() {
  unsigned int u32 = 100;
  unsigned short u16 = 100;
  u16 = u16 + u16;                    // COMPLIANT
  u32 = u16 + u16;                    // NON_COMPLIANT
  u32 = (unsigned int)(u16 + u16);    // COMPLIANT
  unsigned int u32_2 = u16 + u16;     // NON_COMPLIANT
  unsigned int u32a[1] = {u16 + u16}; // NON_COMPLIANT

  signed int s32 = u16 + u16; // ignored - prohibited by Rule 10.3
}