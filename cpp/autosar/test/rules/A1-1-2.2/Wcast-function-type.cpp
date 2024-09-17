// semmle-extractor-options: --clang -std=c++14 -Wcast-function-type
// COMPLIAN

// NOTE: When tested with `codeql test run`, the test extractor provides `-w`
// which overrides `-Wcast-function-type` and causes this test case to be
// non-compliant.
//
// However, when tested with our compiler matrix tests, this test db is built
// via `codeql database create --command="..."`, and the `-w` flag will NOT be
// used. This means the `-Wcast-function-type` flag is active and the test case
// is compliant.
//
// Therefore, the .expected file for this test expects non-compliance, and the
// .expected.gcc and .expected.clang files expect this test to be compliant.