#include <stdbool.h>
#include <stdio.h>

char buf[1024];

void f0(FILE *file) {
  if (fgets(buf, sizeof(buf), file)) {
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}

void f1(FILE *file) {
  if (!fgets(buf, sizeof(buf), file)) {
    /*null*/
  } else {
    /*notNull*/
  }
  return;
}

void f2(FILE *file) {
  if (fgets(buf, sizeof(buf), file) == 0) {
    /*null*/
  } else {
    /*notNull*/
  }
  return;
}

void f3(FILE *file) {
  if (fgets(buf, sizeof(buf), file) != 0) {
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}

void f4(FILE *file) {
  if (!(fgets(buf, sizeof(buf), file) == 0)) {
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}
char *f4a(FILE *file) {
  if (!(fgets(buf, sizeof(buf), file) == NULL)) {
    /*notNull*/
  } else {
    /*null*/
  }
  return buf; // NON_COMPLIANT
}

char *f4b(FILE *file) {
  if (!(fgets(buf, sizeof(buf), file) == NULL)) {
    /*notNull*/
  }
  /*notNull*/
  /*null*/

  return buf; // NON_COMPLIANT
}

char *f4c(FILE *file) {
  if ((fgets(buf, sizeof(buf), file) != NULL)) {
    /*notNull*/
  } else {
    /*null*/
  }
  return buf; // NON_COMPLIANT
}

char *f4d(FILE *file) {
  if ((fgets(buf, sizeof(buf), file) != NULL)) {
    /*notNull*/
  }
  /*null*/
  return buf; // NON_COMPLIANT
}

void f5(FILE *file) {
  if (!(fgets(buf, sizeof(buf), file) != 0)) {
    /*null*/
  } else {
    /*notNull*/
  }
  return;
}

void f6(FILE *file) {
  char *ret = fgets(buf, sizeof(buf), file);
  bool flag = (ret == NULL);
  if (flag) {
    /*null*/
  } else {
    /*notNull*/
  }
  return;
}

void f7(FILE *file) {
  char *ret = fgets(buf, sizeof(buf), file);
  bool flag = (ret == NULL);
  if (!flag) {
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}

void f8(FILE *file, bool cond) {
  if (fgets(buf, sizeof(buf), file) == NULL || /*notNull*/ cond) {
    /*null*/
    /*notNull*/
  } else {
    /*notNull*/
  }
  return;
}

void f9a(FILE *file, bool cond) {
  if (fgets(buf, sizeof(buf), file) != NULL || /*null*/ cond) {
    /*null*/
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}

void f9b(FILE *file, bool cond) {
  if (cond || fgets(buf, sizeof(buf), file) != NULL) {
    /*notNull*/
  } else {
    /*null*/
  }
  return;
}

void f9c(FILE *file, bool cond) {
  if (cond || fgets(buf, sizeof(buf), file) == NULL) {
    /*null*/
  } else {
    /*notNnull*/
  }
  return;
}

void f10(FILE *file, bool cond) {
  if (fgets(buf, sizeof(buf), file) == NULL && /*null*/ cond) {
    /*null*/
  } else {
    /*null*/
    /*notNull*/
  }
  return;
}

void f11a(FILE *file, bool cond) {
  if (fgets(buf, sizeof(buf), file) != NULL && /*notNull*/ cond) {
    /*notNull*/
  } else {
    /*null*/
    /*notNull*/
  }
  return;
}

void f11b(FILE *file, bool cond) {
  if (cond && fgets(buf, sizeof(buf), file) == NULL) {
    /*null*/
    fprintf(stderr, "Read error or end of file.\n");
  } else {
    /*notNull*/
    fprintf(stderr, "Read OK.\n");
  }
  return;
}

void f11c(FILE *file, bool cond) {
  if (cond && fgets(buf, sizeof(buf), file) != NULL) {
    /*notNull*/
    fprintf(stderr, "Read error or end of file.\n");
  } else {
    /*null*/
    fprintf(stderr, "Read OK.\n");
  }
  return;
}