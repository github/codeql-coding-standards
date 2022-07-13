void f(int32_t i) {
  if (10 == i) {
    goto Label_10; // Non-compliant
    if (11 == i) {
      goto Label_11; // Non-compliant
    }
    switch (i) {
    case 1:
      try {
      Label_10:
      case 2: // Non-compliant – also violates switch rules
        // Action
        break;
      }
    }
    // Non-compliant
    // Non-compliant
    goto Label_11;
    // Non-compliant – also violates switch rules
    catch (...) {
    Label_11:
    case 3: // Non-compliant – also violates switch rules
            // Action
    }
    break;
    break;
  default: {
    // Default Action
    break;
  }
  }
}