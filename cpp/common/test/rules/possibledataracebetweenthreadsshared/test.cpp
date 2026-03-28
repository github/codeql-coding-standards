#include "locale.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "time.h"
#include "uchar.h"
#include "wchar.h"
#include <clocale>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cuchar>
#include <cwchar>
#include <mutex>
#include <thread>

int g1;
int g2;
int g3;
int g4;
std::mutex g4_lock;
int g5;
std::mutex g5_lock;

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
  g4_lock.lock();
  g4; // COMPLIANT
}

void single_thread7_writes_g4_locked(void *p) {
  g4_lock.lock();
  g4 = 1; // COMPLIANT
}

void many_thread8_writes_g5_locked(void *p) {
  g5_lock.lock();
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
  // Copied from the c version.
  // Not all of these functions are defined, which c allows but cpp does not.
  // Not all are defined in std:: in our stubs.
  std::setlocale(LC_ALL, "C"); // NON-COMPLIANT
  setlocale(LC_ALL, "C");      // NON-COMPLIANT
  std::tmpnam(nullptr);        // NON-COMPLIANT
  rand();                      // NON-COMPLIANT
  std::rand();                 // NON-COMPLIANT
  // srand(0);                       // NON-COMPLIANT
  getenv("PATH"); // NON-COMPLIANT
  // std::getenv("PATH");                 // NON-COMPLIANT
  ////getenv_s(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  strtok("a", "b");      // NON-COMPLIANT
  std::strtok("a", "b"); // NON-COMPLIANT
  strerror(0);           // NON-COMPLIANT
  std::strerror(0);      // NON-COMPLIANT
  asctime(NULL);         // NON-COMPLIANT
  std::asctime(NULL);    // NON-COMPLIANT
  ctime(NULL);           // NON-COMPLIANT
  std::ctime(NULL);      // NON-COMPLIANT
  gmtime(NULL);          // NON-COMPLIANT
  std::gmtime(NULL);     // NON-COMPLIANT
  localtime(NULL);       // NON-COMPLIANT
  std::localtime(NULL);  // NON-COMPLIANT
  ////mbrtoc16(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  ////mbrtoc32(NULL, NULL, 0, NULL);  // NON-COMPLIANT
  ////c16rtomb(NULL, 0, NULL);        // NON-COMPLIANT
  ////c32rtomb(NULL, 0, NULL);        // NON-COMPLIANT
  // mbrlen(NULL, 0, NULL);          // NON-COMPLIANT
  // mbrtowc(NULL, NULL, 0, NULL);   // NON-COMPLIANT
  // wcrtomb(NULL, 0, NULL);         // NON-COMPLIANT
  // mbsrtowcs(NULL, NULL, 0, NULL); // NON-COMPLIANT
  // wcsrtombs(NULL, NULL, 0, NULL); // NON-COMPLIANT
}

int main(int argc, char *argv[]) {
  std::thread single_thread1;
  std::thread many_thread2;
  std::thread single_thread3;
  std::thread single_thread4;
  std::thread many_thread5;
  std::thread single_thread6;
  std::thread single_thread7;
  std::thread many_thread8;
  std::thread single_thread9;
  std::thread single_thread10;
  std::thread single_thread11;
  std::thread single_thread12;
  std::thread many_thread13;

  single_thread1 = std::thread(single_thread1_reads_g1, nullptr);
  single_thread3 = std::thread(single_thread3_reads_g2, nullptr);
  single_thread4 = std::thread(single_thread4_writes_g2, nullptr);
  single_thread6 = std::thread(single_thread6_reads_g4_locked, nullptr);
  single_thread7 = std::thread(single_thread7_writes_g4_locked, nullptr);
  single_thread9 = std::thread(single_thread9_writes_g6_m1, nullptr);
  single_thread10 = std::thread(single_thread10_writes_g6_m2, nullptr);
  single_thread11 = std::thread(single_thread11_writes_g7_m1, nullptr);
  single_thread12 = std::thread(single_thread12_writes_g7_m1, nullptr);
  for (;;) {
    many_thread2 = std::thread(many_thread2_reads_g1, nullptr);
    many_thread5 = std::thread(many_thread5_writes_g3, nullptr);
    many_thread8 = std::thread(many_thread8_writes_g5_locked, nullptr);
    many_thread13 =
        std::thread(many_thread13_calls_nonreentrant_funcs, nullptr);
  }
}