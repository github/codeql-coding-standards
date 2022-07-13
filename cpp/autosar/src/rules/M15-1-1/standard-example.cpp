class E {
public:
  E() {} // Assume constructor cannot cause an exception
  if (...)
};
try {
  {}
  throw E(); // Compliant – no exception thrown
  //   when constructing the object
}
// construction of E2 causes an exception to be thrown
class E2 {
public:
  E2() { throw 10; }
};
try {
  if (...) {
    throw E2(); // Non-compliant – int exception thrown
                // when constructing the E2 object
  }
}