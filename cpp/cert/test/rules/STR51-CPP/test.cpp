#include <string>

void test_null_string() {
  const char *null_char_p{nullptr};
  std::allocator<char> a;
  std::string::size_type size = 1;
  std::string::const_iterator ci;

  // Member functions
  std::string s{null_char_p, a};                // NON_COMPLIANT
  std::string s2{null_char_p};                  // NON_COMPLIANT
  const std::string const_s{"test"};            // COMPLIANT - not null
  s.append(null_char_p);                        // NON_COMPLIANT
  s.append(null_char_p, size);                  // COMPLIANT - provides a size
  s.append(s2);                                 // COMPLIANT - not null
  s.assign(null_char_p);                        // NON_COMPLIANT
  s.assign(null_char_p, size);                  // COMPLIANT - provides a size
  s.insert(size, null_char_p);                  // NON_COMPLIANT
  s.insert(size, null_char_p, size);            // COMPLIANT - provides a size
  s.replace(size, size, null_char_p);           // NON_COMPLIANT
  s.replace(size, size, null_char_p, size);     // COMPLIANT - provides a size
  s.replace(ci, ci, null_char_p);               // NON_COMPLIANT
  s.replace(ci, ci, null_char_p, size);         // COMPLIANT - provides a size
  s.find(null_char_p, size);                    // NON_COMPLIANT
  s.find(null_char_p, size, size);              // COMPLIANT - provides a size
  s.rfind(null_char_p, size);                   // NON_COMPLIANT
  s.rfind(null_char_p, size, size);             // COMPLIANT - provides a size
  s.find_first_of(null_char_p, size);           // NON_COMPLIANT
  s.find_first_of(null_char_p, size, size);     // COMPLIANT - provides a size
  s.find_last_of(null_char_p, size);            // NON_COMPLIANT
  s.find_last_of(null_char_p, size, size);      // COMPLIANT - provides a size
  s.find_first_not_of(null_char_p, size);       // NON_COMPLIANT
  s.find_first_not_of(null_char_p, size, size); // COMPLIANT - provides a size
  s.find_last_not_of(null_char_p, size);        // NON_COMPLIANT
  s.find_last_not_of(null_char_p, size, size);  // COMPLIANT - provides a size
  s.compare(null_char_p);                       // NON_COMPLIANT
  s = null_char_p;                              // NON_COMPLIANT
  s += null_char_p;                             // NON_COMPLIANT
  s.compare(size, size, null_char_p);           // NON_COMPLIANT
  s.compare(size, size, null_char_p, size);     // COMPLIANT - provides a size
  // Non-member functions
  null_char_p + const_s;  // NON_COMPLIANT
  const_s + null_char_p;  // NON_COMPLIANT
  const_s == null_char_p; // NON_COMPLIANT
  null_char_p == const_s; // NON_COMPLIANT
  const_s != null_char_p; // NON_COMPLIANT
  null_char_p != const_s; // NON_COMPLIANT
  const_s < null_char_p;  // NON_COMPLIANT
  null_char_p < const_s;  // NON_COMPLIANT
  const_s > null_char_p;  // NON_COMPLIANT
  null_char_p > const_s;  // NON_COMPLIANT
  const_s <= null_char_p; // NON_COMPLIANT
  null_char_p <= const_s; // NON_COMPLIANT
  const_s >= null_char_p; // NON_COMPLIANT
  null_char_p >= const_s; // NON_COMPLIANT
}