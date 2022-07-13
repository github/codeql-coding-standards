void test_rethrow_outside_catch() {
  throw; // NON_COMPLIANT - re-throw outside try-catch

  try {
  } catch (...) {
    throw; // COMPLIANT - re-throw allowed inside catch block
  }
}