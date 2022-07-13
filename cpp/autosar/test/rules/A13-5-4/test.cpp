
class A // NON_COMPLIANT
{
public:
  explicit A(int i) : i_(i){};
  friend bool operator==(const A &l, const A &r) noexcept {
    return l.i_ == r.i_;
  };

  friend bool operator!=(const A &l, const A &r) noexcept {
    return l.i_ != r.i_;
  };

private:
  int i_;
};

class B // COMPLIANT
{
public:
  explicit B(int i) : i_(i){};
  friend bool operator==(const B &l, const B &r) noexcept {
    return l.i_ == r.i_;
  };

  friend bool operator!=(const B &l, const B &r) noexcept { return !(l == r); };

private:
  int i_;
};