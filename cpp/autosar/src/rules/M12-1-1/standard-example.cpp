class B1
{
  public: 
    B1()
    {
      typeid(B1); // Compliant, B1 not polymorphic
    }; 
} 
class B2
{
  public:
    virtual ~B2(); 
    virtual void foo(); 
    B2()
    {
      typeid(B2);              // Non-compliant
      B2::foo();               // Compliant – not a virtual call
      foo();                   // Non-compliant
      dynamic_cast<B2*>(this); // Non-compliant
    }; 
}