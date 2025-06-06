 - `RULE-21-22`, `RULE-21-23` - `TgMathArgumentWithInvalidEssentialType.ql`, `TgMathArgumentsWithDifferingStandardType.ql`
   - Change type-generic macro analysis for finding macro parameters to be compatible with gcc, by ignoring early arguments inserted by gcc.
   - Change explicit conversion logic to ignore the explicit casts inserted in macro bodies by clang, which previously overruled the argument essential type.
 - `RULE-13-2` - `UnsequencedAtomicReads.ql`:
   - Handle statement expression implementation of atomic operations in gcc.
 - `RULE-21-25` - `InvalidMemoryOrderArgument.ql`:
   - Handle case of where the enum `memory_order` is declared via a typedef as an anonymous enum.
   - Rewrite how atomically sequenced operations are found; no longer look for builtins or internal functions, instead look for macros with the exact expected name and analyze the macro bodies for the memory sequence parameter.
 - `RULE-9-7` - `UninitializedAtomicArgument.ql`:
   - Handle gcc case where `atomic_init` is defined is a call to `atomic_store`, and take a more flexible approach to finding the initialized atomic variable.
 - `DIR-4-15` - `PossibleMisuseOfUndetectedInfinity.ql`, `PossibleMisuseOfUndetectedNaN.ql`:
   - Fix issue when analyzing clang/gcc implementations of floating point classification macros, where analysis incorrectly determined that `x` in `isinf(x)` was guaranteed to be infinite at the call site itself, affecting later analysis involving `x`.