class A
{
  public:
    // A & operator= ( A const & rhs ) 
    // {
    //   i = rhs.i;
    //   return *this;
    // }
    template <typename T>
    T & operator=(T const & rhs) // Example 2
    {
      if(this != &rhs) {
        delete i;
        i = new int32_t;
        *i = *rhs.i;
      }
      return *this;
    }

  private:
    int32_t * i; // Member requires deep copy
};
void f(A const & a1, A & a2)
{
  a2 = a1; // Unexpectedly uses Example 1
}