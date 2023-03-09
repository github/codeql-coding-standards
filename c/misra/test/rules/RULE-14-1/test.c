typedef float float32_t;

void test_floating_point_loop() {
  for (float f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
  for (double d = 0.0F; d < 10.0F; d += 0.2F) { // NON_COMPLIANT
  }
  for (float32_t f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
}

void test_non_floating_point_loop() {
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
}