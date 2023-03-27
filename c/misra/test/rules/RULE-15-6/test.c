void f1();

void f2(int p1) {
  while (p1) // NON_COMPLIANT
    f1();

  while (p1) // NON_COMPLIANT
    ;
  f1();

  for (int i = 0; i < p1; i++) // NON_COMPLIANT
    f1();

  while (p1)
    ;
  { // NON_COMPLIANT
    ;
  }

  while (p1) { // COMPLIANT
    ;
  }
  for (int i = 0; i < p1; i++) { // COMPLIANT
    ;
  }
}

void f3(int p1) {
  if (p1) // NON_COMPLIANT
    ;
  else
    ;

  if (p1) // NON_COMPLIANT
    ;
  else if (p1) // NON_COMPLIANT
    if (p1)    // NON_COMPLIANT

      if (p1) { // COMPLIANT
        ;
      }

  if (p1) { // COMPLIANT
    ;
  } else { // COMPLIANT
    ;
  }

  if (p1) { // COMPLIANT
    ;
  } else if (p1) { // COMPLIANT
    ;
  } else { // COMPLIANT
    ;
  }
}

void f4(int p1) {

  switch (p1) { // COMPLIANT
  case 0:
    while (p1) {
      ;
    }
    break;
  case 1:
    if (p1) {
      ;
    }
    break;
  default:
    break;
  }

  switch (p1) // NON_COMPLIANT
  case 0:
    while (p1) {
      ;
    }
}