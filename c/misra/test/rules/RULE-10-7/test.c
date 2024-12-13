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

  float f32 = 10.0f;
  double f64 = 10.0f;
  float _Complex cf32 = 10.0f;
  double _Complex cf64 = 10.0f;

  f32 + (f32 + f32);    // COMPLIANT
  cf32 + (cf32 + cf32); // COMPLIANT
  f32 + (cf32 + cf32);  // COMPLIANT
  cf32 + (f32 + f32);   // COMPLIANT
  f64 + (f32 + f32);    // NON_COMPLIANT
  f64 + (cf32 + cf32);  // NON_COMPLIANT
  cf64 + (f32 + f32);   // NON_COMPLIANT
  cf64 + (cf32 + cf32); // NON_COMPLIANT
}