class A
{
  public:
    A& operator= ( A const & rhs );
}; 
A & operator += ( A const & lhs, A const & rhs );
A const operator + ( A const & lhs, A const & rhs );
void f ( A a1, A a2 )
{
  A x;
  x = a1 + a2; // Example 1
  a1 += a2;    // Example 2
  if(x == a1)  // Example 3
  {
  } 
}