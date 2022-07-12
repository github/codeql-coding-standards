#include <exception>

void test_catch_all() {
  try {
  } catch (std::exception &e) {
  } catch (...) { // COMPLIANT - Last catch block
  }

  // try {
  // } catch (...) { // NON_COMPLIANT[FALSE_NEGATIVE] - this is compiler checked
  // by default, but is permitted by g++
  //                                                    under -fpermissive.
  //                                                    However, edg currently
  //                                                    throws an error for this
  //                                                    case.
  // } catch (std::exception &e) {
  // }
}