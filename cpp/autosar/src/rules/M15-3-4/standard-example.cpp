class A {};
class B {};
void f(int32_t i) throw() {
  try {
    if (i > 10) {
      throw A(); // Compliant
    } else {
      throw B(); // Non-compliant
    }
  } catch (A const &) {
  }
}