void f1(int p1) {

  if (p1) { // COMPLIANT
    ;
  } else if (p1) {
    ;
  } else {
    ;
  }
}

void f2(int p1) {
  if (p1) { // COMPLIANT
    ;
  }
  if (p1) { // NON_COMPLIANT
    ;
  } else if (p1) {
    ;
  }
}

void f3(int p1) {

  if (p1) { // COMPLIANT
    ;
  } else {
    ;
  }
  if (p1) { // COMPLIANT
    ;
  } else if (p1) {
    if (p1) { // NON_COMPLIANT
      ;
    } else if (p1) {
      ;
    }
  } else {
    ;
  }
}

void f4(int p1) {

  if (p1) { // NON_COMPLIANT
    ;
  } else if (p1) {
    if (p1) { // COMPLIANT
      ;
    } else if (p1) {
      ;
    } else {
      ;
    }
  }
}