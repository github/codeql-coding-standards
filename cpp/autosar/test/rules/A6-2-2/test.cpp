#include <memory>
#include <type_traits>

template <typename T> class C1 {
  typedef typename std::remove_extent<T>::type element_type;
  typedef element_type *pointer;

public:
  C1(pointer p1) { m1 = p1; }

  ~C1() { std::default_delete<T>()(m1); }

private:
  pointer m1;
};

class C2 {
public:
  void f1(int p1) {}
};

void f1() {
  C1<int[]>{new int[10]}; // NON_COMPLIANT
  C2().f1(1);             // COMPLIANT, using constructed temporary object
}