void test_non_main() {
  try {

  } catch (...) { // NON_COMPLIANT - not a main function
  }
}

int main() {
  try {

  } catch (...) { // COMPLIANT - a main function
  }
}