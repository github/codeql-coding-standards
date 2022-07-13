#include <string>

class trivial {};

class non_trivial {
public:
  non_trivial(int x_) : x(x_){};
  non_trivial() = default;
  virtual int calculate() { return x + 1; }

private:
  int x;
};

void test_mem_funs() {
  using namespace std;
  trivial t1, t2;
  non_trivial nt1{1};
  non_trivial nt2;

  // the following calls should get flagged:
  memcpy(&nt2, &nt1, sizeof(non_trivial));
  memmove(&nt2, &nt1, sizeof(non_trivial));

  // the following calls should not get flagged:
  memcpy(&t2, &t1, sizeof(trivial));
}