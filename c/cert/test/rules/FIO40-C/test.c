#include <stdbool.h>
#include <stdio.h>
#include <string.h>

char buf[1024];
char buf2[sizeof(buf)];

void f0(FILE *file) {
  // covered by rule ERR33-C
  fgets(buf, sizeof(buf), file); // COMPLIANT
  return;
}

char f1(FILE *file) {
  if (fgets(buf, sizeof(buf), file) == NULL) {
    /*null*/
    f0(file);
    sizeof(buf); // COMPLIANT
  }
  return buf[0]; // NON_COMPLIANT
}

char f2a(FILE *file) {
  if (fgets(buf, sizeof(buf), file) == NULL) {
    /*null*/
    *buf = '\0'; // COMPLIANT
    sizeof(buf); // COMPLIANT
  }
  return buf[0]; // COMPLIANT
}

char f2b(FILE *file) {
  if (fgets(buf, sizeof(buf), file) == 0) {
    /*null*/
    buf[0] = '\0'; // COMPLIANT
    sizeof(buf);   // COMPLIANT
  }
  return buf[0]; // COMPLIANT
}

char f3a(FILE *file) {
  if (fgets(buf, sizeof(buf), file) != NULL) {
    // ...
  } else {
    /*null*/
    strcpy(buf, buf2); // COMPLIANT
  }
  return buf[0]; // COMPLIANT
}

char f3b(FILE *file) {
  if (fgets(buf, sizeof(buf), file)) {
    // ...
  } else {
    /*null*/
  }
  return buf[0]; // NON_COMPLIANT
}

char f3c(FILE *file) {
  if (fgets(buf, sizeof(buf), file) != NULL) {
    // ...
  } else {
    /*null*/
    // resetting a different buffer
    strcpy(buf2, buf); // NON_COMPLIANT
  }
  return buf[0]; // NON_COMPLIANT
}

char f4(FILE *file) {
  if (fgets(buf, sizeof(buf), file)) {
    // ...
  } else {
    /*null*/
    fgets(buf, sizeof(buf), file); // COMPLIANT
  }
  return buf[0]; // COMPLIANT
}

char f4b(FILE *file) {
  if (!(fgets(buf, sizeof(buf), file) == NULL)) {
    // ...
  }
  /*null*/

  return buf[0]; // NON_COMPLIANT
}

char f5a(FILE *file) {
  while (fgets(buf, sizeof(buf), file)) {
    // ...
  }
  /*null*/

  return buf[0]; // NON_COMPLIANT
}
char f5b(FILE *file) {
  while (fgets(buf, sizeof(buf), file) == NULL) {
    /*null*/
  }

  return buf[0]; // COMPLIANT
}

char f6(FILE *file, int input) {
  char *ret = fgets(buf, sizeof(buf), file);
  bool flag = (ret != NULL);
  if (flag) {
    // ...
  } else {
    /*null*/
  }
  return buf[0]; // NON_COMPLIANT
}

char f7(FILE *file, int input) {
  char *ret = fgets(buf, sizeof(buf), file); // COMPLIANT
  bool flag = (ret != NULL);
  if (flag) {
    // ...
  } else {
    /*null*/
    *buf = '\0';
  }
  return buf[0];
}

char f8(FILE *file, int input) {
  char *ret = fgets(buf, sizeof(buf), file);
  bool flag = (ret == NULL);
  if (!(flag || input)) {
    // ...
  } else {
    /*null*/
  }
  return buf[0]; // NON_COMPLIANT
}

void f9(FILE *file, int input) {
  char *ret = fgets(buf, sizeof(buf), file); // COMPLIANT
  bool flag = (ret != NULL);
  if (flag) {
    // ...
  } else {
    /*null*/
    // *buf = '\0';
  }
  // buf is not accessed
  return;
}

// fgets wrapper
static inline char *my_fgets(char *str, int size, FILE *file) {
  char *result;
  result = fgets(str, size, file);
  return result;
}

char f10(FILE *file) {
  if (my_fgets(buf, sizeof(buf), file) == NULL)
    memcpy(buf, buf2, sizeof(buf));
  return buf[0]; // COMPLIANT
}

char f11(FILE *file, bool cond) {
  if (cond && fgets(buf, sizeof(buf), file) == NULL)
    /*null*/
    fprintf(stderr, "EOF error.\n");
  return '\0'; // COMPLIANT
}
char f12(FILE *file, bool cond) {
  if (cond && fgets(buf, sizeof(buf), file) == NULL)
    /*null*/
    fprintf(stderr, "Error.\n");
  return buf[0]; // NON_COMPLIANT
}

char f13(FILE *file) {
  while (true) {
    if (!fgets(buf, sizeof buf, file)) {
      /*null*/
      break;
    }
    return buf[0]; // COMPLIANT
  }
  return '\0'; // COMPLIANT
}

char f14(FILE *file) {
  while (true) {
    if (!fgets(buf, sizeof buf, file)) {
      /*null*/
      break;
    }
  }
  return buf[0]; // NON_COMPLIANT
}

char f15(FILE *file) {
  while (1) {
    char *key = fgets(buf, sizeof(buf), file);
    if (key == NULL || strlen(buf) >= (sizeof(buf) - 1))
      break;
  }
  /*null*/
  return buf[0]; // NON_COMPLIANT
}

char f16(FILE *file) {
  if (!fgets(buf, sizeof(buf), file) || strcmp(buf, "end\n")) {
    /*null*/
    return buf[0]; // NON_COMPLIANT
  }
  return 0; // COMPLIANT
}

char f17(FILE *file) {
  if (!fgets(buf, sizeof(buf), file) || strcmp(buf, "end\n")) {
    /*null*/
    strcpy(buf, buf2);
    return buf[0]; // COMPLIANT
  }
  return 0; // COMPLIANT
}
