#ifndef GOOGLETEST_INCLUDE_GTEST_INTERNAL_GTEST_INTERNAL_H_
#define GOOGLETEST_INCLUDE_GTEST_INTERNAL_GTEST_INTERNAL_H_

#define GTEST_TEST_CLASS_NAME_(test_suite_name, test_name) \
  test_suite_name##_##test_name##_Test

#define GTEST_TEST_(test_suite_name, test_name, parent_class)                   \
 class GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)                       \
      : public parent_class {                                                   \
      public:                                                                   \
    GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)() = default;             \
    ~GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)() override = default;   \
    GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)                          \
    (const GTEST_TEST_CLASS_NAME_(test_suite_name, test_name) &) = delete;      \
    GTEST_TEST_CLASS_NAME_(test_suite_name, test_name) & operator=(             \
        const GTEST_TEST_CLASS_NAME_(test_suite_name,                           \
                                     test_name) &) = delete; /* NOLINT */       \
    GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)                          \
    (GTEST_TEST_CLASS_NAME_(test_suite_name, test_name) &&) noexcept = delete;  \
    GTEST_TEST_CLASS_NAME_(test_suite_name, test_name) & operator=(             \
        GTEST_TEST_CLASS_NAME_(test_suite_name,                                 \
                               test_name) &&) noexcept = delete; /* NOLINT */   \
                                                                                \
   private:                                                                     \
    void TestBody() override;                                                            \
    };                                                                          \
    void GTEST_TEST_CLASS_NAME_(test_suite_name, test_name)::TestBody()         \

#endif // GOOGLETEST_INCLUDE_GTEST_INTERNAL_GTEST_INTERNAL_H_
