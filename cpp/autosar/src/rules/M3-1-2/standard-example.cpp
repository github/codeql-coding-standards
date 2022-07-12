class A {};
void b1() {

  void f1(); // Non-compliant - declaring a function in block scope
  A a();     // Non-compliant - appears to declare an object with no
  // arguments to constructor, but it too declares a
  // function 'a' returning type 'A' and taking no
  // parameters.
}