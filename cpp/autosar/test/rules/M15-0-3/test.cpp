// NOTE: These are all compiler errors, so it's not possible to write a test
// case for this query

int test_goto(int x) {

  if (x < 0) {
    // goto x; // NON_COMPLIANT[COMPILER_ERROR] - x is within the body of the
    // try
  } else if (x == 0) {
    // goto y; // NON_COMPLIANT[COMPILER_ERROR] - y is within the body of the
    // catch
  } else if (x > 0) {
    goto z; // COMPLIANT - z is after the try
  }

  try {
  x:
    throw "";
  } catch (...) {
  y:
    throw;
  }
z:
  return 0;
}

int test_switch(int x) {

  switch (x) {
  case 0: // COMPLIANT - outside try-catch
    try {
      // case 1: // NON_COMPLIANT[COMPILER_ERROR] - inside try
      throw "";
    } catch (...) {
      // case 2: // NON_COMPLIANT[COMPILER_ERROR] - inside catch
      throw;
    }
  }
  return 0;
}