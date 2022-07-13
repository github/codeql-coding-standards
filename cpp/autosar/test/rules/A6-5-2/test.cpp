void test_floating_point_loop() {
  for (float f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
}

void test_non_floating_point_loop() {
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
}

void test_loop_with_multiple_loop_counters_declared() {
  for (int i = 0, j = 0; i < j; i++, j++) // NON_COMPLIANT
    ;
}

void test_loop_init_with_multiple_loop_counters_initialized() {
  int i, j;
  for (i = 0, j = 0; i < j; i++, j++) // NON_COMPLIANT
    ;
}