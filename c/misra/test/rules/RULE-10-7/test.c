void testComposite() {
  unsigned int u32 = 100;
  unsigned short u16 = 100;
  u16 + u32 *u16;                 // COMPLIANT
  u32 + u16 *u16;                 // NON_COMPLIANT
  u32 *(u16 + u16);               // NON_COMPLIANT
  u32 *(unsigned int)(u16 + u16); // COMPLIANT
  u32 + u16 + u16;                // COMPLIANT
  u32 += (u16 + u16);             // NON_COMPLIANT
  u32 += (u32 + u16);             // COMPLIANT

  signed int s32 = 100;
  s32 += (u16 + u16); // // ignored - prohibited by Rule 10.4
}