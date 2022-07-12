#include <stdio.h>
#include <string.h>

int f1(FILE *file) {
  fpos_t offset;
  memset(&offset, 0, sizeof(offset));
  return fsetpos(file, &offset); // NON_COMPLIANT
}

int f2(FILE *file) {
  fpos_t offset;
  fgetpos(file, &offset);
  return fsetpos(file, &offset); // COMPLIANT
}

fpos_t f3a_helper(FILE *file) {
  fpos_t offset;
  fgetpos(file, &offset);
  return offset;
}
int f3a_inter(FILE *file) {
  fpos_t offset = f3a_helper(file);
  return fsetpos(file, &offset); // COMPLIANT
}

fpos_t f3b_helper() {
  fpos_t offset;
  memset(&offset, 0, sizeof(offset));
  return offset;
}
int f3b_inter(FILE *file) {
  fpos_t offset = f3b_helper();
  return fsetpos(file, &offset); // NON_COMPLIANT
}
