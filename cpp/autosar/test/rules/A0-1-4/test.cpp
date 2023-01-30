 void f(
   [[maybe_unused]] int i,  // compliant
   int j,  // compliant
   int k   // compliant
 ) {
    static_cast<void>(i);
    (void)j;
    std::ignore = k;
 }