import cpp

/**
 * Namespace for containing emergent language features in C11.
 */
module C11 {
  abstract class EmergentLanguageFeature extends Element { }

  class AtomicVariableSpecifier extends EmergentLanguageFeature, Variable {
    AtomicVariableSpecifier() {
      getType().(DerivedType).getBaseType*().getASpecifier().getName() = "atomic"
    }
  }

  class AtomicDeclaration extends EmergentLanguageFeature, Declaration {
    AtomicDeclaration() { getASpecifier().getName() = "atomic" }
  }

  class ThreadLocalDeclaration extends EmergentLanguageFeature, Declaration {
    ThreadLocalDeclaration() { getASpecifier().getName() = "is_thread_local" }
  }

  class EmergentHeader extends EmergentLanguageFeature, Include {
    EmergentHeader() { getIncludedFile().getBaseName() = ["stdatomic.h", "threads.h"] }
  }

  class LibExt1Macro extends EmergentLanguageFeature, Macro {
    LibExt1Macro() {
      getName() = "__STDC_WANT_LIB_EXT1__" and
      getBody() = "1"
    }
  }
}
