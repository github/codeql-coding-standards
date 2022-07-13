#include <stdlib.h>
#include <string>

void test_banned_cstdlib_functions() {
  std::string env{getenv("JAVA_HOME")};
  int x = system("NULL");
  // All these should fail
  abort();
  exit(0);
}