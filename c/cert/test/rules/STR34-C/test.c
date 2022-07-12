#include <ctype.h>
#include <stdio.h>

int f1() {
  char *c_str;
  int c;
  c = *c_str++; // NON_COMPLIANT
  return (c);
}

int f2() {
  unsigned char *c_str;
  int c;
  c = *c_str++; // COMPLIANT
  return (c);
}

int f3(void) {
  char *c_str;
  int c;
  c = (unsigned char)*c_str++; // COMPLIANT
  return (c);
}

void f4() {
  char *t;

  isalnum(*t); // NON_COMPLIANT
  isalpha(*t); // NON_COMPLIANT
  // isascii(*t); // Not part of the C Standard
  isblank(*t);  // NON_COMPLIANT
  iscntrl(*t);  // NON_COMPLIANT
  isdigit(*t);  // NON_COMPLIANT
  isgraph(*t);  // NON_COMPLIANT
  islower(*t);  // NON_COMPLIANT
  isprint(*t);  // NON_COMPLIANT
  ispunct(*t);  // NON_COMPLIANT
  isspace(*t);  // NON_COMPLIANT
  isupper(*t);  // NON_COMPLIANT
  isxdigit(*t); // NON_COMPLIANT
  // toascii(i); // Not part of the C Standard
  toupper(*t); // NON_COMPLIANT
  tolower(*t); // NON_COMPLIANT
}

void f5() {
  unsigned char *t;

  isalnum(*t); // COMPLIANT
  isalpha(*t); //  COMPLIANT
  // isascii(*t); // Not part of the C Standard
  isblank(*t);  //  COMPLIANT
  iscntrl(*t);  //  COMPLIANT
  isdigit(*t);  //  COMPLIANT
  isgraph(*t);  //  COMPLIANT
  islower(*t);  //  COMPLIANT
  isprint(*t);  //  COMPLIANT
  ispunct(*t);  //  COMPLIANT
  isspace(*t);  //  COMPLIANT
  isupper(*t);  //  COMPLIANT
  isxdigit(*t); // COMPLIANT
  // toascii(i); // Not part of the C Standard
  toupper(*t); //  COMPLIANT
  tolower(*t); //  COMPLIANT
}

void f6() {
  char *t;

  isalnum((unsigned char)*t); // COMPLIANT
  isalpha((unsigned char)*t); //  COMPLIANT
  // isascii((unsigned char*)*t); // Not part of the C Standard
  isblank((unsigned char)*t);  //  COMPLIANT
  iscntrl((unsigned char)*t);  //  COMPLIANT
  isdigit((unsigned char)*t);  //  COMPLIANT
  isgraph((unsigned char)*t);  //  COMPLIANT
  islower((unsigned char)*t);  //  COMPLIANT
  isprint((unsigned char)*t);  //  COMPLIANT
  ispunct((unsigned char)*t);  //  COMPLIANT
  isspace((unsigned char)*t);  //  COMPLIANT
  isupper((unsigned char)*t);  //  COMPLIANT
  isxdigit((unsigned char)*t); // COMPLIANT
  // toascii((unsigned int) i); // Not part of the C Standard
  toupper((unsigned char)*t); //  COMPLIANT
  tolower((unsigned char)*t); //  COMPLIANT
}

void f7() {
  int t;

  // Note these are all NON_COMPLIANT under STR37-C

  isalnum(t); // COMPLIANT
  isalpha(t); // COMPLIANT
  // isascii(t); // Not part of the C Standard
  isblank(t);  // COMPLIANT
  iscntrl(t);  // COMPLIANT
  isdigit(t);  // COMPLIANT
  isgraph(t);  // COMPLIANT
  islower(t);  // COMPLIANT
  isprint(t);  // COMPLIANT
  ispunct(t);  // COMPLIANT
  isspace(t);  // COMPLIANT
  isupper(t);  // COMPLIANT
  isxdigit(t); // COMPLIANT
  // toascii(i); // Not part of the C Standard
  toupper(t); // COMPLIANT
  tolower(t); // COMPLIANT
}
