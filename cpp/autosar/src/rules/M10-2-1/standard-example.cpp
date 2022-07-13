class B1
{
  public:
    int32_t count; // Non-compliant
    void foo ( );  // Non-compliant
}; 

class B2
{
  public:
    int32_t count; // Non-compliant
    void foo ( );  // Non-compliant
}; 

class D : public B1, public B2
{
  public:
    void Bar ( )
    { 
      ++count; // Is that B1::count or B2::count?
      foo ( ); // Is that B1::foo() or B2::foo()?
    }
};