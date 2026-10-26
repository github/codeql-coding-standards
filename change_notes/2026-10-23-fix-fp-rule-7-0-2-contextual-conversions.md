- `RULE-7-0-2` - `NoImplicitBoolConversion.ql`:
   - Fixed false positives on the initializer of an `if`/`for` condition
     declaration (e.g. `if (T* p = f())` or `if (auto sp = weak.lock())`) when
     the initialized type is a pointer or a class with an explicit
     `operator bool`. These are contextual conversions, which are permitted.
   - Fixed false positives on `static_cast<bool>` of a class type with an
     explicit `operator bool` inside a class template.
