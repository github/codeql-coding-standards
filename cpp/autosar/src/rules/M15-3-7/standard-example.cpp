void f1() {
  try {
    // ...
  }

  catch (int32_t i) {
    // Handle int exceptions
  } catch (...) // catch-all handler
  {
    // Handle all other exception types
  }
}
void f2() {
  try {
    // ...
  } catch (...)
  // catch-all handler
  {
    // Handle all exception types
}
catch ( int32_t i ) // Non-compliant – handler will never be called {}
}