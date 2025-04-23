#include <unistd.h>

void use_str(char *buf);

void f1() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf)); // NON-COMPLIANT
  buf[len] = '\0';                                   // NON-COMPLIANT
}

void f2() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT
  // NON-COMPLIANT: buffer not null-terminated
}

void f3() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  buf[len] = '\0'; // NON-COMPLIANT: not guarded by error check
}

void f4() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  if (len == -1) {
    return;
  }

  use_str(buf); // NON-COMPLIANT: buf is not null-terminated
}

void f5() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  if (len != -1) {
    buf[len] = '\0'; // COMPLIANT
  }
}

void f6() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  buf[len] = '\0'; // NON-COMPLIANT: len may be -1
  if (len != -1) {
    return;
  }

  use_str(buf);
}

void f7() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  if (len < 10) {
    if (len != -1) {
      buf[len] = '\0';
    }
  }

  use_str(buf); // NON-COMPLIANT: Null termination doesn't dominate use
}

void f8() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  use_str(buf); // NON-COMPLIANT: buf used before null-termination
  if (len == -1) {
    return;
  }

  buf[len] = '\0';
}

void f9() {
  char buf[1024];
  ssize_t len = readlink("/file", buf, sizeof(buf) - 1); // COMPLIANT

  if (len >= 0) {
    buf[len] = '\0'; // COMPLIANT
  }
}

void f10(char *buf, int size) {
  ssize_t len = readlink(
      "/file", buf, size); // NON-COMPLIANT: The size likely should be size - 1
}