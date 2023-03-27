#include <stdarg.h>
#include <stdio.h>

int contains_zero(size_t count, va_list ap) {
  for (size_t i = 1; i < count; ++i) {
    if (va_arg(ap, double) == 0.0) { // COMPLIANT
      return 1;
    }
  }
  return 0;
}

int f1a(size_t count, ...) {
  va_list ap;
  va_start(ap, count);

  if (contains_zero(count, ap)) {
    va_start(ap, count);
    return 1;
  }

  for (size_t i = 0; i < count; ++i) {
    printf("%f ", 1.0 / va_arg(ap, double)); // NON_COMPLIANT
  }

  va_end(ap); // NON_COMPLIANT
  return 0;
}

int f1b(size_t count, ...) {
  int status;
  va_list ap;
  va_start(ap, count);

  if (contains_zero(count, ap)) {
    printf("0 in arguments!\n");
    status = 1;
  } else {
    va_end(ap); // NON_COMPLIANT
    va_start(ap, count);
    for (size_t i = 0; i < count; i++) {
      printf("%f ", 1.0 / va_arg(ap, double)); // COMPLIANT
    }
    printf("\n");
    status = 0;
  }

  va_end(ap); // NON_COMPLIANT
  return status;
}

int f1c(size_t count, ...) {
  int status;
  va_list ap;
  va_list ap1;
  va_start(ap, count);

  if (contains_zero(count, ap)) {
    printf("0 in arguments!\n");
    status = 1;
  } else {
    va_end(ap1); // COMPLIANT
    va_start(ap1, count);
    for (size_t i = 0; i < count; i++) {
      printf("%f ", 1.0 / va_arg(ap, double)); // NON_COMPLIANT
    }
    printf("\n");
    status = 0;
  }

  va_end(ap); // NON_COMPLIANT
  return status;
}

int contains_zero_ok(size_t count, va_list *ap) {
  va_list ap1;
  va_copy(ap1, *ap);
  for (size_t i = 1; i < count; ++i) {
    if (va_arg(ap1, double) == 0.0) { // COMPLIANT
      return 1;
    }
  }
  va_end(ap1); // COMPLIANT
  return 0;
}

int print_reciprocals_ok(size_t count, ...) {
  int status;
  va_list ap;
  va_start(ap, count);

  if (contains_zero_ok(count, &ap)) {
    printf("0 in arguments!\n");
    status = 1;
  } else {
    for (size_t i = 0; i < count; i++) {
      printf("%f ", 1.0 / va_arg(ap, double)); // COMPLIANT
    }
    printf("\n");
    status = 0;
  }

  va_end(ap); // COMPLIANT
  return status;
}
