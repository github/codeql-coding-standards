int f1(int i) {
  int j = 0;

  { int k; }

  if ((i % 2) == 0) {
    while (j < (2 * i + 1)) {
      j++;
    }
  } else {
    for (int k = 0; k < 2 * i; k++) {
      j++;
    }
  }
  return j;
}

int f2(int i) {
  int j = 0;

  { int k; }

  if ((i % 2) == 0) {
    while (j < (2 * i + 1)) {
      j++;
    }
  } else {
    for (int k = 0; k < 2 * i; k++) {
      j++;
    }
  }
  return j;
}