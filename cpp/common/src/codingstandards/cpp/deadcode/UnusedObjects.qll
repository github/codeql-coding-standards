import cpp
import codingstandards.cpp.alertreporting.HoldsForAllCopies
import codingstandards.cpp.alertreporting.DeduplicateMacroResults

/**
 * An unused object definition is an object, meaning a place in memory, whose definition could be
 * removed and the program would still compile.
 *
 * Technically, parameters may be considered objects, but they are covered by their own rule.
 * Similarly, members of structs are an addressable place in memory, and may be considered objects.
 * However, the member declaration is nothing but a layout offset, which is not an object.
 *
 * This therefore only reports variables (local or top level) which have a definition, and are
 * unused.
 */
class UnusedObjectDefinition extends VariableDeclarationEntry {
  UnusedObjectDefinition() {
    not exists(VariableAccess access | access.getTarget() = getVariable()) and
    getVariable().getDefinition() = this and
    not this instanceof ParameterDeclarationEntry and
    not getVariable() instanceof MemberVariable
  }

  /* Dead objects with these attributes are reported in the "strict" queries. */
  predicate hasAttrUnused() {
    getVariable().getAnAttribute().hasName(["unused", "used", "maybe_unused", "cleanup"])
  }
}

/* Configuration to use the `DedupMacroResults` module to reduce alert noise */
module UnusedObjectDefinitionDedupeConfig implements
  DeduplicateMacroConfigSig<UnusedObjectDefinition>
{
  string describe(UnusedObjectDefinition def) { result = def.getName() }
}

import DeduplicateMacroResults<UnusedObjectDefinition, UnusedObjectDefinitionDedupeConfig> as DeduplicateUnusedMacroObjects

/**
 * A macro invocation that only defines one unused variable.
 *
 * These are reported at the invocation site when the variable is unused.
 */
class MacroExpansionWithOnlyUnusedObjectDefinition extends MacroInvocation {
  UnusedObjectDefinition unusedObject;

  MacroExpansionWithOnlyUnusedObjectDefinition() {
    exists(DeclStmt stmt, Declaration decl |
      stmt = getStmt() and
      count(getStmt()) = 1 and
      count(stmt.getADeclaration()) = 1 and
      decl = stmt.getADeclaration() and
      count(decl.getADeclarationEntry()) = 1 and
      unusedObject = decl.getADeclarationEntry()
    ) and
    not exists(this.getParentInvocation())
  }

  UnusedObjectDefinition getUnusedObject() { result = unusedObject }
}

/**
 * An object definition which is not from a macro, and for which all copies are unused.
 *
 * Extends the `HoldForAllCopies::LogicalResultElement` class, because these dead objects are often
 * duplicated across defines and sometimes aren't marked used due to extractor bugs.
 */
class SimpleDeadObjectDefinition extends HoldsForAllCopies<UnusedObjectDefinition, VariableDeclarationEntry>::LogicalResultElement
{
  SimpleDeadObjectDefinition() { not getAnElementInstance().isInMacroExpansion() }

  string getName() { result = getAnElementInstance().getName() }
}

/* Make a type for reporting these two results in one query */
newtype TReportDeadObjectAtDefinition =
  TSimpleDeadObjectDefinition(SimpleDeadObjectDefinition def) or
  TMacroExpansionWithOnlyUnusedObject(MacroExpansionWithOnlyUnusedObjectDefinition def)

/**
 * Class to report simple dead object definitions, and dead objects from macros that do nothing but
 * define an object.
 *
 * To report all cases, make sure to also use the `DeduplicateUnusedMacroObjects::Report` module.
 *
 * To report these cases, use the methods:
 *  - `getMessage()`
 *  - `getPrimaryElement()`,
 *  - `getOptionalPlaceholderLocation()`
 *  - `getOptionalPlaceholderMessage()`
 */
class ReportDeadObjectAtDefinition extends TReportDeadObjectAtDefinition {
  string toString() { result = getMessage() }

  string getMessage() {
    exists(MacroExpansionWithOnlyUnusedObjectDefinition def |
      this = TMacroExpansionWithOnlyUnusedObject(def) and
      result = "Unused object definition '" + def.getUnusedObject().getName() + "' from macro '$@'."
    )
    or
    exists(SimpleDeadObjectDefinition def |
      this = TSimpleDeadObjectDefinition(def) and
      result = "Unused object definition '" + def.getName() + "'."
    )
  }

  predicate hasAttrUnused() {
    exists(MacroExpansionWithOnlyUnusedObjectDefinition def |
      this = TMacroExpansionWithOnlyUnusedObject(def) and
      def.getUnusedObject().hasAttrUnused()
    )
    or
    exists(SimpleDeadObjectDefinition def |
      this = TSimpleDeadObjectDefinition(def) and
      def.getAnElementInstance().hasAttrUnused()
    )
  }

  Element getPrimaryElement() {
    this = TMacroExpansionWithOnlyUnusedObject(result)
    or
    exists(SimpleDeadObjectDefinition def |
      this = TSimpleDeadObjectDefinition(def) and
      result = def.getAnElementInstance()
    )
  }

  Location getOptionalPlaceholderLocation() {
    exists(MacroExpansionWithOnlyUnusedObjectDefinition def |
      this = TMacroExpansionWithOnlyUnusedObject(def) and
      result = def.getMacro().getLocation()
    )
    or
    exists(SimpleDeadObjectDefinition def |
      this = TSimpleDeadObjectDefinition(def) and
      result = def.getAnElementInstance().getLocation()
    )
  }

  string getOptionalPlaceholderMessage() {
    exists(MacroExpansionWithOnlyUnusedObjectDefinition def |
      this = TMacroExpansionWithOnlyUnusedObject(def) and
      result = def.getMacroName()
    )
    or
    this = TSimpleDeadObjectDefinition(_) and
    result = ""
  }
}

/* Module config to use the `DeduplicateUnusedMacroObjects::Report` module */
module ReportDeadObjectInMacroConfig implements MacroReportConfigSig<UnusedObjectDefinition> {
  bindingset[description]
  string getMessageSameResultInAllExpansions(Macro m, string description) {
    result = "Macro '" + m.getName() + "' defines unused object '" + description + "'."
  }

  string getMessageVariedResultInAllExpansions(Macro m) {
    result = "Macro '" + m.getName() + "' defines unused object of varied names, for example, '$@'."
  }

  string getMessageResultInIsolatedExpansion(UnusedObjectDefinition unused) {
    result = "Invocation of macro '$@' defines unused object '" + unused.getName() + "'."
  }
}

/* The object to report in queries of dead objects used in macros */
class ReportDeadObjectInMacro extends DeduplicateUnusedMacroObjects::Report<ReportDeadObjectInMacroConfig>::ReportResultInMacro
{
  ReportDeadObjectInMacro() {
    // `MacroExpansionWithOnlyUnusedObjectDefinition` is reported by class `ReportDeadObjectAtDefinition`
    not getAResultMacroExpansion() instanceof MacroExpansionWithOnlyUnusedObjectDefinition
  }

  predicate hasAttrUnused() { getAResultMacroExpansion().getResultElement().hasAttrUnused() }
}
