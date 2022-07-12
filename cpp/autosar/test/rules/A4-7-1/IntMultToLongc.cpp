long long f(short x, int y, long long z) {
  y == x *x;               // COMPLIANT
  y == x *(int)x;          // COMPLIANT
  z == y *x;               // NON_COMPLIANT
  z == (long long)(y * x); // we assume the user knows what they are doing
  if (x == 56)
    return y * y; // NON_COMPLIANT
  if (x == 56)
    return (long long)(y * y); // we assume the user knows what they are doing
  return 42 * 23;              // COMPLIANT
}

void int_float(int i, int j, long long ll, float f, float g, double h, char c) {
  // note: where cases are marked as 'dubious' that means there could be an
  // overflow,
  //       but the target type does not imply that the developer anticipates one
  //       as with an int -> long long conversion.  We should therefore not flag
  //       these cases.

  double v1_1 = f * g;         // NON_COMPLIANT (float -> double)
  double v1_2 = f * (double)g; // COMPLIANT

  double v2_1 = (i + j) * f; // NON_COMPLIANT (float -> double)
  double v2_2 = (i + j)      // NON_COMPLIANT
                * (double)f; // COMPLIANT

  double v3_1 = i * j;            // dubious (int -> double)
  double v3_2 = (double)i * j;    // COMPLIANT
  double v3_3 = (long long)i * j; // COMPLIANT

  float v4_1 = i * j;        // dubious (int -> float)
  float v4_2 = i * (float)j; // COMPLIANT

  long long v5_1 = f * g;            // COMPLIANT (float -> long long)
  long long v5_2 = f * (long long)g; // COMPLIANT
  long long v5_3 = (long long)f * (long long)g; // COMPLIANT

  int v6_1 = f * g;      // COMPLIANT (float -> int)
  int v6_2 = (int)f * g; // COMPLIANT

  double v7_1 = f * f;   // NON_COMPLIANT (float -> double)
  double v7_2 = h * h;   // COMPLIANT
  double v7_3 = (f * f); // NON_COMPLIANT[FALSE_NEGATIVE] (float -> double)

  float v8_1 =
      f * f * 2.0; // dubious (float -> double -> float)
                   // ^ though 2.0 is strictly speaking a double, it's unlikely
                   // the author anticipates requiring a double here
  float v8_2 = f * f * 2.0f; // COMPLIANT (float -> float)

  float v9_1 = f * 2.0 * f;  // dubious (float -> double -> float)
  float v9_2 = f * 2.0f * f; // COMPLIANT (float -> float)

  float v10_1 = 2.0 * f * f;  // dubious (float -> double -> float)
  float v10_2 = 2.0f * f * f; // COMPLIANT (float -> float)

  float v11_1 = (2.0 * 2.0) * f;   // COMPLIANT (one argument is const)
  float v11_2 = (2.0f * 2.0f) * f; // COMPLIANT

  float v12_1 = 1.0 + f * f + f * f;  // dubious (float -> double -> float)
  float v12_2 = 1.0f + f * f + f * f; // COMPLIANT

  double v13_1 = f * f * 2.0; // NON_COMPLIANT[FALSE_NEGATIVE] (float -> double)
  double v13_2 = f * f * 2.0f; // NON_COMPLIANT (float -> double)

  long long v14_1 = i * (i + 2) + ll;        // NON_COMPLIANT (int -> long long)
  long long v14_2 = i * (i + 2ll) * ll;      // COMPLIANT
  long long v14_3 = i * (i + (int)2ll) + ll; // NON_COMPLIANT (int -> long long)
}

typedef unsigned long long size_t;
void *malloc(size_t size);

void use_size_t(int W, int H) {
  int x = 10;
  int y = 20;
  const int vs[] = {10, 20};

  malloc(W * H);                 // NON_COMPLIANT (int -> size_t)
  malloc((size_t)W * (size_t)H); // COMPLIANT

  malloc(10 * 20);       // COMPLIANT (small values)
  malloc(x * y);         // COMPLIANT (small values)
  malloc(vs[0] * vs[1]); // COMPLIANT (small values)
}

int printf(const char *format, ...);

void use_printf(float f, double d) {
  printf("%f",
         f * f); // COMPLIANT (float -> double)
                 // ^ there's a float -> double varargs promotion here, but it's
                 // unlikely that the author anticipates requiring a double
  printf("%f", d * d); // COMPLIANT
}

size_t three_chars(unsigned char a, unsigned char b, unsigned char c) {
  return a * b * c; // at most 16581375
}

void g(unsigned char uchar1, unsigned char uchar2, unsigned char uchar3,
       int i) {
  unsigned long ulong1, ulong2, ulong3, ulong4, ulong5;
  ulong1 = (uchar1 + 1) * (uchar2 + 1);                // COMPLIANT
  ulong2 = (i + 1) * (uchar2 + 1);                     // NON_COMPLIANT
  ulong3 = (uchar1 + 1) * (uchar2 + 1) * (uchar3 + 1); // COMPLIANT

  ulong4 = (uchar1 + (uchar1 + 1)) * (uchar2 + 1); // COMPLIANT
  ulong5 = (i + (uchar1 + 1)) * (uchar2 + 1);      // NON_COMPLIANT

  ulong5 = (uchar1 + 1073741824) * uchar2; // NON_COMPLIANT[FALSE_NEGATIVE]
  ulong5 = (uchar1 + (1 << 30)) * uchar2;  // NON_COMPLIANT[FALSE_NEGATIVE]
  ulong5 = uchar1 * uchar1 * uchar1 * uchar2 * uchar2 *
           uchar2;                           // NON_COMPLIANT[FALSE_NEGATIVE]
  ulong5 = (uchar1 + (unsigned short)(-1)) * // NON_COMPLIANT
           (uchar2 + (unsigned short)(-1));
}

struct A {
  short s;
  int i;
};

void g2(struct A *a, short n) {
  unsigned long ulong1, ulong2;
  ulong1 = (a->s - 1) * ((*a).s + 1); // COMPLIANT
  ulong2 = a->i * (*a).i;             // NON_COMPLIANT
}

int global_i;
unsigned char global_uchar;
void g3() {
  unsigned long ulong1, ulong2;
  ulong1 = global_i * global_i;    // NON_COMPLIANT
  ulong2 = (global_uchar + 1) * 2; // COMPLIANT
}