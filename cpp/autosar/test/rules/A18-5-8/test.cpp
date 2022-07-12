#include <memory>
#include <utility>

struct StructA {
  int x;
  int y;
};

void use(StructA *a);
void transfer(std::unique_ptr<StructA> &&a);
void copy(std::shared_ptr<StructA> a);

void test(int n) {
  StructA a1; // COMPLIANT
  use(&a1);

  StructA *a2 = new StructA{}; // NON_COMPLIANT
  use(a2);
  delete a2;

  StructA *a3 = new StructA[100]; // NON_COMPLIANT
  use(a3);
  delete[] a3;

  StructA *a4 = new StructA[1000]; // COMPLIANT - large enough to justify heap
  use(a4);
  delete[] a4;

  StructA *a5 =
      new StructA[n]; // COMPLIANT - `n` is unbounded, so could be large
  use(a5);
  delete[] a5;

  // make_shared performs heap allocation, and doesn't escape
  auto shared_a1 = std::make_shared<StructA>(); // NON_COMPLIANT

  // make_shared performs heap allocation, but shares ownership with other
  // functions
  auto shared_a2 = std::make_shared<StructA>(); // COMPLIANT
  copy(shared_a2);

  // make_unique performs heap allocation
  auto unique_a1 = std::make_unique<StructA>(); // NON_COMPLIANT

  // make_unique performs heap allocation, but transfers ownership to another
  // function
  auto unique_a2 = std::make_unique<StructA>(); // COMPLIANT
  transfer(std::move(unique_a2));
}

void test_conditional(bool do_x) {
  int *x_vals;
  if (do_x) {
    x_vals = new int[5]; // COMPLIANT - heap used for conditional allocation
  }

  if (do_x) {
    delete[] x_vals;
  }
}

bool fetch_and_store(int &x, int &y);

StructA *test_failure() {
  StructA *a = new StructA{}; // COMPLIANT - this outlives the function
  if (!fetch_and_store(a->x, a->y)) {
    delete a; // Only deleted on failure
    a = nullptr;
  }
  return a;
}