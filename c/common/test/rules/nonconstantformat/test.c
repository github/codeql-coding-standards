#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

void f1(const char *user) {
  int ret;
  static const char msg_format[] = "Hello %s.";
  size_t len = strlen(user) + sizeof(msg_format);
  char *msg = (char *)malloc(len);
  ret = snprintf(msg, len, msg_format, user);
  fprintf(stderr, msg); // NON_COMPLIANT
  free(msg);
}

void f2(const char *user) {
  int ret;
  static const char msg_format[] = "Hello %s.";
  size_t len = strlen(user) + sizeof(msg_format);
  char *msg = (char *)malloc(len);
  ret = snprintf(msg, len, msg_format, user);
  fputs(msg, stderr); // COMPLIANT
  free(msg);
}

void f3(const char *user) {
  static const char msg_format[] = "Hello %s.";
  fprintf(stderr, msg_format, user); // COMPLIANT
}

// POSIX //
void f4(const char *user) {
  int ret;
  static const char msg_format[] = "Hello %s.";
  size_t len = strlen(user) + sizeof(msg_format);
  char *msg = (char *)malloc(len);
  ret = snprintf(msg, len, msg_format, user);
  syslog(LOG_INFO, msg); // NON_COMPLIANT
  free(msg);
}

void f5(const char *user) {
  static const char msg_format[] = "Hello %s.";
  syslog(LOG_INFO, msg_format, user); // COMPLIANT
}
