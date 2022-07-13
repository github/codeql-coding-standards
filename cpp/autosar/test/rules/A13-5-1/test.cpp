/*If “operator[]” is to be overloaded with a non-const version, const
version shall also be implemented.*/

// operator overloaded- const and non const version

class A1 {
  int operator[](int index) // COMPLIANT-non-const verson
  {
    return 0;
  }
  int operator[](int index) const // COMPLIANT-const version
  {
    return 0;
  }
};

class A2 {
public:
  int operator[](int index) { // NON_COMPLIANT
    return container[index];
    ;
  }

private:
  static constexpr int maxSize = 12;
  int container[maxSize];
};