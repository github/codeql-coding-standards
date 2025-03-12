// codeql::misra_deviation(x) - invalid, no x
// codeql::autosar_deviation(x) - invalid, no x
// codeql::cert_deviation(x) - invalid, no x
// codeql::misra_deviation_next(a-0-4-2-deviation) - invalid, next_line
// codeql::autosar_deviation_next(a-0-4-2-deviation) - invalid, next_line
// codeql::cert_deviation_next(a-0-4-2-deviation) - invalid, next_line

// codeql::misra_deviation_begin(a-0-4-2-deviation)
// codeql::autosar_deviation_begin(a-0-4-2-deviation)
// codeql::cert_deviation_begin(a-0-4-2-deviation)
// codeql::misra_deviation_end(a-0-4-2-deviation)
// codeql::autosar_deviation_end(a-0-4-2-deviation)
// codeql::cert_deviation_end(a-0-4-2-deviation)
// codeql::misra_deviation_end(a-0-4-2-deviation) - invalid, unmatched end
// codeql::autosar_deviation_end(a-0-4-2-deviation) - invalid, unmatched end
// codeql::cert_deviation_end(a-0-4-2-deviation) - invalid, unmatched end
// codeql::misra_deviation_begin(a-0-4-2-deviation) - invalid, unmatched begin
// codeql::autosar_deviation_begin(a-0-4-2-deviation) - invalid, unmatched begin
// codeql::cert_deviation_begin(a-0-4-2-deviation) - invalid, unmatched begin

[[codeql::misra_deviation("x")]] // invalid
void test() {}

[[codeql::autosar_deviation("a-0-4-2-deviation")]] void test2() {}
