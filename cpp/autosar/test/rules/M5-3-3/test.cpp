/* The unary & operator shall not be overloaded */
// do not defined it at all
class A

{
  A operator&(); // NON_COMPLIANT
};
