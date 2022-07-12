//% $Id: A0-1-3.cpp 291350 2017-10-17 14:31:34Z jan.babst $
#include <cstdint>
static void F1() // Compliant
{}
namespace {
void F2() // Non-compliant, defined function never used
{}
} // namespace
class C {
public:
  C() : x(0) {}
  void M1(std::int32_t i) // Compliant, member function is used
  {
    x = i;
  }
  void M2(std::int32_t i,
          std::int32_t j) // Compliant, never used but declared
  {
    // as public
    x = (i > j) ? i : j;
  }

protected:
  void M1ProtectedImpl(std::int32_t j) // Compliant, never used but declared
                                       // as protected
  {
    x = j;
  }

private:
  std::int32_t x;
  void M1PrivateImpl(
      std::int32_t j) // Non-compliant, private member function never used
  {
    x = j;
  }
};
int main(int, char **) {
  F1();
  C c;
  c.M1(1);
  return 0;
}