#define __STDC_WANT_LIB_EXT1__
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void f1(void) {
  // fopen with a constant path is not a compliant means of creating a
  // temporary file (if we can infer it is a temporary file).
  fopen("/tmp/file", "r");      // NON-COMPLIANT
  fopen("/var/tmp/file", "r");  // NON-COMPLIANT
  fopen("C:\\Temp\\file", "r"); // NON-COMPLIANT
}

void f2(void) {
  char buf[L_tmpnam];
  // tmpnam() doesn't guarantee a unique name and requires extra care to
  // safely open a file with the name it returns.
  tmpnam(buf);
}

void f3(void) {
  // tmpnam_s is not safer than tmpnam, it is just an option to set a size
  // for the buffer. It is not a compliant means of creating a temporary file.
  char buf[400];
  tmpnam_s(buf, sizeof(buf)); // NON-COMPLIANT
}

void f4(void) {
  // Most historical implementations of tmpfile() have a limited number of
  // filenames before recycling them.
  tmpfile(); // NON-COMPLIANT
}

void f5(void) {
  FILE *fp;
  // tmpfile_s doesn't allow the user to specify a directory for the
  // temporary file.
  //
  // An exception is allowed (FIO21-C-EX1) if all targeted implementations
  // create temporary files in secure directories. However, we cannot detect
  // this statically.
  tmpfile_s(fp); // NON-COMPLIANT
}

void f6(void) {
  char path[] = "/tmp-XXXXXX";
  // Some implementations follow BSD 4.3 and generate very predictable names.
  // There is also a race condition between the call to mkstemp and the open
  // that can add a security risk.
  mktemp(path); // NON-COMPLIANT
}

void f7(void) {
  char path[] = "/tmp-XXXXXX";
  // mkstemp is a compliant means of creating a temporary file.
  mkstemp(path); // COMPLIANT
}

#define PATHMAX 256
#define TMPROOT "/tmp/dir/"
#define TMP "tmp/"
void f8(char *basename) {
  // Test that we handle some basic cases of path concatenation.
  char l1[PATHMAX];
  // We treat "/tmp/" as a strong sign of a temporary file.
  snprintf(l1, sizeof(l1), "%s%s", TMPROOT, basename);
  FILE *fd1 = fopen(l1, "r"); // NON-COMPLIANT

  char l2[PATHMAX];
  // Currently we draw the line here, don't report "tmp" without slashes.
  snprintf(l2, sizeof(l2), "/%s%s", TMP, basename);
  FILE *fd2 = fopen(l2, "r"); // NON-COMPLIANT[False negative]
}