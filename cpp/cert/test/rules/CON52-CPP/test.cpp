#include <mutex>
#include <thread>

struct BitFieldStruct {
  unsigned int f1 : 2;
  unsigned int f2 : 2;
};

std::mutex mu;
BitFieldStruct bfs;

void f1() {
  std::lock_guard<std::mutex> lk(mu);
  bfs.f1 = 1; // COMPLIANT
}

void f2() {
  std::unique_lock<std::mutex> lk(mu);
  bfs.f2 = 2; // COMPLIANT
}

void f3() {
  bfs.f2 = 2; // COMPLIANT
}

void f4(std::mutex &pm) {
  int i = 0;
  pm.lock();
  i = i + 1;
  pm.unlock();
}

void f5(std::mutex &pm) {
  pm.lock();
  bfs.f2 = 2; // COMPLIANT
  pm.unlock();
}

void f6(std::mutex &pm) {
  pm.lock();
  bfs.f2 = 2; // COMPLIANT
}

void f7(std::mutex &pm) {
  pm.lock();
  pm.unlock();
  bfs.f2 = 2; // COMPLIANT
}

void f8(std::mutex &pm, std::mutex &pm2) {
  pm.lock();
  pm2.unlock();
  bfs.f2 = 2; // COMPLIANT
}

void f1t() {
  std::lock_guard<std::mutex> lk(mu);
  bfs.f1 = 1; // COMPLIANT
}

void f2t() {
  std::unique_lock<std::mutex> lk(mu);
  bfs.f2 = 2; // COMPLIANT
}

void f3t() {
  bfs.f2 = 2; // NON_COMPLIANT
}

void f4t(std::mutex *pm) {
  int i = 0;
  pm->lock();
  i = i + 1;
  pm->unlock();
}

void f5t(std::mutex *pm) {
  pm->lock();
  bfs.f2 = 2; // COMPLIANT
  pm->unlock();
}

void f6t(std::mutex *pm) {
  pm->lock();
  bfs.f2 = 2; // COMPLIANT
}

void f7t(std::mutex *pm) {
  pm->lock();
  pm->unlock();
  bfs.f2 = 2; // NON_COMPLIANT
}

void f8t(std::mutex *pm, std::mutex *pm2) {
  pm->lock();
  pm2->unlock();
  bfs.f2 = 2; // COMPLIANT
}

void f9t() {
  { std::unique_lock<std::mutex> lk(mu); }
  bfs.f2 = 2; // NON_COMPLIANT
}

void m() {
  std::mutex m1;
  std::mutex m2;

  std::thread t1 = std::thread(f1t);
  std::thread t2 = std::thread(f2t);
  std::thread t3 = std::thread(f3t);
  std::thread t4 = std::thread(f4t, &m1);
  std::thread t5 = std::thread(f5t, &m1);
  std::thread t6 = std::thread(f6t, &m1);
  std::thread t7 = std::thread(f7t, &m1);
  std::thread t8 = std::thread(f8t, &m1, &m2);
  std::thread t9 = std::thread(f9t);
}