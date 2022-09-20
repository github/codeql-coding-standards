#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void f1(void) {
  char *tmpvar;
  char *tempvar;

  tmpvar = getenv("TMP");
  if (!tmpvar) {
    /* Handle error */
  }
  tempvar = getenv("TEMP");
  if (!tempvar) {
    /* Handle error */
  }
  if (strcmp(tmpvar, tempvar) == 0) { // NON_COMPLIANT
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
}

void f2(void) {
  char *tmpvar;
  char *tempvar;

  const char *temp = getenv("TMP");
  if (temp != NULL) {
    tmpvar = (char *)malloc(strlen(temp) + 1);
    if (tmpvar != NULL) {
      strcpy(tmpvar, temp);
    } else {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  temp = getenv("TEMP");
  if (temp != NULL) {
    tempvar = (char *)malloc(strlen(temp) + 1);
    if (tempvar != NULL) {
      strcpy(tempvar, temp);
    } else {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  if (strcmp(tmpvar, tempvar) == 0) { // COMPLIANT
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  free(tempvar);
}

#define __STDC_WANT_LIB_EXT1__ 1

void f3(void) {
  char *tmpvar;
  char *tempvar;

  const char *temp = getenv("TMP");
  if (temp != NULL) {
    tmpvar = strdup(temp);
    if (tmpvar == NULL) {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  temp = getenv("TEMP");
  if (temp != NULL) {
    tempvar = strdup(temp);
    if (tempvar == NULL) {
      /* Handle error */
    }
  } else {
    /* Handle error */
  }

  if (strcmp(tmpvar, tempvar) == 0) { // COMPLIANT
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  tmpvar = NULL;
  free(tempvar);
  tempvar = NULL;
}

void f4(void) {
  char *temp = getenv("VAR1");
  printf(temp);
  temp = getenv("VAR2");
  printf(temp); // COMPLIANT
}

void f5(void) {
  const char *envVars[] = {
      "v1",
      "v2",
      "v3",
  };
  for (int i = 0; i < 3; i++) {
    char *temp = getenv(envVars[i]);
    printf(temp); // COMPLIANT
  }
}

void f5b(void) {
  const char *envVars[] = {
      "v1",
      "v2",
      "v3",
  };
  char *temp;
  char *tmp;
  for (int i = 0; i < 3; i++) {
    temp = getenv(envVars[i]);
    tmp = getenv(envVars[i]);
  }

  if (strcmp(temp, tmp) == 0) { // NON_COMPLIANT
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
}

void f6(void) {
  const char *envVars[] = {
      "v1",
      "v2",
      "v3",
  };
  char *temp[3];
  for (int i = 0; i < 3; i++) {
    temp[i] = getenv(envVars[i]);
  }
  printf(temp[0]); // NON_COMPLIANT[FALSE_NEGATIVE]
}

char *tmpvar_global;
char *tempvar_global;
void f7(void) {
  tmpvar_global = getenv("TMP");
  if (!tmpvar_global) {
    /* Handle error */
  }
  tempvar_global = getenv("TEMP");
  if (!tempvar_global) {
    /* Handle error */
  }
  if (strcmp(tmpvar_global, tempvar_global) == 0) { // NON_COMPLIANT
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
}

extern void f8fun();
void f8(void) {
  char *temp = getenv("VAR1");
  printf(temp);
  f8fun(); // this function might call getenv()
  temp = getenv("VAR2");
  printf(temp); // NON_COMPLIANT[FALSE_NEGATIVE]
}

void f9(void) {
  const char *r;
  struct lconv *lc;
  char c[128];
  r = setlocale(LC_ALL, "ja_JP.UTF-8");
  strcpy(c, r);
  lc = localeconv();
  printf("%s\n", r);                   // NON_COMPLIANT
  printf("%s\n", c);                   // COMPLIANT
  printf("%s\n", lc->currency_symbol); // COMPLIANT
}

void f10(void) {
  struct tm tm = *localtime(&(time_t){time(NULL)});
  printf("%s", asctime(&tm)); // COMPLIANT
}

void f11fun(void) { char *tempvar = getenv("TEMP"); }
void f11(void) {
  char *tmpvar;

  tmpvar = getenv("TMP");
  if (!tmpvar) {
    /* Handle error */
  }
  f11fun();

  printf(tmpvar); // NON_COMPLIANT
}
