// test cases for StackAddressEscapes.ql

namespace std {
class string;

template <class T> class vector {};
}; // namespace std

class manager {
public:
  manager(){};
  ~manager(){};
};

class resource {
public:
  resource(manager *_m) : m(_m){};

  void set_strings(std::vector<std::string> const &_strings);

private:
  manager *m;
  std::vector<std::string> const *strings;
};

void resource ::set_strings(std::vector<std::string> const &_strings) {
  strings = &_strings;
}

manager *glob_man;

manager *test_managers() {
  manager man;
  manager *man_ptr;
  man_ptr = &man;

  resource a(
      &man); // NON_COMPLIANT[FALSE_NEGATIVE] - stack address `&man` escapes
  resource b(man_ptr); // NON_COMPLIANT[FALSE_NEGATIVE] - stack address
                       // `man_ptr` escapes
  resource *c = new resource(
      &man); // NON_COMPLIANT[FALSE_NEGATIVE] - stack address `&man` escapes

  std::vector<std::string> vs;
  a.set_strings(
      vs); // NON_COMPLIANT[FALSE_NEGATIVE] - stack address `&vs` escapes

  glob_man = &man; // NON_COMPLIANT - stack address `&man` escapes

  return &man; // NON_COMPLIANT[FALSE_NEGATIVE] - stack address `&man` escapes
}