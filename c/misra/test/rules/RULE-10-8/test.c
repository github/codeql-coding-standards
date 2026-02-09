void testDifferentEssentialType() {
  unsigned int u = 1;
  signed int s = 1;
  (signed int)(u + u);   // NON_COMPLIANT
  (unsigned int)(s + s); // NON_COMPLIANT
  (signed int)(s + s);   // COMPLIANT
  (unsigned int)(u + u); // COMPLIANT

  float f = 1.0;
  float _Complex cf = 1.0;
  (float)(u + u);            // NON_COMPLIANT
  (float _Complex)(u + u);   // NON_COMPLIANT
  (unsigned int)(f + f);     // NON_COMPLIANT
  (unsigned int)(cf + cf);   // NON_COMPLIANT
  (float)(f + f);            // COMPLIANT
  (float)(cf + cf);          // COMPLIANT
  (float _Complex)(f + f);   // COMPLIANT
  (float _Complex)(cf + cf); // COMPLIANT
}

void testWiderType() {
  unsigned short us = 1;
  unsigned int u = 1;

  (unsigned int)(us + us); // NON_COMPLIANT
  (unsigned short)(u + u); // COMPLIANT

  signed short ss = 1;
  signed int s = 1;

  (signed int)(ss + ss); // NON_COMPLIANT
  (signed short)(s + s); // COMPLIANT

  float f32 = 1.0;
  double f64 = 1.0;
  float _Complex cf32 = 1.0;
  double _Complex cf64 = 1.0;

  (float)(f32 + f32);             // COMPLIANT
  (float)(cf32 + cf32);           // COMPLIANT
  (float _Complex)(f32 + f32);    // COMPLIANT
  (float _Complex)(cf32 + cf32);  // COMPLIANT
  (double)(f32 + f32);            // NON_COMPLIANT
  (double)(cf32 + cf32);          // NON_COMPLIANT
  (double _Complex)(f64 + f64);   // COMPLIANT
  (double _Complex)(cf64 + cf64); // COMPLIANT
}