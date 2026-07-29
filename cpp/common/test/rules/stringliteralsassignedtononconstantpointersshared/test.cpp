const char *a1 = "CodeQL";
char *a2 = "CodeQL"; // NON_COMPLIANT
char a3[] = "CodeQL";
char a4[7] = "CodeQL";
const char a5[] = "CodeQL";
const char a6[7] = "CodeQL";

void f1() {
  const char *fa1 = "CodeQL";
  char *fa2 = "CodeQL"; // NON_COMPLIANT
  char fa3[] = "CodeQL";
  char fa4[7] = "CodeQL";
  const char fa5[] = "CodeQL";
  const char fa6[7] = "CodeQL";

  const char *f7 = "CodeQL1";

  f7 = "CodeQL2";

  char *f8 = "CodeQL1"; // NON_COMPLIANT
  f8 = "CodeQL2";       // NON_COMPLIANT
}
