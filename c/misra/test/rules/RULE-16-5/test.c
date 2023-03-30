void f1(int p1) {
  int i;
  int j;
  switch (p1) {
  default: // COMPLIANT
    i++;
    break;
  case 1:
    j++;
    break;
  }
  switch (p1) {
  case 1:
    i++;
    break;
  default: // NON_COMPLIANT
    j++;
    break;
  case 2:
    i++;
    break;
  }
  switch (p1) {
  case 1:
    i++;
    break;
  case 2:
    j++;
    break;
  default: // COMPLIANT
    i++;
    break;
  }
}
