#include <mutex>
#include <thread>

class B {
  int sum;

public:
  std::mutex mu;
  B() = delete;
  explicit B(int initialAmount) : sum(initialAmount) {}
  int get() const { return sum; }
  void set(int amount) { sum = amount; }
};

int d1(B *from, B *to, int amount) { // COMPLIANT
  std::unique_lock<std::mutex> lk1(from->mu, std::defer_lock);
  std::unique_lock<std::mutex> lk2(to->mu, std::defer_lock);

  std::lock(lk1, lk2);

  if (from->get() >= amount) {
    from->set(from->get() - amount);
    to->set(to->get() + amount);
    return 0;
  }
  return -1;
}

int d2(B *from, B *to, int amount) { // NON_COMPLIANT
  std::lock_guard<std::mutex> from_lock(from->mu);

  if (from->get() < amount) {
    return -1;
  }
  std::lock_guard<std::mutex> to_lock(to->mu);

  from->set(from->get() - amount);
  to->set(to->get() + amount);

  return 0;
}

int d3(B *from, B *to, int amount) { // NON_COMPLIANT
  std::lock_guard<std::mutex> from_lock(from->mu);

  if (from->get() < amount) {
    return -1;
  }
  std::lock_guard<std::mutex> to_lock(to->mu);

  from->set(from->get() - amount);
  to->set(to->get() + amount);

  return 0;
}

void f(B *ba1, B *ba2) {
  std::thread thr1(d1, ba1, ba2, 100);
  std::thread thr2(d2, ba2, ba1, 100);
  thr1.join();
  thr2.join();
}

void f2(B *ba1, B *ba2) {
  std::thread thr1(d2, ba1, ba2, 100);
  std::thread thr2(d2, ba2, ba1, 100);
  thr1.join();
  thr2.join();
}

void f3(B *ba1, B *ba2) {
  std::thread thr1(d3, ba1, ba2, 100);
  std::thread thr2(d3, ba1, ba2, 100);
  thr1.join();
  thr2.join();
}