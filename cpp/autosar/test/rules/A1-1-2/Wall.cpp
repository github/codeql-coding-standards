// semmle-extractor-options: --clang -std=c++14 -Wall
// COMPLIANT

// NOTE: When tested with `codeql test run`, the test extractor provides `-w`
// which overrides `-Wall` and causes this test case to be non-compliant.
//
// However, when tested with our compiler matrix tests, this test db is built
// via `codeql database create --command="..."`, and the `-w` flag will NOT be
// used. This means the `-Wall` flag is active and the test case is compliant.
//
// Therefore, the .expected file for this test expects non-compliance, and the
// .expected.gcc and .expected.clang files expect this test to be compliant.