import cpp
import codingstandards.cpp.deadcode.UnusedVariables
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
    (
      getVariable() instanceof BasePotentiallyUnusedLocalVariable
      or
      getVariable() instanceof BasePotentiallyUnusedGlobalOrNamespaceVariable
    ) and
    not exists(VariableAccess access | access.getTarget() = getVariable()) and
    getVariable().getDefinition() = this
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

/* Module config to use the `DeduplicateUnusedMacroObjects::Report` module */
module ReportDeadObjectConfig implements MacroReportConfigSig<UnusedObjectDefinition> {
  bindingset[description]
  string getMessageSameResultInAllExpansions(Macro m, string description) {
    result = "Macro '" + m.getName() + "' defines unused object '" + description + "'."
  }

  string getMessageVariedResultInAllExpansions(Macro m) {
    result =
      "Macro '" + m.getName() +
        "' defines unused object with an invocation-dependent name, for example, '$@'."
  }

  string getMessageResultInIsolatedExpansion(UnusedObjectDefinition unused) {
    result = "Invocation of macro '$@' defines unused object '" + unused.getName() + "'."
  }

  string getMessageNotInMacro(UnusedObjectDefinition unused, Locatable optLoc1, string optStr1) {
    result = "Unused object '" + unused.getName() + "'." and
    optLoc1 = unused and
    optStr1 = "(ignored)"
  }
}

/* The object to report in queries of dead objects used in macros */
class ReportDeadObject extends DeduplicateUnusedMacroObjects::Report<ReportDeadObjectConfig>::ReportResult
{
  predicate hasAttrUnused() { getAResultElement().hasAttrUnused() }
}
