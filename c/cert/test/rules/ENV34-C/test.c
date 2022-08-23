#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

  if (strcmp(tmpvar, tempvar) == 0) {
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

  if (strcmp(tmpvar, tempvar) == 0) {
    printf("TMP and TEMP are the same.\n");
  } else {
    printf("TMP and TEMP are NOT the same.\n");
  }
  free(tmpvar);
  tmpvar = NULL;
  free(tempvar);
  tempvar = NULL;
}