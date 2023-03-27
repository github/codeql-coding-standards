void f();

void f1(int p1) {
  int i;
  int j;
  switch (p1) {
  case 1: // COMPLIANT
    if (i) {
    case 2: // NON_COMPLIANT
      j;
      break;
    }
    break;
  default: // COMPLIANT
    j;
    break;
  }
}

void f2(int p1) {
  int i;
  int j;
  switch (p1) {
  case 1: // COMPLIANT
    if (i) {
      j;
    }
    break;
  case 2: // COMPLIANT
    if (i) {
      j;
    }
  case 3: // COMPLIANT
    if (i) {
      j;
    case 4: // NON_COMPLIANT
      j;
    }
    break;
  default: // COMPLIANT
    j;
    break;
  }
}

void f3(int p1) {

  int i;
  int j;
  switch (p1) {
  case 1: // COMPLIANT
    if (i) {
      j;
    }
    break;
  case 2: // COMPLIANT
    if (i) {
      j;
    }
    break;
  case 3: // COMPLIANT
    if (i) {
      j;
    }
    break;
  default: // COMPLIANT
    j;
    break;
  }
}

void f4(int p1) {
  switch (p1) {
    int i;
    if (i) {
    case 1: // NON_COMPLIANT
      f();
    }
  }
}
