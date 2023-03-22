#include <stddef.h>
#include <string.h>

unsigned long copy_to_user(void *to, const void *from, unsigned long n);

typedef struct {
  int x;
  int y;
} MyStruct;

void forget_y() {
  MyStruct s;
  s.x = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (y)
}

void forget_x() {
  MyStruct s;
  s.y = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (x)
}

void forget_both() {
  MyStruct s;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (x, y)
}

void init_both() {
  MyStruct s;
  s.x = 1;
  s.y = 1;
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

void init_after() {
  MyStruct s;
  s.x = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT
  s.y = 1;
}

void init_other() {
  MyStruct s, t;
  s.y = 1;
  t.x = 1;
  t.y = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (x)
  copy_to_user(0, &t, sizeof t); // COMPLIANT
}

void zero_memory() {
  MyStruct s;
  memset(&s, 0, sizeof s);
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

void zero_memory_after() {
  MyStruct s;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT
  memset(&s, 0, sizeof s);
}

void zero_field() {
  MyStruct s;
  memset(&s.x, 0, sizeof s.x);
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (y)
}

void overwrite_with_zeroed() {
  MyStruct s, t;
  memset(&t, 0, sizeof t);
  s = t;
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

void overwrite_struct_with_uninit() {
  MyStruct s, t;
  s = t;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT[FALSE NEGATIVE]
}

void overwrite_field_with_uninit() {
  MyStruct s;
  int x;
  s.x = x;
  s.y = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT[FALSE NEGATIVE]
}

typedef struct {
  size_t length;
  char buf[128];
} PascalString;

void zero_array() {
  PascalString s;
  memset(s.buf, 0, sizeof s.buf);
  s.length = 0;
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

void zero_array_by_ref() {
  PascalString s;
  memset(&s.buf, 0, sizeof s.buf);
  s.length = 0;
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

char *strcpy(char *dst, const char *src);

void use_strcpy() {
  PascalString s;
  strcpy(s.buf, "Hello, World"); // does not zero rest of s.buf
  s.length = strlen(s.buf);
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (buf)
}

void *malloc(size_t size);

void heap_memory() {
  MyStruct *s;
  s = (MyStruct *)malloc(sizeof(*s));
  s->x = 1;
  copy_to_user(0, s, sizeof(*s)); // NON_COMPLIANT[FALSE NEGATIVE]
}

void conditional_memset(int b) {
  MyStruct s;
  if (b) {
    memset(&s, 0, sizeof s);
  }
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT
}

void memset_field() {
  MyStruct s;
  memset(&s.x, 0, sizeof(s.x));
  s.y = 1;
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

const static int one = 1;
void zero_if_true() {
  MyStruct s;
  if (one) {
    memset(&s, 0, sizeof s);
  }
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

struct has_padding {
  short s;
  int i;
};

void forget_padding() {
  struct has_padding s;
  s.s = 1;
  s.i = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT
}

void remember_padding() {
  struct has_padding s;
  memset(&s, 0, sizeof s);
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}