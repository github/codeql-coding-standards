#include <memory>
#include <utility>
#include <vector>

struct StructA {
  int x;
};

class StructManager {
public:
  void addStruct(StructA *a) { structs.push_back(a); }
  void createNewStruct() {
    StructA *a = new StructA{}; // COMPLIANT - in manager class
    structs.push_back(a);
  }

  ~StructManager() {
    for (auto s : structs) {
      delete s; // COMPLIANT - in manager class
    }
    structs.clear();
  }

private:
  std::vector<StructA *> structs;
};

void test_alloc() {
  StructA *a1 = new StructA{}; // NON_COMPLIANT
  delete a1;                   // NON_COMPLIANT
  StructManager sm;
  sm.addStruct(new StructA{}); // COMPLIANT
  sm.createNewStruct();

  auto a2 = std::make_unique<StructA>(); // COMPLIANT

  auto a3 = std::unique_ptr<StructA>(new StructA{}); // NON_COMPLIANT
}