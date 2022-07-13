#include <stdio.h>

enum { BUFFERSIZE = 32 };

extern void initialize_data(char *data, size_t size);

void f1(const char *file_name) {
  char data[BUFFERSIZE];
  char append_data[BUFFERSIZE];
  FILE *file;

  file = fopen(file_name, "a+");

  if (fwrite(append_data, 1, BUFFERSIZE, file) != BUFFERSIZE) {
  }
  if (fread(data, 1, BUFFERSIZE, file) < BUFFERSIZE) { // NON_COMPLIANT
  }

  if (fclose(file) == EOF) {
  }
}

FILE *global_file;
void f2(const char *file_name) {
  char data[BUFFERSIZE];
  char append_data[BUFFERSIZE];

  global_file = fopen(file_name, "a+");

  if (fwrite(append_data, 1, BUFFERSIZE, global_file) != BUFFERSIZE) {
  }
  if (fread(data, 1, BUFFERSIZE, global_file) < BUFFERSIZE) { // NON_COMPLIANT
  }

  if (fclose(global_file) == EOF) {
  }
}

void f3(const char *file_name) {
  char data[BUFFERSIZE];
  char append_data[BUFFERSIZE];
  FILE *file = fopen(file_name, "a+");
  if (file == NULL) {
    /* Handle error */
  }

  initialize_data(append_data, BUFFERSIZE);
  if (fwrite(append_data, BUFFERSIZE, 1, file) != BUFFERSIZE) {
    /* Handle error */
  }

  if (fseek(file, 0L, SEEK_SET) != 0) {
    /* Handle error */
  }

  if (fread(data, BUFFERSIZE, 1, file) != 0) { // COMPLIANT
    /* Handle there not being data */
  }

  if (fclose(file) == EOF) {
    /* Handle error */
  }
}
