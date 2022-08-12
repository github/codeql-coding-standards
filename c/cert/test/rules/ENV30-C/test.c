#include <locale.h>
#include <stdlib.h>
#include <string.h>

void trstr(char *c_str, char orig, char rep) {
  while (*c_str != '\0') {
    if (*c_str == orig) {
      *c_str = rep; // NON_COMPLIANT
    }
    ++c_str;
  }
}

void f1(void) {
  char *env1 = getenv("TEST_ENV");
  char *copy_of_env;
  copy_of_env = env1; // COMPLIANT

  if (env1 == NULL) {
  }
  trstr(env1, '"', '_');
}

void f2(void) {
  const char *env2;
  char *copy_of_env;

  env2 = getenv("TEST_ENV");
  if (env2 == NULL) {
  }

  copy_of_env = (char *)malloc(strlen(env2) + 1);
  if (copy_of_env == NULL) {
  }

  strcpy(copy_of_env, env2);
  trstr(copy_of_env, '"', '_'); // COMPLIANT
}

void f3(void) {
  const char *env3;
  char *copy_of_env;

  env3 = getenv("TEST_ENV");
  if (env3 == NULL) {
  }

  copy_of_env = strdup(env3);
  if (copy_of_env == NULL) {
  }

  trstr(copy_of_env, '"', '_'); // COMPLIANT
  if (setenv("TEST_ENV", copy_of_env, 1) != 0) {
  }
}

void f4(void) {
  struct lconv *conv4 = localeconv();

  setlocale(LC_ALL, "C"); // COMPLIANT
  conv4 = localeconv();   // COMPLIANT

  if ('\0' == conv4->decimal_point[0]) {
    conv4->decimal_point = "."; // NON_COMPLIANT
  }
}

void f4alias(void) {
  struct lconv *conv4 = localeconv();
  struct lconv *conv = conv4;

  if ('\0' == conv4->decimal_point[0]) {
    conv->decimal_point = "."; // NON_COMPLIANT
  }
}

void f5(void) {
  const struct lconv *conv5 = localeconv();
  if (conv5 == NULL) {
  }

  struct lconv *copy_of_conv = (struct lconv *)malloc(sizeof(struct lconv));
  if (copy_of_conv == NULL) {
  }

  memcpy(copy_of_conv, conv5, sizeof(struct lconv));

  if ('\0' == copy_of_conv->decimal_point[0]) {
    copy_of_conv->decimal_point = "."; // COMPLIANT
  }

  free(copy_of_conv);
}