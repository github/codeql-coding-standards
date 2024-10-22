#include <cstdio>
#include <stddef.h>
void *test_cstdio_is_used() {
  std::FILE *f = std::fopen("foo.txt", "r"); // NON_COMPLIANT

  std::fpos_t init_position;       // NON_COMPLIANT
  std::fgetpos(f, &init_position); // NON_COMPLIANT

  while (!std::feof(f)) {   // NON_COMPLIANT
    char c = std::fgetc(f); // NON_COMPLIANT
    if (c == EOF)           // NON_COMPLIANT
      std::rewind(f);       // NON_COMPLIANT
  }
  if (std::ferror(f)) {   // NON_COMPLIANT
    std::clearerr(f);     // NON_COMPLIANT
    std::fclose(f);       // NON_COMPLIANT
    std::perror("fgetc"); // NON_COMPLIANT
  }

  std::fseek(f, (size_t)0, SEEK_SET); // NON_COMPLIANT
  std::fseek(f, (size_t)0, SEEK_END); // NON_COMPLIANT
  char buf[BUFSIZ];                   // NON_COMPLIANT
  std::fread(buf, 1, sizeof(buf), f); // NON_COMPLIANT

  std::fsetpos(f, &init_position); // NON_COMPLIANT
  std::fflush(f);                  // NON_COMPLIANT
  std::fclose(f);                  // NON_COMPLIANT

  std::printf("DEBUG: TMP_MAX=%d FILENAME_MAX=%d FOPEN_MAX=%d\n", TMP_MAX,
              FILENAME_MAX, FOPEN_MAX); // NON_COMPLIANT
  std::puts("all done!");               // NON_COMPLIANT

  // global namespace
  FILE *f1 = fopen("foo.txt", "r"); // NON_COMPLIANT

  fpos_t init_position1;
  fgetpos(f1, &init_position1); // NON_COMPLIANT

  while (!feof(f1)) {   // NON_COMPLIANT
    char c = fgetc(f1); // NON_COMPLIANT
    if (c == EOF)       // NON_COMPLIANT
      rewind(f1);       // NON_COMPLIANT
  }
  if (ferror(f1)) {  // NON_COMPLIANT
    clearerr(f1);    // NON_COMPLIANT
    fclose(f1);      // NON_COMPLIANT
    perror("fgetc"); // NON_COMPLIANT
  }

  fseek(f1, (size_t)0, SEEK_SET); // NON_COMPLIANT
  fread(buf, 1, sizeof(buf), f1); // NON_COMPLIANT

  fsetpos(f1, &init_position1); // NON_COMPLIANT
  fflush(f1);                   // NON_COMPLIANT
  fclose(f1);                   // NON_COMPLIANT

  printf("foo");     // NON_COMPLIANT
  puts("all done!"); // NON_COMPLIANT

  return NULL; // COMPLIANT - NULL is not uniquely defined by cstdio
}