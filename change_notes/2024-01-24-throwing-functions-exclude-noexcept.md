 * Exceptions are no longer propagated from calls to `noexcept` functions, or calls functions with dynamic exception specifications where the exception is not permitted. This is consistent with the default behaviour specified in `[expect.spec]` which indicates that `std::terminate` is called. This has the following impact:
   - `A15-4-2`, `ERR55-CPP` - reduce false positives for `noexcept` functions which call other `noexcept` function which may throw.
   - `A15-2-2` - reduce false positives for constructors which call `noexcept` functions.
   - `A15-4-5` - reduce false positives for checked exceptions that are thrown from `noexcept` functions called by the original function.
   - `DCL57-CPP` - do not report exceptions thrown from `noexcept` functions called by deallocation functions or destructors.
   - `A15-5-1`, `M15-3-1` - do not report exceptions thrown from `noexcept` functions called by special functions.