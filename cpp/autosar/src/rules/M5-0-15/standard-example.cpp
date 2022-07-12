template <typename IterType> uint8_t sum_values(IterType iter, IterType end) {
  uint8_t result = 0;
  while (iter != end) {
    result += *iter;
    ++iter; // Compliant by exception
  }
  return result;
}
void my_fn(uint8_t *p1, uint8_t p2[]) {
  uint8_t index = 0;
  uint8_t *p3;
  uint8_t *p4;
  *p1 = 0;
  ++index;
  index = index + 5;
  p1 = p1 + 5; // Non-compliant – pointer increment
  p1[5] = 0;   // Non-compliant – p1 was not declared as array
  p3 = &p1[5]; // Non-compliant – p1 was not declared as array

  p2[0] = 0;     // Compliant
  p2[index] = 0; // Compliant
  p4 = &p2[5];
}
uint8_t a1[16];
uint8_t a2[16];
my_fn(a1, a2);
my_fn(&a1[4], &a2[4]);
uint8_t a[10];
uint8_t *p;

p = a;
*(p + 5) = 0; // Non-compliant
p[5] = 0;     // Compliant
sum_values(&a1[0], &a1[16]);
