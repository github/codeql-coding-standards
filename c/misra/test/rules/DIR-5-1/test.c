#include "locale.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "threads.h"
#include "time.h"
#include "uchar.h"
#include "wchar.h"

int g1;
int g2;
int g3;
int g4;
mtx_t g4_lock;
int g5;
mtx_t g5_lock;

void single_thread1_reads_g1(void *p) {
  g1; // COMPLIANT
}

void many_thread2_reads_g1(void *p) {
  g1; // COMPLIANT
}

void single_thread3_reads_g2(void *p) {
  g2; // COMPLIANT
}

void single_thread4_writes_g2(void *p) {
  g2 = 1; // NON-COMPLIANT
}

void many_thread5_writes_g3(void *p) {
  g3 = 1; // NON-COMPLIANT
}

void single_thread6_reads_g4_locked(void *p) {
  mtx_lock(&g4_lock);
  g4; // COMPLIANT
}

void single_thread7_writes_g4_locked(void *p) {
  mtx_lock(&g4_lock);
  g4 = 1; // COMPLIANT
}

void many_thread8_writes_g5_locked(void *p) {
  mtx_lock(&g5_lock);
  g5 = 1; // COMPLIANT
}

struct {
  int m1;
  int m2;
} g6;

void single_thread9_writes_g6_m1(void *p) {
  g6.m1 = 1; // COMPLIANT
}

void single_thread10_writes_g6_m2(void *p) {
  g6.m2 = 1; // COMPLIANT
}

struct {
  int m1;
} g7;

void single_thread11_writes_g7_m1(void *p) {
  g7.m1 = 1; // NON-COMPLIANT
}

void single_thread12_writes_g7_m1(void *p) {
  g7.m1 = 1; // NON-COMPLIANT
}

void many_thread13_calls_nonreentrant_funcs(void *p) {
  setlocale(LC_ALL, "C");         // NON-COMPLIANT
  tmpnam("");                     // NON-COMPLIANT
  rand();                         // NON-COMPLIANT
  srand(0);                       // NON-COMPLIANT
  getenv("PATH");                 // NON-COMPLIANT
  getenv_s(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  strtok("a", "b");               // NON-COMPLIANT
  strerror(0);                    // NON-COMPLIANT
  asctime(NULL);                  // NON-COMPLIANT
  ctime(NULL);                    // NON-COMPLIANT
  gmtime(NULL);                   // NON-COMPLIANT
  localtime(NULL);                // NON-COMPLIANT
  mbrtoc16(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  mbrtoc32(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  c16rtomb(NULL, 0, NULL);        // NON-COMPLIANT
  c32rtomb(NULL, 0, NULL);        // NON-COMPLIANT
  mbrlen(NULL, 0, NULL);          // NON-COMPLIANT
  mbrtowc(NULL, NULL, 0, NULL);   // NON-COMPLIANT
  wcrtomb(NULL, 0, NULL);         // NON-COMPLIANT
  mbsrtowcs(NULL, NULL, 0, NULL); // NON-COMPLIANT
  wcsrtombs(NULL, NULL, 0, NULL); // NON-COMPLIANT
}

int main(int argc, char *argv[]) {
  thrd_t single_thread1;
  thrd_t many_thread2;
  thrd_t single_thread3;
  thrd_t single_thread4;
  thrd_t many_thread5;
  thrd_t single_thread6;
  thrd_t single_thread7;
  thrd_t many_thread8;
  thrd_t single_thread9;
  thrd_t single_thread10;
  thrd_t single_thread11;
  thrd_t single_thread12;
  thrd_t many_thread13;

  thrd_create(&single_thread1, single_thread1_reads_g1, NULL);
  thrd_create(&single_thread3, single_thread3_reads_g2, NULL);
  thrd_create(&single_thread4, single_thread4_writes_g2, NULL);
  thrd_create(&single_thread6, single_thread6_reads_g4_locked, NULL);
  thrd_create(&single_thread7, single_thread7_writes_g4_locked, NULL);
  thrd_create(&single_thread9, single_thread9_writes_g6_m1, NULL);
  thrd_create(&single_thread10, single_thread10_writes_g6_m2, NULL);
  thrd_create(&single_thread11, single_thread11_writes_g7_m1, NULL);
  thrd_create(&single_thread12, single_thread12_writes_g7_m1, NULL);
  for (;;) {
    thrd_create(&many_thread2, many_thread2_reads_g1, NULL);
    thrd_create(&many_thread5, many_thread5_writes_g3, NULL);
    thrd_create(&many_thread8, many_thread8_writes_g5_locked, NULL);
    thrd_create(&many_thread13, many_thread13_calls_nonreentrant_funcs, NULL);
  }
}