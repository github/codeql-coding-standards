int id1;

namespace ns1 {
int id1; // COMPLIANT

namespace ns2 {
int id1; // COMPLIANT
class C1 {
  int id1;
  void test_scope(int id1) {
    for (int id1; id1 < 1; id1++) {
      for (int id1; id1 < 1; id1++) {
        {
          int id1;

          if (id1 == 0) {
            int id1;
          } else {
            int id1;
          }
          switch (id1) {
          case 0:
            int id1;
            break;
          }
          try {
            auto lambda1 = [id1]() { int id1 = 10; };
          } catch (int id1) {
            int id1;
          }
        }
      }
    }
  }
};
} // namespace ns2
} // namespace ns1
