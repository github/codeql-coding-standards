#ifndef GOOGLETEST_INCLUDE_GTEST_GTEST_H_
#define GOOGLETEST_INCLUDE_GTEST_GTEST_H_

#include "gtest/gtest-internal.h"

namespace testing {

class Test
{
  public:
  virtual ~Test();
  protected:
  // Creates a Test object.
  Test();
  private:
  virtual void TestBody() = 0;
  Test(const Test&) = delete;
  Test& operator=(const Test&) = delete;
};

#define GTEST_TEST(test_suite_name, test_name)             \
  GTEST_TEST_(test_suite_name, test_name, ::testing::Test)

#define TEST(test_suite_name, test_name) GTEST_TEST(test_suite_name, test_name)

} // namespace testing

#endif  // GOOGLETEST_INCLUDE_GTEST_GTEST_H_
