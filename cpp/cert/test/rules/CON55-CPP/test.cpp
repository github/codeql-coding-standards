#include <condition_variable>
#include <iostream>
#include <mutex>
#include <thread>

std::mutex mutex;
std::condition_variable cond;

void r1(size_t myStep) {
  static size_t currentStep = 0;
  std::unique_lock<std::mutex> lk(mutex);

  while (currentStep != myStep) {
    cond.wait(lk);
  }

  currentStep++;

  cond.notify_one(); // NON_COMPLIANT
}

void r2(size_t myStep) {
  static size_t currentStep = 0;
  std::unique_lock<std::mutex> lk(mutex);

  while (currentStep != myStep) {
    cond.wait(lk);
  }

  currentStep++;

  cond.notify_all(); // COMPLIANT
}

int f1() {
  std::thread threads[5];

  for (size_t i = 0; i < 5; ++i) {
    threads[i] = std::thread(r1, i);
  }

  for (size_t i = 5; i != 0; --i) {
    threads[i - 1].join();
  }
}