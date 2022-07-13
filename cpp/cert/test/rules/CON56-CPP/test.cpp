#include <mutex>
#include <thread>

std::mutex m;

void w1() {
  while (!m.try_lock()) { // NON_COMPLIANT
  }
}

void f1() {
  std::lock_guard<std::mutex> lk(m);
  w1();
}

void f2() { std::lock_guard<std::mutex> lk(m); }

void w2() {
  std::lock_guard<std::mutex> lock(m);
  while (!m.try_lock()) {
  }
}

void w3() {
  m.unlock();
  while (!m.try_lock()) { // COMPLIANT
  }
  int a = 0;
  if (a > 3) {
    a++;
  }
}

void w333() {
  m.unlock();
  while (!m.try_lock()) { // COMPLIANT
  }
  int a = 0;
  if (a > 3) {
    a++;
  }
}

void w33() {
  while (!m.try_lock()) { // COMPLIANT
  }
  int a = 0;
  if (a > 3) {
    a++;
  }
}

void t1() {
  std::thread t(f1);
  w1();
}

void t2() {
  m.lock();
  std::thread t(w1);
}

void t3() {
  m.lock();
  w1();
}

void t4() {
  m.lock();
  std::thread t(w3);
}

void t5() {
  m.lock();
  w3();
}

void t55() {
  m.lock();
  w33();
}

void t6() {
  m.lock();
  m.unlock();

  std::thread t(w333);
}

void t7() {
  m.lock();
  m.unlock();

  w333();
}
