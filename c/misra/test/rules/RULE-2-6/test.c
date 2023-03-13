void test1(int p1) {
dead_label_1: // NON_COMPLIANT
live_label_1: // COMPLIANT
  p1 + 1;
live_label_2: // COMPLIANT
dead_label_2: // NON_COMPLIANT
  p1 + 2;
dead_label_3: // NON_COMPLIANT
  p1 + 3;

  if (p1 > 1) {
    goto live_label_1;
  }

  // Taking the address of a label is sufficient to make it "live"
  void *label_ptr = &&live_label_2;
}