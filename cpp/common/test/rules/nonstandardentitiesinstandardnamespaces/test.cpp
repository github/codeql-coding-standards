class C1 {
public:
  C1(int p1) : m1(p1) {}

  int f1() const { return m1; }

private:
  int m1;
};

namespace std {
int m1; // NON_COMPLIANT

template <class T>
struct plus; // NON_COMPLIANT; used for the specialization case so assume this
             // is part of a std.

template <>
struct plus<C1> { // COMPLIANT; template specialization depending on a
                  // user-defined type.
  C1 operator()(const C1 &lhs, const C1 &rhs) { return lhs.f1() + rhs.f1(); }
};

template <> struct plus<float> { // NON_COMPLIANT
  float operator()(const float &lhs, const float &rhs) { return lhs + rhs; }
};
} // namespace std

namespace posix {
int m1; // NON_COMPLIANT
}