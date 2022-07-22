
char *restrict p1;                                             // NON_COMPLIANT
int *restrict p2;                                              // NON_COMPLIANT
void f1(int *restrict p1, int *restrict p2, int *restrict p3); // NON_COMPLIANT
void f2(int *p1, int *p2, int *p3)                             // COMPLIANT
{}
void f3(int p1, float *p2, float *const p3) { // COMPLIANT
}
