const int16_t x = 19; // Compliant
const int16_t y = 21; // Non-compliant
void usedonlyonce(void) {
  int16_t once_1 = 42; // Non-compliant
  int16_t once_2;
  once_2 = x; // Non-compliant
}