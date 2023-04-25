void f1(int p1) {
  int i = 0;
  switch (p1) { // NON_COMPLIANT
  default:
    break;
  }

  switch (p1) { // NON_COMPLIANT
  case 1:
  default:
    break;
  }

  switch (p1) { // NON_COMPLIANT
  case 1:
  case 2:
  default:
    break;
  }

  switch (p1) { // COMPLIANT
  case 1:
    i++;
  default:
    i = 1;
    break;
  }

  switch (p1) { // COMPLIANT
  case 1:
    i++;
  case 2:
    i = 2;
  default:
    i = 1;
    break;
  }

  switch (p1) { // COMPLIANT
  case 1:
    i++;
  case 2:
    i = 2;
  case 3:
  default:
    i = 1;
    break;
  }
}
