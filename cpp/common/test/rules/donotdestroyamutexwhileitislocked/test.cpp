#include <mutex>
#include <thread>

std::mutex *m4 = new std::mutex(); // NON_COMPLIANT
std::mutex m5;                     // COMPLIANT
std::mutex *m6 = new std::mutex(); // COMPLIANT

void t1(int i, std::mutex *pm) {}
void t2(int i, std::mutex **pm) {}
void t3(int i, std::mutex *pm) { delete pm; }
void t4(int i) { delete m4; }
void t5(int i) { std::lock_guard<std::mutex> lk(m5); }

void f1() {
  std::thread threads[5];
  std::mutex m1; // NON_COMPLIANT

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, &m1);
  }
}

void f2() {
  std::thread threads[5];
  std::mutex m1; // COMPLIANT

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, &m1);
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }
}

std::mutex m2; // COMPLIANT - m2 is not deleted and never goes out of scope.
               // There is no delete

void f3() {
  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, &m2);
  }
}

std::mutex *m3;

void f4() {
  m3 = new std::mutex(); // COMPLIANT

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, m3);
  }

  // since we wait here, and the local function created the
  // mutex, the following delete is allowed.
  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }

  delete m3;
}

void f5() {
  m3 = new std::mutex(); // COMPLIANT

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t2, i, &m3);
  }
}

void f6() {
  m3 = new std::mutex(); // COMPLIANT

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t1, i, m3);
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }

  delete m3;
}

void f7() {
  m3 = new std::mutex(); // NON_COMPLIANT - t3 will attempt to delete the mutex.

  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t3, i, m3);
  }

  for (int i = 0; i < 5; ++i) {
    threads[i].join();
  }
}

void f8() {
  std::mutex *m = new std::mutex(); // COMPLIANT
  delete m;
}

void f9() {
  std::mutex m; // COMPLIANT
}

// f10 does not wait but it is OK since m5 is global and doesn't go out of
// scope -- the destructor isn't called until the program exists.
void f10() {
  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t5, i);
  }
}

// f11 represents an invalid usage of the global mutex `m4` since it attempts to
// delete it from within the thread.
void f11() {
  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t4, i);
  }
}

// f12 represents a valid but tricky usage of the global mutex `m6` since it is
// not deleted/accessed from the thread
void f12() {
  std::thread threads[5];

  for (int i = 0; i < 5; ++i) {
    threads[i] = std::thread(t4, i);
  }

  delete m6;
}
