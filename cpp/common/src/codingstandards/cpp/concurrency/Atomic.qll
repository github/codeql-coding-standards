import cpp

/**
 * Models calls to routines `atomic_compare_exchange_weak` and
 * `atomic_compare_exchange_weak_explicit` in the `stdatomic` library.
 * Note that these are typically implemented as macros within Clang and
 * GCC's standard libraries.
 */
class AtomicCompareExchange extends MacroInvocation {
  AtomicCompareExchange() {
    getMacroName() = "atomic_compare_exchange_weak"
    or
    // some compilers model `atomic_compare_exchange_weak` as a macro that
    // expands to `atomic_compare_exchange_weak_explicit` so this defeats that
    // and other similar modeling.
    getMacroName() = "atomic_compare_exchange_weak_explicit" and
    not exists(MacroInvocation m |
      m.getMacroName() = "atomic_compare_exchange_weak" and
      m.getAnExpandedElement() = getAnExpandedElement()
    )
  }
}

/**
 * Models calls to routines `atomic_store` and
 * `atomic_store_explicit` in the `stdatomic` library.
 * Note that these are typically implemented as macros within Clang and
 * GCC's standard libraries.
 */
class AtomicStore extends MacroInvocation {
  AtomicStore() {
    getMacroName() = "atomic_store"
    or
    // some compilers model `atomic_compare_exchange_weak` as a macro that
    // expands to `atomic_compare_exchange_weak_explicit` so this defeats that
    // and other similar modeling.
    getMacroName() = "atomic_store_explicit" and
    not exists(MacroInvocation m |
      m.getMacroName() = "atomic_store" and
      m.getAnExpandedElement() = getAnExpandedElement()
    )
  }
}
