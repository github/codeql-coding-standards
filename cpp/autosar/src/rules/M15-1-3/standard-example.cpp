void f1(void) {
  try {
    throw(42);
  } catch (int32_t i) // int will be handled here first
  {
    if (i > 0) {
      throw; // and then re-thrown - Compliant
    }
  }
}
void g1(void) {
  try {
    f1();
  } catch (int32_t i) {
    // Handle re-throw from f1 ( )
    // after f1's handler has done what it needs
  }
}
void f2(void) {
  throw; // Non-compliant
}
void g2(void) {
  try {
    throw; // Non-compliant

  }

  catch (...) {
    // ...
  }
}