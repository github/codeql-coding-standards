namespace ns1 {
struct S1 {
  struct S2 {
    static constexpr int m1 =
        1; // declares m1 according to [class.static.data:4]
  };
};
} // namespace ns1
