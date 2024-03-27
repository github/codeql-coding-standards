/** A module to reason about the compiler used to compile translation units. */

import cpp
import codingstandards.cpp.Scope

newtype Compiler =
  Gcc() or
  Clang() or
  UnsupportedCompiler()

/** Get the match pattern to detect the compiler being mimicked by the extractor to determine the compiler used to compile a file. */
string getMimicMatch(Compiler compiler) {
  result = ["%gcc", "%g++"] and compiler instanceof Gcc
  or
  result = ["%clang", "%clang++"] and compiler instanceof Clang
}

/** Get the compiler used to compile the translation unit the file `f` is part of. */
Compiler getCompiler(File f) {
  exists(Compilation compilation, TranslationUnit translationUnit |
    compilation.getAFileCompiled() = translationUnit and
    (f = translationUnit or f = translationUnit.getAUserFile())
  |
    if exists(int mimicIndex | compilation.getArgument(mimicIndex) = "--mimic")
    then
      exists(int mimicIndex |
        compilation.getArgument(mimicIndex) = "--mimic" and
        (
          compilation.getArgument(mimicIndex + 1).matches(getMimicMatch(result))
          or
          forall(string match | match = getMimicMatch(_) |
            not compilation.getArgument(mimicIndex + 1).matches(match)
          ) and
          result = UnsupportedCompiler()
        )
      )
    else result = UnsupportedCompiler()
  )
}
