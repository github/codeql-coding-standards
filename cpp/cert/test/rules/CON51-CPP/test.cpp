#include <mutex>
#include <stdexcept>
#include <thread>

struct MaybeException : public std::exception {
  const char *what() const throw() { return "MaybeException"; }
};

void mightThrow() { throw MaybeException(); }

void f1(std::mutex *pm) {
  pm->lock();
  try {
    mightThrow(); // COMPLIANT
  } catch (...) {
    pm->unlock();
    throw;
  }
  pm->unlock();
}

void f2(std::mutex *pm) {
  pm->lock();
  try {
    mightThrow(); // COMPLIANT
  } catch (...) {
    pm->unlock();
    throw;
  }
}

void f3(std::mutex *pm) {
  pm->lock();
  try {
    mightThrow(); // NON_COMPLIANT - catch statement never unlocks the mutex.
  } catch (...) {
    throw;
  }
}

void f4(std::mutex *pm) {
  int i = 0;
  pm->lock();
  i = i + 1; // COMPLIANT
  pm->unlock();
}

void f5(std::mutex *pm) {
  pm->lock();
  mightThrow(); // NON_COMPLIANT
  pm->unlock();
}

void f6(std::mutex *pm) {
  int i = 0;
  while (i < 50) {
    pm->lock();
    mightThrow(); // NON_COMPLIANT
    pm->unlock();
  }
}

void f7(std::mutex *pm) {
  int i = 0;
  while (i < 50) {
    pm->lock();
    i = i + 1; // COMPLIANT
    pm->unlock();
  }
}

void f8(std::mutex *pm) {
  int i = 0;
  while (i < 50) {
    pm->lock();
    try {
      mightThrow(); // COMPLIANT
    } catch (...) {
      pm->unlock();
      throw;
    }
    pm->unlock();
  }
}

void m() {
  std::mutex pm;
  std::thread t1 = std::thread(f1, &pm);
  std::thread t2 = std::thread(f2, &pm);
  std::thread t3 = std::thread(f3, &pm);
  std::thread t4 = std::thread(f4, &pm);
  std::thread t5 = std::thread(f5, &pm);
  std::thread t6 = std::thread(f6, &pm);
  std::thread t7 = std::thread(f7, &pm);
  std::thread t8 = std::thread(f8, &pm);
}
