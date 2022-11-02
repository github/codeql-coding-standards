int id1;

void f1() {
  int id1; // NON_COMPLIANT
}

void f2(int id1) {} // NON_COMPLIANT

void f3() {
  for (int id1; id1 < 1; id1++) { // NON_COMPLIANT
    for (int id1; id1 < 1; id1++) {
    } // NON_COMPLIANT
  }
}

struct astruct {
  int id1;
};

extern void g(struct astruct *p);

int id2 = 0;

void f4(struct astruct id2) { // NON_COMPLIANT
  g(&id2);
}

void f5(struct astruct id3) { // COMPLIANT
  g(&id2);
}