import cpp

/**
 * Namespace for containing emergent language features in C11.
 */
module C11 {
  abstract class EmergentLanguageFeature extends Element { }

  class LibExt1Macro extends EmergentLanguageFeature, Macro {
    LibExt1Macro() {
      getName() = "__STDC_WANT_LIB_EXT1__" and
      getBody() = "1"
    }
  }
}
