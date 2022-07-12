#include <chrono>
#include <condition_variable>
#include <mutex>
using namespace std::chrono_literals;

std::condition_variable_any cond_var_any;
std::mutex mutex_any;

void test_wait() {
  std::unique_lock<std::mutex> lock(mutex_any);
  cond_var_any.wait(lock); // NON_COMPLIANT
}

void test_wait_for() {
  std::unique_lock<std::mutex> lock(mutex_any);
  if (cond_var_any.wait_for(lock, 100ms) ==
      std::cv_status::no_timeout) { // NON_COMPLIANT
  }
}

void test_wait_until() {
  std::unique_lock<std::mutex> lock(mutex_any);
  auto now = std::chrono::system_clock::now();
  if (cond_var_any.wait_until(lock, now) ==
      std::cv_status::no_timeout) { // NON_COMPLIANT
  }
}