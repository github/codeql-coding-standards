#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
int f1a(const char *filename) {
  FILE *f = fopen(filename, "r"); // NON_COMPLIANT
  if (NULL == f) {
    return -1;
  }
  /* ... */
  return 0;
}

int f1b(const char *filename) {
  FILE *f = freopen(filename, "w+", stdout); // NON_COMPLIANT
  if (NULL == f) {
    return -1;
  }
  /* ... */
  return 0;
}

void f1c(const char *filename) {
  FILE *f = freopen(filename, "w+", stdout); // NON_COMPLIANT
  if (NULL == f) {
    return;
  }
  /* ... */
  // FILE* out of scope not closed
}

int f2a(const char *filename) {
  FILE *f = fopen(filename, "r"); // COMPLIANT
  if (NULL == f) {
    return -1;
  }
  /* ... */
  if (fclose(f) == EOF) {
    return -1;
  }
  return 0;
}

int f2b(const char *filename) {
  FILE *f = fopen(filename, "r"); // NON_COMPLIANT
  if (NULL == f) {
    return -1;
  }
  if (filename) {
    if (fclose(f) == EOF) {
      return -1;
    }
  }
  // file not closed on this path
  return 0;
}

// scope prolonged
int f2c(const char *filename) {
  FILE *g;
  {
    FILE *f = fopen(filename, "r"); // COMPLIANT
    if (NULL == f) {
      return -1;
    }
    /* ... */
    g = f;
    // f out of scope
  }
  if (fclose(g) == EOF) {
    return -1;
  }
  return 0;
}

// interprocedural
int closing_helper(FILE *g) {
  if (fclose(g) == EOF) {
    return -1;
  }
  return 0;
}
int f2inter(const char *filename) {
  FILE *f = fopen(filename, "r"); // COMPLIANT[FALSE_POSITIVE]
  if (NULL == f) {
    return -1;
  }
  return closing_helper(f);
}

int f2cfg(const char *filename) {
  FILE *f = freopen(filename, "r", stdout); // NON_COMPLIANT
  if (NULL == f) {
    return -1;
  }
  if (filename) {
    if (fclose(f) == EOF) {
      return -1;
    }
  }
  // file not closed on one path
  return 0;
}

int f3(const char *filename) {
  FILE *f = fopen(filename, "w"); // NON_COMPLIANT
  if (NULL == f) {
    exit(EXIT_FAILURE);
  }
  /* ... */
  exit(EXIT_SUCCESS);
}

int f4(const char *filename) {
  FILE *f = fopen(filename, "w"); // COMPLIANT
  if (NULL == f) {
    /* Handle error */
  }
  /* ... */
  if (fclose(f) == EOF) {
    /* Handle error */
  }
  exit(EXIT_SUCCESS);
}

int f5(const char *filename) {
  int fd = open(filename, O_RDONLY, S_IRUSR); // NON_COMPLIANT
  if (-1 == fd) {
    return -1;
  }
  /* ... */
  return 0;
}

int f6(const char *filename) {
  int fd = open(filename, O_RDONLY, S_IRUSR); // COMPLIANT
  if (-1 == fd) {
    return -1;
  }
  /* ... */
  if (-1 == close(fd)) {
    return -1;
  }
  return 0;
}
