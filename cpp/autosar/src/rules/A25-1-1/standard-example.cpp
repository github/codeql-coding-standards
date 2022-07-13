//% $Id: A25-1-1.cpp 309784 2018-03-01 20:18:29Z michal.szczepankiewicz $
#include <iostream> 
#include <vector> 
#include <algorithm> 
#include <functional> 
#include <iterator>
class ThirdElemPred : public std::unary_function<int, bool> 
{
  public:
    ThirdElemPred() : timesCalled(0) {}
    bool operator()(const int &) { return (++timesCalled) == 3; } 
    //non-compliant, non-const call operator that
    //modifies the predicate object field
  private:
    size_t timesCalled;
};

class ThirdElemPred2 : public std::unary_function<int, bool>
{
  public:
    ThirdElemPred2() : timesCalled(0) {}
    bool operator()(const int &) const { return (++timesCalled) == 3; } 
    //non-compliant, const call operator that
    //modifies the mutable predicate object field
  private:
    mutable size_t timesCalled;
};

class ValueFivePred: public std::unary_function<int, bool>
{
  public:
    bool operator()(const int& v) const { return v == 5; }
    //compliant, const call operator that does not
    //modify the predicate object state
};

void F1(std::vector<int> v)
{
  //non-compliant, predicate object state modified
  int timesCalled = 0;
  //display values that are NOT to be removed

  std::copy(v.begin(), std::remove_if(v.begin(), v.end(), [timesCalled](const int &) mutable { return 
          (++timesCalled) == 3; }), std::ostream_iterator<std:: vector<int>::value_type>(std::cout, " ") );
  std::cout << std::endl;
}

void F2(std::vector<int> v) 
{
  //non-compliant, predicate object state modified
  std::copy(v.begin(), std::remove_if(v.begin(), v.end(), ThirdElemPred()), 
            std::ostream_iterator<std::vector<int>::value_type>(std::cout, " ") );
  std::cout << std::endl;
}

void F22(std::vector<int> v) 
{
  //non-compliant, predicate object state modified
  std::copy(v.begin(), std::remove_if(v.begin(), v.end(), ThirdElemPred2()), 
            std::ostream_iterator<std::vector<int>::value_type>(std::cout, " ") );
  std::cout << std::endl;
}

void F3(std::vector<int> v) 
{
  //compliant, predicate object that has its state
  //modified is passed as a std::reference_wrapper
  ThirdElemPred pred;
  std::copy(v.begin(), std::remove_if(v.begin(), v.end(), std::ref(pred)), 
            std::ostream_iterator<std::vector<int>::value_type>(std::cout, " ") ); 
  std::cout << std::endl;
}

int main(void)
{
  std::vector<int> v{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  F1(v);
  F2(v);
  F22(v);
  F3(v);
  //output for g++-5.5, correct result only for F3
    //F1  0 1 3 4 6 7 8 9
    //F2  0 1 3 4 6 7 8 9
    //F22 0 1 3 4 6 7 8 9
    //F3  0 1 3 4 5 6 7 8 9
  return 0; 
}
