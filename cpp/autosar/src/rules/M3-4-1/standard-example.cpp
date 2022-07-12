void f(int32_t k)
{
  int32_t j = k * k; // Non-compliant
  {
    int32_t i = j;   // Compliant
    std::cout << i << j << std::endl;
  }
}