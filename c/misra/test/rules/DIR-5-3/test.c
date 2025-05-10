#include "pthread.h"
#include "threads.h"

thrd_t g1;    // COMPLIANT
pthread_t g2; // COMPLIANT

void *pthread_func(void *arg);
void *pthread_func_inner(void *arg);
int thrd_func(void *arg);
int thrd_func_inner(void *arg);

void make_threads_called_from_main(void);
void func_called_from_main(void);
void make_threads_called_from_func_called_from_main(void);
void make_threads_called_from_main_pthread_thrd(void);

int main(int argc, char *argv[]) {
  thrd_create(&g1, &thrd_func, NULL);             // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func, NULL); // COMPLIANT

  thrd_create(&g1, &thrd_func_inner, NULL);             // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // COMPLIANT

  make_threads_called_from_main();
  func_called_from_main();
  make_threads_called_from_main_pthread_thrd();
}

void make_threads_called_from_main() {
  thrd_create(&g1, &thrd_func_inner, NULL);             // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // COMPLIANT
}

void func_called_from_main() {
  make_threads_called_from_func_called_from_main();
}

void make_threads_called_from_func_called_from_main() {
  thrd_create(&g1, &thrd_func_inner, NULL);             // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // COMPLIANT
}

void make_threads_called_from_pthread_func(void);
void make_threads_called_from_thrd_func(void);
void func_called_from_pthread_thrd(void);
void make_threads_called_from_func_called_from_pthread_thrd(void);

void *pthread_func(void *arg) {
  thrd_create(&g1, &thrd_func_inner, NULL);             // NON-COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // NON-COMPLIANT

  make_threads_called_from_pthread_func();
  func_called_from_pthread_thrd();
  make_threads_called_from_main_pthread_thrd();
}

int thrd_func(void *arg) {
  thrd_create(&g1, &thrd_func_inner, NULL);             // NON-COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // NON-COMPLIANT

  make_threads_called_from_thrd_func();
  func_called_from_pthread_thrd();
  make_threads_called_from_main_pthread_thrd();
}

void make_threads_called_from_thrd_func(void) {
  thrd_create(&g1, &thrd_func_inner, NULL);             // NON-COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // NON-COMPLIANT
}

void func_called_from_pthread_thrd(void) {
  make_threads_called_from_func_called_from_pthread_thrd();
}

void make_threads_called_from_func_called_from_pthread_thrd(void) {
  thrd_create(&g1, &thrd_func_inner, NULL);             // NON-COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // NON-COMPLIANT
}

void make_threads_called_from_main_pthread_thrd() {
  thrd_create(&g1, &thrd_func_inner, NULL);             // NON-COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // NON-COMPLIANT
}

void make_threads_not_called_by_anyone() {
  thrd_create(&g1, &thrd_func_inner, NULL);             // COMPLIANT
  pthread_create(&g2, NULL, &pthread_func_inner, NULL); // COMPLIANT
}
