int g1 = 0;

unsigned char g2[sizeof(g1++)]; // NON_COMPLIANT

void f1(int p);
void f2(long long p);

#define m1(x)                                                                  \
  do {                                                                         \
    if (sizeof(x) == sizeof(int)) {                                            \
      f1(x);                                                                   \
    } else {                                                                   \
      f2(x);                                                                   \
    }                                                                          \
  } while (0)

void f3() { m1(g1++); } // COMPLIANT
