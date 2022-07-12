// $Id: A13-2-1.cpp 271687 2017-03-23 08:57:35Z piotr.tanski $
class A
{
  public:
    // ...
    A& operator=(const A&) & // Compliant 
    {
      // ...
      return *this; }
    };

class B
{
  public:
    // ...
    const B& operator=(const B&) & // Non-compliant - violating consistency
                                   // with standard types
    {
      // ...
      return *this;
    }
};

class C
{
  public:
    // ...
    C operator=(const C&) & // Non-compliant 
    {
      // ...
      return *this;
    }
};

class D 
{ 
  public: 
    // ...
    D* operator=(const D&) & // Non-compliant 
    {
      // ...
      return this;
    } 
};