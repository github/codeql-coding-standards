#include <mutex>
#include <thread>

void t1(int i, std::mutex *pm) {}
void t2(int i, std::mutex **pm) {}
void t3(int i, std::mutex *pm) { delete pm; }

void f1() {
  std::thread threads[5];
  std::mutex m1;

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, &m1); // NON_COMPLIANT
  }
}

void f2() {
  std::thread threads[5];
  std::mutex m1;

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, &m1); // COMPLIANT - due to check below
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }
}

std::mutex m2;

void f3() {
  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(
        t1, i, &m2); // COMPLIANT - since m2 will not go out of scope.
  }
}

std::mutex *m3;

void f4() {
  m3 = new std::mutex();

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, m3); // COMPLIANT
  }

  // since we wait here, and the local function created the
  // mutex, the following delete is allowed.
  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }

  delete m3;
}

void f5() {
  m3 = new std::mutex();

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t2, i, &m3); // COMPLIANT
  }
}

void f6() {
  m3 = new std::mutex();

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, m3); // COMPLIANT
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }

  delete m3;
}

void f7() {
  m3 = new std::mutex();

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(
        t3, i, m3); // NON_COMPLIANT - t3 will attempt to delete the mutex.
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }
}

void f8() {
  std::mutex *m = new std::mutex();
  delete m; // COMPLIANT
}

void f9() {
  std::mutex m; // COMPLIANT
}

std::mutex *m4 = new std::mutex();
