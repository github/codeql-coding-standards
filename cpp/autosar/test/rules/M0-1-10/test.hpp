template <class T>
constexpr T aCalledFuncInHeader(T value) noexcept { // COMPLIANT
  return static_cast<T>(value);
}
