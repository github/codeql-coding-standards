void f1(int p1) {
  int i;
  int j;
  switch (p1) { // NON COMPLIANT
  case 1:
    i++;
    j++;
    break;
  case 2:
  case 3:
    break;
  }
  switch (p1) { // NON_COMPLIANT
  case 1:
    i++;
    break;
  case 2:
    j++;
    break;
  default:
    break;
  }
  switch (p1) { // COMPLIANT
  case 1:
    i++;
    break;
  case 2:
    j++;
    break;
  default:
    // codeql
    break;
  }

  switch (p1) { // COMPLIANT
  case 1:
    i++;
    break;
  default:
    j++;
    break;
  }
  switch (p1) { // COMPLIANT
  case 1:
    i++;
    break;
  default:
    j++;
    i++;
    break;
  }

  switch (p1) { // NON_COMPLIANT
  case 1:
    i++;
    break;
  default: {
    break;
  }
  }
}
