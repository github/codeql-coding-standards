void test1(int p1) {
dead_label_1: // NON_COMPLIANT
live_label_1: // COMPLIANT
  int x = 0;
live_label_2: // COMPLIANT
dead_label_2: // NON_COMPLIANT
  int y = 0;
dead_label_3: // NON_COMPLIANT
  int z = 0;

  if (p1 > 1) {
    goto live_label_1;
  }

  // Taking the address of a label is sufficient to make it "live"
  void *label_ptr = &&live_label_2;
}