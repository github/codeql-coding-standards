// $Id: A5-2-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A
{
  public:
    virtual void F() noexcept;
};
class B : public A
{
  public:
  void F() noexcept override {}
};
void Fn(A* aptr) noexcept 
{
  // ...
  B* bptr = dynamic_cast<B*>(aptr); // Non-compliant

  if (bptr != nullptr) 
  {
    // Use B class interface
  }
  else
  {
    // Use A class interface
  } 
}