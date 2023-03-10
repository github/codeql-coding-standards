void f1(int p1) {
  int i;
  int j;
  switch (p1) {
  case 1: // COMPLIANT
    break;
  case 2: // COMPLIANT
  case 3: // COMPLIANT
  case 4: // COMPLIANT
    break;
  case 5: // NON_COMPLIANT
    i = j;
    j++;
  case 6: // NON_COMPLIANT
    if (i > j) {
      j++;
      i++;
      break;
    }
  case 7: // COMPLIANT
    if (i > j) {
      j++;
      i++;
    }
    break;
  default: // NON_COMPLIANT
    i++;
  }
}

void f2(int p1) {
  switch (p1) {
  case 1: // COMPLIANT
    break;
  case 2:  // COMPLIANT
  case 3:  // COMPLIANT
  case 4:  // COMPLIANT
  default: // COMPLIANT
    break;
  }
}

void f3(int p1) {
  switch (p1) {
  default: // NON_COMPLIANT
    p1++;
  case 1: // COMPLIANT
    break;
  }
}
