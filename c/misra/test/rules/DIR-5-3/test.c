#include "threads.h"
#include "pthread.h"

thrd_t g1; // COMPLIANT
pthread_t g2; // COMPLIANT
thrd_t g3[10]; // COMPLIANT
pthread_t g4[10]; // COMPLIANT

struct {
    thrd_t m1; // COMPLIANT
    pthread_t m2; // COMPLIANT
} g7;

void* pthread_func(void* arg);
int thrd_func(void* arg);

void make_threads_called_from_main(void);
void func_called_from_main(void);
void make_threads_called_from_func_called_from_main(void);
void make_threads_called_from_main_pthread_thrd(void);

void main() {
  // Main starting top level threads -- ok.
  thrd_create(&g1, &thrd_func, NULL); // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func, NULL); // COMPLIANT

  // Starting thread in pool -- ok.
  thrd_create(&g3[0], &thrd_func, NULL); // COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // COMPLIANT

  make_threads_called_from_main();
  func_called_from_main();
  make_threads_called_from_main_pthread_thrd();
}

void make_threads_called_from_main() {
  thrd_create(&g3[0], &thrd_func, NULL); // COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // COMPLIANT
}

void func_called_from_main() {
    make_threads_called_from_func_called_from_main();
}

void make_threads_called_from_func_called_from_main() {
  thrd_create(&g3[0], &thrd_func, NULL); // COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // COMPLIANT
}

void make_threads_called_from_pthread_func(void);
void make_threads_called_from_thrd_func(void);
void func_called_from_pthread_thrd(void);
void make_threads_called_from_func_called_from_pthread_thrd(void);

void* pthread_func(void* arg) {
  thrd_create(&g3[0], &thrd_func, NULL); // NON-COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // NON-COMPLIANT

  make_threads_called_from_pthread_func();
  func_called_from_pthread_thrd();
  make_threads_called_from_main_pthread_thrd();
}

int thrd_func(void* arg) {
  thrd_create(&g3[0], &thrd_func, NULL); // NON-COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // NON-COMPLIANT

  make_threads_called_from_thrd_func();
  func_called_from_pthread_thrd();
  make_threads_called_from_main_pthread_thrd();
}

void make_threads_called_from_thrd_func(void) {
  thrd_create(&g3[0], &thrd_func, NULL); // NON-COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // NON-COMPLIANT
}

void func_called_from_pthread_thrd(void) {
    make_threads_called_from_func_called_from_pthread_thrd();
}

void make_threads_called_from_func_called_from_pthread_thrd(void) {
  thrd_create(&g3[0], &thrd_func, NULL); // NON-COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // NON-COMPLIANT
}

void make_threads_called_from_main_pthread_thrd() {
  thrd_create(&g3[0], &thrd_func, NULL); // NON-COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // NON-COMPLIANT
}

void make_threads_not_called_by_anyone() {
  thrd_create(&g3[0], &thrd_func, NULL); // COMPLIANT
  pthread_create(&g4[0], NULL, &pthread_func, NULL); // COMPLIANT
}
