// $Id: A13-5-2.cpp 303121 2018-01-09 09:03:52Z michal.szczepankiewicz $
class A
{
  public:
    explicit A(double d) : d(d) {}
    explicit operator double() const { return d; } // Compliant 
  private:
    double d;
};

int main(void)
{
  A a{3.1415926535897932384626433832795028841971693993751058209749445923078};
  double tmp1{a};
  // float tmp2{a}; //compilation error instead of warning, prevents from data
  // precision loss
  return 0;
}