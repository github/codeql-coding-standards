// $Id: A12-4-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A
{
  public:
    ~A() // Non-compliant
    {
    }
};
class B : public A
{
};
class C
{
  public:
    virtual ~C() // Compliant
    {
    }
};
class D : public C
{
};
class E
{
  protected:
    ~E(); // Compliant
};
class F : public E
{
};
void F1(A* obj1, C* obj2)
{
  // ...
  delete obj1; // Only destructor of class A will be invoked
  delete obj2; // Both destructors of D and C will be invoked
}
void F2()
{
  A* a = new B;
  C* c = new D;
  F1(a, c);
}