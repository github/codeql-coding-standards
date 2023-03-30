
void f1(int p1) {

  switch (p1) // COMPLIANT
  {
  case 1:
    break;
  case 2:
    break;
  default:
    break;
  }
}

void f2(int p1) {
  switch (p1 == 1) // NON_COMPLIANT
  {
  case 0:
    break;
  case 1:
    break;
  default:
    break;
  }
}

void f3(char *p1) {
  switch (p1 == "CODEQL") // NON_COMPLIANT
  {
  case 0:
    break;
  case 1:
    break;
  default:
    break;
  }
}