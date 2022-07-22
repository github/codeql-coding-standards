#include <condition_variable>
#include <mutex>

static std::mutex mu;
static std::condition_variable cv;

void f1() {
  std::unique_lock<std::mutex> lk(mu);

  if (1) {
    cv.wait(lk); // NON_COMPLIANT
  }
}

void f2() {
  std::unique_lock<std::mutex> lk(mu);
  int i = 2;
  while (i > 0) {
    cv.wait(lk); // COMPLIANT
    i--;
  }
}

void f3() {
  std::unique_lock<std::mutex> lk(mu);
  int i = 2;
  do {
    cv.wait(lk); // COMPLIANT
    i--;
  } while (i > 0);
}

void f4() {
  std::unique_lock<std::mutex> lk(mu);

  for (;;) {
    cv.wait(lk); // COMPLIANT
  }
}

void f5() {
  std::unique_lock<std::mutex> lk(mu);

  int i = 2;
  while (i > 0) {
    i--;
  }

  cv.wait(lk); // NON_COMPLIANT
}

void f6() {
  std::unique_lock<std::mutex> lk(mu);

  for (int i = 0; i < 10; i++) {
  }
  int i = 0;
  if (i > 0) {
    cv.wait(lk); // NON_COMPLIANT
    i--;
  }
}
