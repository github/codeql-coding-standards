#include <csignal>

void signal_handler(int signal) {}

void test_signal_is_used() {
  std::sig_atomic_t atom;              // NON_COMPLIANT
  std::signal(SIGINT, signal_handler); // NON_COMPLIANT
  std::raise(SIGINT);                  // NON_COMPLIANT

  sig_atomic_t atom1;             // NON_COMPLIANT
  signal(SIGINT, signal_handler); // NON_COMPLIANT
  raise(SIGINT);                  // NON_COMPLIANT
}