#include <stdio.h>

void f1(const char *file) {
  FILE *f = fopen(file, "r"); // NON_COMPLIANT
  if (NULL != f) {
    /* File exists, handle error */
  } else {
    if (fclose(f) == EOF) {
      /* Handle error */
    }
    f = fopen(file, "w");
    if (NULL == f) {
      /* Handle error */
    }

    /* Write to file */
    if (fclose(f) == EOF) {
      /* Handle error */
    }
  }
}

void f2(const char *file) {
  FILE *f = fopen(file, "wx"); // COMPLIANT
  if (NULL == f) {
    /* Handle error */
  }
  /* Write to file */
  if (fclose(f) == EOF) {
    /* Handle error */
  }
}

#include <fcntl.h>
#include <unistd.h>

void f3(const char *file) {
  int fd = open(file, O_CREAT | O_EXCL | O_WRONLY);
  if (-1 != fd) {
    FILE *f = fdopen(fd, "w"); // COMPLIANT
    if (NULL != f) {
      /* Write to file */

      if (fclose(f) == EOF) {
        /* Handle error */
      }
    } else {
      if (close(fd) == -1) {
        /* Handle error */
      }
    }
  }
}

#include <sys/stat.h>

int f4(char *filename, int flags) {
  struct stat lstat_info;
  struct stat fstat_info;
  int f;

  if (lstat(filename, &lstat_info) == -1) {
    /* File does not exist, handle error */
  }

  if (!S_ISREG(lstat_info.st_mode)) {
    /* File is not a regular file, handle error */
  }

  if ((f = open(filename, flags)) == -1) { // COMPLIANT
    /* File has disappeared, handle error */
  }

  if (fstat(f, &fstat_info) == -1) {
    /* Handle error */
  }

  if (lstat_info.st_ino != fstat_info.st_ino ||
      lstat_info.st_dev != fstat_info.st_dev) {
    /* Open file is not the expected regular file, handle error */
  }

  /* f is the expected regular open file */
  return f;
}

void f5(const char *file) {
  FILE *f = fopen("file", "r"); // NON_COMPLIANT
  if (NULL != f) {
    /* File exists, handle error */
  } else {
    if (fclose(f) == EOF) {
      /* Handle error */
    }
    f = fopen("file", "w");
    if (NULL == f) {
      /* Handle error */
    }

    /* Write to file */
    if (fclose(f) == EOF) {
      /* Handle error */
    }
  }
}

void f6(const char *file) {
  int readChar;
  FILE *f = fopen(file, "r"); // COMPLIANT
  // the file is accessed
  if (NULL != f) {
    /* File exists, handle error */
  } else {
    // read file
    readChar = fgetc(f);
    printf("%c", readChar);
  }

  f = fopen(file, "w");
}