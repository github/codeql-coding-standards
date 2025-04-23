#define __STDC_WANT_LIB_EXT1__
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void f1(void) {
  // fopen() without the 'x' mode flag is non-compliant when creating a new
  // file.
  FILE *fp = fopen("/tmp/file", "w"); // NON-COMPLIANT
  if (fp) {
    fclose(fp);
  }
}

void f2(void) {
  // fopen() in read mode doesn't require exclusive creation.
  FILE *fp = fopen("/tmp/file", "r"); // COMPLIANT
  if (fp) {
    fclose(fp);
  }
}

void f3(void) {
  // fopen() with the 'x' mode flag ensures exclusive creation.
  FILE *fp = fopen("/tmp/file", "wx"); // COMPLIANT
  if (fp) {
    fclose(fp);
  }
}

void f4(void) {
  // fopen_s() without the 'x' mode flag is non-compliant.
  FILE *fp;
  errno_t res = fopen_s(&fp, "/tmp/file", "w"); // NON-COMPLIANT
  if (res == 0) {
    fclose(fp);
  }
}

void f5(void) {
  // fopen_s() with the 'x' mode flag ensures exclusive creation.
  FILE *fp;
  errno_t res = fopen_s(&fp, "/tmp/file", "wx"); // COMPLIANT
  if (res == 0) {
    fclose(fp);
  }
}

void f6(void) {
  // open() without O_EXCL is non-compliant when creating a new file.
  int fd = open("/tmp/file", O_CREAT | O_WRONLY, 0644); // NON-COMPLIANT
  if (fd != -1) {
    close(fd);
  }
}

void f7(void) {
  // open() with O_EXCL ensures exclusive creation.
  int fd = open("/tmp/file", O_CREAT | O_EXCL | O_WRONLY, 0644); // COMPLIANT
  if (fd != -1) {
    close(fd);
  }
}

void f8(void) {
  // open() without O_CREAT doesn't require exclusive creation.
  int fd = open("/tmp/file", O_WRONLY, 0644); // COMPLIANT
  if (fd != -1) {
    close(fd);
  }
}

void f9(void) {
  // fdopen() can be used with a file descriptor created with O_EXCL.
  int fd = open("/tmp/file", O_CREAT | O_EXCL | O_WRONLY, 0644); // COMPLIANT
  if (fd != -1) {
    FILE *fp = fdopen(fd, "w");
    if (fp) {
      fclose(fp);
    } else {
      close(fd);
    }
  }
}

void f10(void) {
  // fdopen() without O_EXCL is non-compliant when creating a new file.
  int fd = open("/tmp/file", O_CREAT | O_WRONLY, 0644); // NON-COMPLIANT
  if (fd != -1) {
    FILE *fp = fdopen(fd, "w");
    if (fp) {
      fclose(fp);
    } else {
      close(fd);
    }
  }
}

void f11(void) {
  // fdopen() without O_CREAT doesn't require exclusive creation.
  int fd = open("/tmp/file", O_WRONLY, 0644); // COMPLIANT
  if (fd != -1) {
    FILE *fp = fdopen(fd, "w");
    if (fp) {
      fclose(fp);
    } else {
      close(fd);
    }
  }
}