#include <stdatomic.h>

int g1 = memory_order_seq_cst;
int g2 = memory_order_relaxed;
int g3 = memory_order_acquire;
int g4 = memory_order_consume;
int g5 = memory_order_acq_rel;
int g6 = memory_order_release;
int *ptr;

void f(int p) {
  _Atomic int l1;
  atomic_flag l2;

  // Directly specified values:
  atomic_load_explicit(&l1, memory_order_seq_cst); // COMPLIANT
  atomic_load_explicit(&l1, memory_order_relaxed); // NON-COMPLIANT
  atomic_load_explicit(&l1, memory_order_acquire); // NON-COMPLIANT
  atomic_load_explicit(&l1, memory_order_consume); // NON-COMPLIANT
  atomic_load_explicit(&l1, memory_order_acq_rel); // NON-COMPLIANT
  atomic_load_explicit(&l1, memory_order_release); // NON-COMPLIANT

  // Implicit values:
  atomic_store(&l1, 0);                        // COMPLIANT
  atomic_load(&l1);                            // COMPLIANT
  atomic_flag_test_and_set(&l2);               // COMPLIANT
  atomic_flag_clear(&l2);                      // COMPLIANT
  atomic_exchange(&l1, 0);                     // COMPLIANT
  atomic_compare_exchange_strong(&l1, ptr, 1); // COMPLIANT
  atomic_compare_exchange_weak(&l1, ptr, 1);   // COMPLIANT
  atomic_fetch_add(&l1, 0);                    // COMPLIANT
  atomic_fetch_sub(&l1, 0);                    // COMPLIANT
  atomic_fetch_or(&l1, 0);                     // COMPLIANT
  atomic_fetch_xor(&l1, 0);                    // COMPLIANT
  atomic_fetch_and(&l1, 0);                    // COMPLIANT

  // Compliant flowed values (one test per sink):
  atomic_store_explicit(&l1, 0, g1);                            // COMPLIANT
  atomic_load_explicit(&l1, g1);                                // COMPLIANT
  atomic_flag_test_and_set_explicit(&l2, g1);                   // COMPLIANT
  atomic_flag_clear_explicit(&l2, g1);                          // COMPLIANT
  atomic_exchange_explicit(&l1, 0, g1);                         // COMPLIANT
  atomic_compare_exchange_strong_explicit(&l1, ptr, 1, g1, g1); // COMPLIANT
  atomic_compare_exchange_weak_explicit(&l1, ptr, 1, g1, g1);   // COMPLIANT
  atomic_fetch_add_explicit(&l1, 0, g1);                        // COMPLIANT
  atomic_fetch_sub_explicit(&l1, 0, g1);                        // COMPLIANT
  atomic_fetch_or_explicit(&l1, 0, g1);                         // COMPLIANT
  atomic_fetch_xor_explicit(&l1, 0, g1);                        // COMPLIANT
  atomic_fetch_and_explicit(&l1, 0, g1);                        // COMPLIANT
  atomic_thread_fence(g1);                                      // COMPLIANT
  atomic_signal_fence(g1);                                      // COMPLIANT

  // Non-compliant flowed values (one test per sink):
  atomic_store_explicit(&l1, 0, g2);                            // NON-COMPLIANT
  atomic_load_explicit(&l1, g2);                                // NON-COMPLIANT
  atomic_flag_test_and_set_explicit(&l2, g2);                   // NON-COMPLIANT
  atomic_flag_clear_explicit(&l2, g2);                          // NON-COMPLIANT
  atomic_exchange_explicit(&l1, 0, g2);                         // NON-COMPLIANT
  atomic_compare_exchange_strong_explicit(&l1, ptr, 1, g2, g1); // NON-COMPLIANT
  atomic_compare_exchange_strong_explicit(&l1, ptr, 1, g1, g2); // NON-COMPLIANT
  atomic_compare_exchange_weak_explicit(&l1, ptr, 1, g2, g1);   // NON-COMPLIANT
  atomic_compare_exchange_weak_explicit(&l1, ptr, 1, g1, g2);   // NON-COMPLIANT
  atomic_fetch_add_explicit(&l1, 0, g2);                        // NON-COMPLIANT
  atomic_fetch_sub_explicit(&l1, 0, g2);                        // NON-COMPLIANT
  atomic_fetch_or_explicit(&l1, 0, g2);                         // NON-COMPLIANT
  atomic_fetch_xor_explicit(&l1, 0, g2);                        // NON-COMPLIANT
  atomic_fetch_and_explicit(&l1, 0, g2);                        // NON-COMPLIANT
  atomic_thread_fence(g2);                                      // NON-COMPLIANT
  atomic_signal_fence(g2);                                      // NON-COMPLIANT

  // Non-compliant flowed values (one test per source):
  atomic_thread_fence(g2); // NON-COMPLIANT
  atomic_thread_fence(g3); // NON-COMPLIANT
  atomic_thread_fence(g4); // NON-COMPLIANT
  atomic_thread_fence(g5); // NON-COMPLIANT
  atomic_thread_fence(g6); // NON-COMPLIANT

  // Computed flow sources:
  atomic_thread_fence(memory_order_seq_cst * 1); // COMPLIANT
  atomic_thread_fence(1);                        // NON-COMPLIANT
  atomic_thread_fence(100);                      // NON-COMPLIANT
  atomic_thread_fence(g1 + 1); // NON_COMPLIANT[FALSE_NEGATIVE]

  // No unsafe flow, currently accepted:
  atomic_thread_fence(p); // COMPLIANT
}