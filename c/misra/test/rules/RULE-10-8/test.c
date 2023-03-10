void testDifferentEssentialType() {
  unsigned int u = 1;
  signed int s = 1;
  (signed int)(u + u);   // NON_COMPLIANT
  (unsigned int)(s + s); // NON_COMPLIANT
  (signed int)(s + s);   // COMPLIANT
  (unsigned int)(u + u); // COMPLIANT
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
}