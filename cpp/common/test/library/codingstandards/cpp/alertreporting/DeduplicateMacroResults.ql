import cpp
import codingstandards.cpp.alertreporting.DeduplicateMacroResults

class FindMe extends VariableDeclarationEntry {
  FindMe() { getType().toString() = "findme" }
}

module FindMeDedupeConfig implements DeduplicateMacroConfigSig<FindMe> {
  string describe(FindMe def) { result = def.getName() }
}

module FindMeReportConfig implements MacroReportConfigSig<FindMe> {
  bindingset[description]
  string getMessageSameResultInAllExpansions(Macro m, string description) {
    result = "Macro " + m.getName() + " always has findme var named " + description
  }

  string getMessageVariedResultInAllExpansions(Macro m) {
    result = "Macro " + m.getName() + " always has findme var, for example '$@'."
  }

  string getMessageResultInIsolatedExpansion(FindMe f) {
    result = "Invocation of macro $@ has findme var '" + f.getName() + "'."
  }

  string getMessageNotInMacro(FindMe f, Locatable extra, string extraString) {
    result = "Findme var '" + f.getName() + "'." and extra = f and extraString = ""
  }
}

import DeduplicateMacroResults<FindMe, FindMeDedupeConfig>
import DeduplicateMacroResults<FindMe, FindMeDedupeConfig>::Report<FindMeReportConfig>

from ReportResult report
select report.getPrimaryElement(), report.getMessage(), report.getOptionalPlaceholderLocatable(),
  report.getOptionalPlaceholderMessage()
