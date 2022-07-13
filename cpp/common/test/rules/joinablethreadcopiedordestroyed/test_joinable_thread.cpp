#include <thread>
#include <utility>

void f();

void test_simple_join() {
  std::thread t(f);
  t.join();
} // COMPLIANT - t is joined before destructor is called

void test_simple_not_join() {
  std::thread t(f);
} // NON_COMPLIANT - t is not joined before destructor is called

void test_simple_join_conditional(int i) {
  if (i < 100) {
    std::thread t(f);
    t.join();
  } // COMPLIANT - t is joined on all paths before destructor is called
}

void test_simple_not_join_conditional(int i) {
  std::thread t(f);
  if (i < 100) {
    t.join();
  }
} // NON_COMPLIANT - t is not joined on all paths before destructor is called

void test_simple_not_join_conditional_2(int i) {
  if (i < 100) {
    std::thread t(f);
  } // NON_COMPLIANT - t is joined on all paths before destructor is called
}

void test_simple_copy_assignment() {
  std::thread t(f);
  std::thread t2(f);
  t2.join();
  t2 =
      std::move(t); // COMPLIANT - t2 is joined before move assignment is called
  t2.join();
} // COMPLIANT - t2 (which was t) is joined before the destructor is called

void test_simple_not_join_copy_assignment() {
  std::thread t(f);
  std::thread t2(f);
  t2 = std::move(
      t); // NON_COMPLIANT - t2 is not joined before move assignment is called
  t2.join();
}

void test_detach() {
  std::thread t(f);
  t.detach(); // COMPLIANT - a detached thread is no longer joinable
}