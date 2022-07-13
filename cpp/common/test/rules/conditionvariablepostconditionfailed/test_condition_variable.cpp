#include <chrono>
#include <condition_variable>
#include <mutex>
using namespace std::chrono_literals;

std::condition_variable cond_var;
std::mutex mutex;

void test_wait() {
  std::unique_lock<std::mutex> lock(mutex);
  cond_var.wait(lock); // NON_COMPLIANT
}

void test_wait_for() {
  std::unique_lock<std::mutex> lock(mutex);
  if (cond_var.wait_for(lock, 100ms) ==
      std::cv_status::no_timeout) { // NON_COMPLIANT
  }
}

void test_wait_until() {
  std::unique_lock<std::mutex> lock(mutex);
  auto now = std::chrono::system_clock::now();
  if (cond_var.wait_until(lock, now) ==
      std::cv_status::no_timeout) { // NON_COMPLIANT
  }
}