import codingstandards.cpp.AlertReporting

/**
 * A configuration for deduplicating query results inside of macros.
 *
 * See doc comment on `DeduplicateMacroResults` module.
 */
signature module DeduplicateMacroConfigSig<ResultType ResultElement> {
  /**
   * Stringify the `ResultElement`. All `ResultElement`s that share an "identity" should stringify
   * to the same string to get proper results.
   */
  string describe(ResultElement re);
}

/**
 * A configuration for generating reports from reports that may or may not be duplicated across
 * macro expansions.
 *
 * See doc comment on `DeduplicateMacroResults` module.
 *
 * This signature is used to parameterize the module `DeduplicateMacroResults::Report`.
 */
signature module MacroReportConfigSig<ResultType ResultElement> {
  /* Create a message to describe this macro, with a string describing its `ResultElement`. */
  bindingset[description]
  string getMessageSameResultInAllExpansions(Macro m, string description);

  /* Create a message to describe this macro, using '$@' to describe an example `ResultElement`. */
  string getMessageVariedResultInAllExpansions(Macro m);

  /*
   * Create a message to describe this macro expansion which produces a `ResultElement`, using '$@'
   * to describe the relevant macro.
   */

  string getMessageResultInIsolatedExpansion(ResultElement element);
}

/**
 * A module for taking the results of `MacroUnwrapper<T>` and consolidating them.
 *
 * The module `MacroUnwrapper<T>` is great for simple alerts such as usage of banned functions. In
 * such cases, reporting "call to 'foo()' in macro 'M'" will only have one result even if the macro
 * is expanded multiple times.
 *
 * However, other queries may have a dynamic message which can vary per macro call site due to
 * token manipulation (`a ## b`), for instance, "Macro 'M' defines unused object 'generated_name_x'"
 * which will lead to hundreds of results if there are hundreds of such generated names.
 *
 * This module can be used to find and easily report non-compliant behavior, grouped by the macro
 * it originates in, regardless of whether the messages will exactly match.
 *
 * ## General Usage
 *
 * To use this macro, define a class for the relevant behavior, and a means of stringifying
 * relevant elements as a config, to parameterize the `DeduplicateMacroResults` module.
 *
 * ```
 *   class InvalidFoo extends Foo {
 *     InvalidFoo() { ... }
 *   }
 *
 *   module DeduplicateFooInMacrosConfig implements DeduplicateMacroConfigSig<InvalidFoo> {
 *     string describe(InvalidFoo foo) { result = ... }
 *   }
 *
 *   import DeduplicateMacroResults<InvalidFoo, DeduplicateFooInMacrosConfig> as DeduplicateFooInMacros;
 * ```
 *
 * This module exposes the following classes:
 *  - `PrimaryMacroSameResultElementInAllInvocations extends Macro`: Every invocation of this macro
 *    generates an `InvalidFoo` which stringifies to the same thing. Use the method
 *    `getResultElementDescription()` to get that shared string.
 *  - `PrimaryMacroDifferentResultElementInAllInvocations extends Macro`: Every invocation of this
 *    macro generates an `InvalidFoo`, but they do not all stringify to the same thing. Use the
 *    method `getExampleResultElement()` to get an *single* example `InvalidFoo` to help users fix
 *    and understand the issue.
 *  - `IsolatedMacroExpansionWithResultElement extends MacroInvocation`: An invocation of a macro
 *    which in this particular instance generates an `InvalidFoo`, while other invocations of the
 *    same macro do not.
 *
 * The three above classes all attempt to resolve to the most *specific* macro to the issue at
 * hand. For instance, if macro `M1` calls macro `M2` which expands to an `InvalidFoo`, then the
 * problem may be with `M2` (it is the most specific macro call here), or the problem may be with
 * `M2` (if all expansions of `M2` generate an `InvalidFoo` but not all expansions of `M1` do so).
 *
 * ## Generating Report Objects
 *
 * This module also can be used to more easily report issues across these cases, by implementing
 * `MacroReportConfigSig` and importing `DeduplicateMacroResults::Report::ReportResultInMacro`.
 *
 * ```
 *   module InvalidFooInMacroReportConfig implements MacroReportConfigSig<InvalidFoo> {
 *
 *     // ***Take care that usage of $@ is correct in the following predicates***!!!!
 *     bindingset[description]
 *     string getMessageSameResultInAllExpansions(Macro m, string description) {
 *       result = "Macro " + m.getName() + " always has invalid foo " + description
 *     }
 *
 *     string getMessageVariedResultInAllExpansions(Macro m) {
 *       result = "Macro " + m.getName() + " always has invalid foo, for example '$@'."
 *     }
 *
 *     string getMessageResultInIsolatedExpansion(InvalidFoo foo) {
 *       result = "Invocation of macro $@ has invalid foo '" + foo.getName() + "'."
 *     }
 *   }
 *
 *   import DeduplicateFooInMacros::Report<InvalidFooInMacroReportConfig> as Report;
 *
 *   from Report::ReportResultInMacro report
 *     where not excluded(report.getPrimaryElement(), ...)
 *   select report.getPrimaryElement(), report.getMessage(), report.getOptionalPlaceholderLocation(),
 *     report.getOptionalPlaceholderMessage()
 * ```
 *
 * Note that this does *not* (currently) generate a result for elements not contained by a macro.
 * To do report such cases, either add support for that in this module, or write a separate query
 * that reports `InvalidFoo` cases where not `.isInMacroExpansion()`.
 */
