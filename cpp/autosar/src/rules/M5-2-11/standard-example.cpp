#include "util.h"
class A
{
  public:
    UtilType getValue();
    UtilType setValue(UtilType const &);
};
void f1(A& a1, A& a2)
{ 
  a1.getValue() && a2.setValue(0); // Short circuiting may occur
}
bool operator&&(UtilType const &,
                UtilType const &); // Non-compliant
void f2(A& a1, A& a2)
{ 
  a1.getValue() && a2.setValue(0); // Both operands evaluated
}