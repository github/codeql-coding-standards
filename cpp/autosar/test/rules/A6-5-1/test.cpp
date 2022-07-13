void test_non_compliant_loop_does_not_use_loop_counter() {
  constexpr int N = 10;
  int arr2[N];
  for (int i = 0; i < N; i++) // NON_COMPLIANT
  {
  }
}

void test_compliant_loop_uses_loop_counter() {
  constexpr int N = 10;
  int arr2[N];
  for (int i = 0; i < N; i++) // COMPLIANT
  {
    i = i + 1;
  }
}