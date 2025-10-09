#include <array>
#include <vector>

/* Helper functions */
std::vector<int> getData() { return {1, 2, 3}; }
std::vector<int> processData(const std::vector<int> &input) { return input; }
std::vector<int> getContainer() { return {4, 5, 6}; }

class MyContainer {
public:
  MyContainer() = default;
  MyContainer(std::vector<int> data) : data_(data) {}
  std::vector<int>::iterator begin() { return data_.begin(); }
  std::vector<int>::iterator end() { return data_.end(); }

private:
  std::vector<int> data_{7, 8, 9};
};

class ConvertibleToVector {
public:
  operator std::vector<int>() const { return {7, 8, 9}; }
  std::array<int, 3>::iterator begin() { return data_.begin(); }
  std::array<int, 3>::iterator end() { return data_.end(); }
  std::array<int, 3>::const_iterator begin() const { return data_.cbegin(); }
  std::array<int, 3>::const_iterator end() const { return data_.cend(); }

private:
  std::array<int, 3> data_{7, 8, 9};
};

std::vector<int> operator+(std::vector<int> a, std::vector<int> b) {
  std::vector<int> result = a;
  result.insert(result.end(), b.begin(), b.end());
  return result;
}

std::vector<int> convertToIntVector(std::vector<int> vector) { return vector; }

int main() {
  std::vector<int> localVec = {1, 2, 3};

  /* ========== 1. EXPLICIT FUNCTION CALLS ========== */

  for (auto x : getContainer()) { // COMPLIANT: 1 function call only
  }

  for (auto x : processData(getData())) { // NON_COMPLIANT: 2 function calls
  }

  /* ========== 2. OBJECT CREATION (CONSTRUCTOR CALLS) ========== */

  for (auto x : std::vector<int>(3)) { // COMPLIANT: 1 constructor call only
  }

  for (auto x : std::vector<int>{
           1, 2, 3}) { // NON_COMPLIANT: 2 constructor call to
                       // `vector` and `initializer_list`, respectively
  }

  for (auto x : MyContainer()) { // COMPLIANT: 1 constructor call only
  }

  for (auto x : std::string("hello")) { // COMPLIANT: 1 constructor call only
  }

  for (auto x : std::vector<int>(
           getData())) { // NON-COMPLIANT: 1 constructor + 1 function call
  }

  for (auto x : MyContainer(processData(
           localVec))) { // NON-COMPLIANT: 1 constructor + 1 function call
  }

  auto data = std::vector<int>(getData());
  for (auto x : data) { // NON-COMPLIANT: 1 constructor + 1 function call
  }

  MyContainer myContainer = MyContainer(processData(localVec));
  for (auto x : myContainer) { // NON-COMPLIANT: 1 constructor + 1 function call
  }

  /* ========== 3. OPERATOR OVERLOADING ========== */

  std::vector<int> vec1 = {1}, vec2 = {2}, vec3 = {3};
  std::vector<int> appendedVector = (vec1 + vec2) + vec3;
  for (auto x : appendedVector) { // COMPLIANT: 0 calls
  }

  std::vector<int> appendedVector2 = getData() + processData(localVec);
  for (auto x : appendedVector2) { // COMPLIANT: 0 calls
  }

  std::vector<int> anotherVec = {4, 5, 6};
  for (auto x : localVec + anotherVec) { // NON_COMPLIANT: 2 calls to vector's
                                         // constructor, 1 operator+ call
  }

  for (auto x : (vec1 + vec2) + vec3) { // NON-COMPLIANT: 3 calls to vector's
                                        // constructor, 2 operator+ calls
  }

  for (auto x :
       getData() +
           processData(
               localVec)) { // NON-COMPLIANT: 2 function calls + 1 operator call
  }

  /* ========== 4. IMPLICIT CONVERSIONS ========== */

  ConvertibleToVector convertible;
  for (int x :
       ConvertibleToVector()) { // COMPLIANT: 1 conversion operator call only
  }

  for (int x :
       convertToIntVector(convertible)) { // NON_COMPLIANT: 1 function call + 1
                                          // conversion operator call
  }

  for (int x :
       convertToIntVector(convertible)) { // NON_COMPLIANT: 1 function call + 1
                                          // conversion operator call
  }

  std::vector<int> intVector1 = convertToIntVector(convertible);
  for (int x : intVector1) { // COMPLIANT: 0 function calls
  }

  std::vector<int> intVector2 = convertToIntVector(convertible);
  for (int x : intVector2) { // COMPLIANT: 0 function calls
  }
}