module DeduplicateMacroResults<
  ResultType ResultElement, DeduplicateMacroConfigSig<ResultElement> Config>
{
  /* A final class so that we may extend Macro. */
  final private class FinalMacro = Macro;

  /* Helper final class import so that we may reference/extend it. */
  final private class ResultMacroExpansion = MacroUnwrapper<ResultElement>::ResultMacroExpansion;

  /**
   * A macro for which all of its invocations produce an element that is described the same way.
   *
   * This is not necessarily the "primary" / most specific macro for these result elements.
   * This difference is captured in `PrimarySameResultElementInAllMacroInvocations`, and the two
   * classes are only separate to avoid non-monotonic recursion.
   */
  private class SameResultElementInAllMacroInvocations extends FinalMacro {
    string resultElementDescription;

    SameResultElementInAllMacroInvocations() {
      forex(MacroInvocation mi | mi = getAnInvocation() |
        Config::describe(mi.(ResultMacroExpansion).getResultElement()) = resultElementDescription
      )
    }

    string getResultElementDescription() { result = resultElementDescription }

    ResultElement getAResultElement() {
      result = getAnInvocation().(ResultMacroExpansion).getResultElement()
    }
  }

  /**
   * A macro for which all of its invocations produce an element that is described the same way.
   *
   * This is the necessarily the "primary" / most specific macro for these result elements.
   */
  class PrimaryMacroSameResultElementInAllInvocations extends SameResultElementInAllMacroInvocations
  {
    PrimaryMacroSameResultElementInAllInvocations() {
      not exists(MacroInvocation inner |
        inner.getParentInvocation() = getAnInvocation() and
        inner.getMacro() instanceof SameResultElementInAllMacroInvocations
      )
    }
  }

  /**
   * A expansion that generates a `ResultElement` that is uniquely described by the config.
   *
   * This is used so that we can find a single example invocation site to report as an example for
   * macros which generate an array of different `ResultElement`s that are described differently.
   *
   * For example, two macro invocations may be given the same arguments, and generate the same
   * `ResultElement`, while a third macro invocation is unique and generates a unique
   * `ResultElement`. We wish to direct the user to that unique example or we will show the user
   * two different reports for one underlying issue.
   */
  private class UniqueResultMacroExpansion extends ResultMacroExpansion {
    UniqueResultMacroExpansion() {
      not exists(ResultMacroExpansion other |
        not this = other and
        this.getMacroName() = other.getMacroName() and
        Config::describe(this.getResultElement()) = Config::describe(other.getResultElement())
      )
    }
  }

  /**
   * A macro for which all of its invocations produce an element, but they are not all described the
   * same way.
   *
   * This is not necessarily the "primary" / most specific macro for these result elements.
   * This difference is captured in `PrimaryDiferentResultElementInAllMacroInvocations`, and the two
   * classes are only separate to avoid non-monotonic recursion.
   */
  private class DifferentResultElementInAllMacroInvocations extends FinalMacro {
    ResultElement exampleResultElement;

    DifferentResultElementInAllMacroInvocations() {
      forex(MacroInvocation mi | mi = getAnInvocation() | mi instanceof ResultMacroExpansion) and
      count(getAnInvocation().(ResultMacroExpansion).getResultElement()) > 1 and
      exists(string description |
        description =
          rank[1](Config::describe(getAnInvocation().(UniqueResultMacroExpansion).getResultElement())
          ) and
        Config::describe(exampleResultElement) = description and
        exampleResultElement = getAnInvocation().(ResultMacroExpansion).getResultElement()
      )
    }

    ResultElement getExampleResultElement() { result = exampleResultElement }

    ResultElement getAResultElement() {
      result = getAnInvocation().(ResultMacroExpansion).getResultElement()
    }
  }

  /**
   * A macro for which all of its invocations produce an element, but they are not all described the
   * same way.
   *
   * This is "primary" / most specific macro for these result elements.
   */
  class PrimaryMacroDifferentResultElementInAllInvocations extends DifferentResultElementInAllMacroInvocations
  {
    PrimaryMacroDifferentResultElementInAllInvocations() {
      not exists(MacroInvocation inner |
        inner.getParentInvocation() = getAnInvocation() and
        inner.getMacro() instanceof DifferentResultElementInAllMacroInvocations
      )
    }
  }

  /*
   * Convenience predicate to know when invalid macro expansions have been reported at their macro
   * definition.
   */

  private predicate reported(Macro macro) {
    macro instanceof PrimaryMacroSameResultElementInAllInvocations or
    macro instanceof PrimaryMacroDifferentResultElementInAllInvocations
  }

  /**
   * A macro invocation for which the target macro does not always produce a `ResultElement`, but
   * this specific invocation of it does.
   *
   * This is "primary" / most specific macro for these result elements. It will also does not match
   * `MacroInvocation`s inside of a `MacroInvocation` of a `Macro` which always produces a
   * `ResultElement`, indicating that the real problem lies with that other `Macro` instead of with
   * this particular invocation.
   */
  class IsolatedMacroExpansionWithResultElement extends ResultMacroExpansion {
    IsolatedMacroExpansionWithResultElement() {
      not reported(getParentInvocation*().getMacro()) and
      not exists(MacroInvocation inner |
        reported(inner.getMacro()) and
        inner.getParentInvocation*() = this
      ) and
      not exists(ResultMacroExpansion moreSpecific |
        moreSpecific.getResultElement() = getResultElement() and
        moreSpecific.getParentInvocation+() = this
      )
    }
  }

  /**
   * A module for generating reports across the various cases of problematic macros, problematic
   * macro invocations.
   *
   * See the doc comment for the `DeduplicateMacroResults` module for more info.
   */
  module Report<MacroReportConfigSig<ResultElement> ReportConfig> {
    newtype TReportResultInMacro =
      TReportMacroResultWithSameName(PrimaryMacroSameResultElementInAllInvocations def) or
      TReportMacroResultWithVariedName(PrimaryMacroDifferentResultElementInAllInvocations def) or
      TReportIsolatedMacroResult(IsolatedMacroExpansionWithResultElement def)

    /**
     * An instance of a `ResultElement` to be reported to a user.
     *
     * To show a report, use the following methods:
     *  - `report.getPrimaryElement()`
     *  - `report.getMessage()`
     *  - `report.getOptionalPlaceholderLocation()`
     *  - `report.getOptionalPlaceholderMessage()`
     *
     * The values returned by these methods are configured by the `MacroReportConfigSig`
     * signature parameter.
     */
    class ReportResultInMacro extends TReportResultInMacro {
      string toString() { result = getMessage() }

      string getMessage() {
        exists(PrimaryMacroDifferentResultElementInAllInvocations def |
          this = TReportMacroResultWithVariedName(def) and
          result = ReportConfig::getMessageVariedResultInAllExpansions(def)
        )
        or
        exists(PrimaryMacroSameResultElementInAllInvocations def |
          this = TReportMacroResultWithSameName(def) and
          result =
            ReportConfig::getMessageSameResultInAllExpansions(def, def.getResultElementDescription())
        )
        or
        exists(IsolatedMacroExpansionWithResultElement def |
          this = TReportIsolatedMacroResult(def) and
          result = ReportConfig::getMessageResultInIsolatedExpansion(def.getResultElement())
        )
      }

      Element getPrimaryElement() {
        this = TReportMacroResultWithSameName(result)
        or
        this = TReportMacroResultWithVariedName(result)
        or
        this = TReportIsolatedMacroResult(result)
      }

      Location getOptionalPlaceholderLocation() {
        exists(PrimaryMacroDifferentResultElementInAllInvocations def |
          this = TReportMacroResultWithVariedName(def) and
          result = def.getExampleResultElement().getLocation()
        )
        or
        exists(PrimaryMacroSameResultElementInAllInvocations def |
          this = TReportMacroResultWithSameName(def) and
          result = def.getLocation()
        )
        or
        exists(IsolatedMacroExpansionWithResultElement def |
          this = TReportIsolatedMacroResult(def) and
          result = def.getMacro().getLocation()
        )
      }

      string getOptionalPlaceholderMessage() {
        exists(PrimaryMacroDifferentResultElementInAllInvocations def |
          this = TReportMacroResultWithVariedName(def) and
          result = Config::describe(def.getExampleResultElement())
        )
        or
        this = TReportMacroResultWithSameName(_) and
        result = "(ignored)"
        or
        this = TReportIsolatedMacroResult(_) and
        result = getMacro().getName()
      }

      Macro getMacro() {
        this = TReportMacroResultWithVariedName(result)
        or
        this = TReportMacroResultWithSameName(result)
        or
        exists(IsolatedMacroExpansionWithResultElement def |
          this = TReportIsolatedMacroResult(def) and
          result = def.getMacro()
        )
      }

      ResultMacroExpansion getAResultMacroExpansion() {
        exists(PrimaryMacroDifferentResultElementInAllInvocations def |
          this = TReportMacroResultWithVariedName(def) and
          result = def.getAnInvocation()
        )
        or
        exists(PrimaryMacroSameResultElementInAllInvocations def |
          this = TReportMacroResultWithSameName(def) and
          result = def.getAnInvocation()
        )
        or
        this = TReportIsolatedMacroResult(result)
      }
    }
  }
}
