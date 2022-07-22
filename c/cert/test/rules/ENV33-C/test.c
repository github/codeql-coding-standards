typedef struct _FILE FILE;
#define NULL (void *)0

int system(const char *);
void abort(void);
FILE *popen(const char *, const char *);

void f1(const char *p1) {
  FILE *l1;
  system(p1); // NON_COMPLIANT
  abort();
  l1 = popen("ls *", "r"); // NON_COMPLIANT
}

void f2() {
  const int *l1 = NULL;

  system(0);         // COMPLIANT
  system(NULL);      // COMPLIANT
  system(l1);        // NON_COMPLIANT
  system("ls -la");  // NON_COMPLIANT
  popen(NULL, NULL); // NON_COMPLIANT
}
