/**
 * A module for identifying deviations specified in a `conding-standards.yml` file.
 *
 * The deviation model is based on the "MISRA Compliance 2020" document.
 */

import cpp
import semmle.code.cpp.XML
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.Config
import CodeIdentifierDeviation

predicate applyDeviationsAtQueryLevel() {
  not exists(CodingStandardsReportDeviatedAlerts reportDeviatedResults |
    // There exists at least one `report-deviated-alerts: true` command in the repository
    reportDeviatedResults.getTextValue().trim() = "true"
  )
}

/** An element which tells the analysis whether to report deviated results. */
class CodingStandardsReportDeviatedAlerts extends XmlElement {
  CodingStandardsReportDeviatedAlerts() {
    getParent() instanceof CodingStandardsConfig and
    hasName("report-deviated-alerts")
  }
}

/** A container of deviation records. */
class DeviationRecords extends CodingStandardsConfigSection {
  DeviationRecords() { hasName("deviations") }
}

/** A container for the deviation permits records. */
class DeviationPermits extends CodingStandardsConfigSection {
  DeviationPermits() { hasName("deviation-permits") }
}

/** A deviation permit record, that is specified by a permit identifier */
class DeviationPermit extends XmlElement {
  DeviationPermit() {
    getParent() instanceof DeviationPermits and
    hasName("deviation-permits-entry")
  }

  string getRawScope() { result = getAChild("scope").getTextValue() }

  predicate hasScope() { exists(getRawScope()) }

  string getScope() { if hasScope() then result = getRawScope() else result = "" }

  string getRawJustification() { result = getAChild("justification").getTextValue() }

  predicate hasJustification() { exists(getRawJustification()) }

  string getJustification() {
    if hasJustification() then result = getRawJustification() else result = ""
  }

  string getRawBackground() { result = getAChild("background").getTextValue() }

  predicate hasBackground() { exists(getRawBackground()) }

  string getBackground() { if hasBackground() then result = getRawBackground() else result = "" }

  string getRawRequirements() { result = getAChild("requirements").getTextValue() }

  predicate hasRequirements() { exists(getRawRequirements()) }

  string getRequirements() {
    if hasRequirements() then result = getRawRequirements() else result = ""
  }

  string getRawPermitId() { result = getAChild("permit-id").getTextValue() }

  predicate hasPermitId() { exists(getRawPermitId()) }

  string getPermitId() {
    // In the case of the permit identifier we do not return an empty string because that can
    // result in spurious matches when an invalid permit without an id is specified, because
    // the record returns an empty string for the permit id if it is not specified.
    result = getRawPermitId()
  }

  predicate hasCodeIdentifier() { exists(getAChild("code-identifier")) }

  /** Gets the code identifier associated with this deviation record, if any. */
  string getCodeIdentifier() { result = getAChild("code-identifier").getTextValue() }

  /** Gets the `rule-id` specified for this record, if any. */
  string getRawRuleId() { result = getAChild("rule-id").getTextValue() }

  predicate hasRuleId() { exists(getRawRuleId()) }

  string getRuleId() { if hasRuleId() then result = getRawRuleId() else result = "" }

  /** Gets the `query-id` specified for this record, if any. */
  string getRawQueryId() { result = getAChild("query-id").getTextValue() }

  predicate hasQueryId() { exists(getRawQueryId()) }

  string getQueryId() { if hasQueryId() then result = getRawQueryId() else result = "" }

  /** If the permit is invalid, get a string describing a reason for it being invalid. */
  string getAnInvalidPermitReason() {
    not hasPermitId() and result = "Deviation permit does not specify a permit identifier."
    or
    exists(string childName |
      exists(getAChild(childName)) and
      not childName in [
          "permit-id", "rule-id", "query-id", "code-identifier", "scope", "justification",
          "background", "requirements"
        ] and
      result = "Deviation permit specifies unknown property `" + childName + "`."
    )
  }

  /** Holds if the deviation record is valid */
  predicate isDeviationPermitValid() { not exists(getAnInvalidPermitReason()) }
}

/** A deviation record, that is a specified rule or query */
class DeviationRecord extends XmlElement {
  DeviationRecord() {
    getParent() instanceof DeviationRecords and
    hasName("deviations-entry")
  }

  private string getRawScope() { result = getAChild("scope").getTextValue() }

  private string getRawJustification() { result = getAChild("justification").getTextValue() }

  private string getRawBackground() { result = getAChild("background").getTextValue() }

  private string getRawRequirements() { result = getAChild("requirements").getTextValue() }

  private string getRawPermitId() { result = getAChild("permit-id").getTextValue() }

  private XmlElement getRawRaisedBy() { result = getAChild("raised-by") }

  private string getRawRaisedByName() { result = getRawRaisedBy().getAChild("name").getTextValue() }

  private string getRawRaisedByDate() { result = getRawRaisedBy().getAChild("date").getTextValue() }

  private XmlElement getRawApprovedBy() { result = getAChild("approved-by") }

  private string getRawApprovedByName() {
    result = getRawApprovedBy().getAChild("name").getTextValue()
  }

  private string getRawApprovedByDate() {
    result = getRawApprovedBy().getAChild("date").getTextValue()
  }

  predicate hasRaisedBy() { exists(getRawRaisedBy()) }

  predicate hasApprovedBy() { exists(getRawApprovedBy()) }

  string getRaisedByName() {
    if exists(getRawRaisedByName()) then result = getRawRaisedByName() else result = ""
  }

  string getRaisedByDate() {
    if exists(getRawRaisedByDate()) then result = getRawRaisedByDate() else result = ""
  }

  string getApprovedByName() {
    if exists(getRawApprovedByName()) then result = getRawApprovedByName() else result = ""
  }

  string getApprovedByDate() {
    if exists(getRawApprovedByDate()) then result = getRawApprovedByDate() else result = ""
  }

  string getScope() {
    if exists(getRawScope())
    then result = getRawScope()
    else
      if getADeviationPermit().hasScope()
      then result = getADeviationPermit().getScope()
      else result = ""
  }

  string getJustification() {
    if exists(getRawJustification())
    then result = getRawJustification()
    else
      if getADeviationPermit().hasJustification()
      then result = getADeviationPermit().getJustification()
      else result = ""
  }

  string getBackground() {
    if exists(getRawBackground())
    then result = getRawBackground()
    else
      if getADeviationPermit().hasBackground()
      then result = getADeviationPermit().getBackground()
      else result = ""
  }

  string getRequirements() {
    if exists(getRawRequirements())
    then result = getRawRequirements()
    else
      if getADeviationPermit().hasRequirements()
      then result = getADeviationPermit().getRequirements()
      else result = ""
  }

  string getPermitId() {
    if exists(getRawPermitId()) then result = getRawPermitId() else result = ""
  }

  predicate hasPermitId() { exists(getRawPermitId()) }

  /** Gets the code identifier associated with this deviation record, if any. */
  string getCodeIdentifier() {
    if exists(getAChild("code-identifier").getTextValue())
    then result = getAChild("code-identifier").getTextValue()
    else result = getADeviationPermit().getCodeIdentifier()
  }

  /** Gets a code identifier deviation in code which starts or ends with the code identifier comment. */
  CodeIdentifierDeviation getACodeIdentifierDeviation() { this = result.getADeviationRecord() }

  /** Gets the `rule-id` specified for this record, if any. */
  private string getRawRuleId() { result = getAChild("rule-id").getTextValue() }

  string getRuleId() {
    if exists(getRawRuleId())
    then result = getRawRuleId()
    else
      if exists(DeviationPermit dp | dp.getPermitId() = getPermitId() and dp.hasRuleId())
      then
        exists(DeviationPermit dp |
          dp.getPermitId() = getPermitId() and dp.hasRuleId() and result = dp.getRuleId()
        )
      else result = ""
  }

  predicate hasRuleId() { not exists(string id | id = getRuleId() and id = "") }

  /** Gets the `query-id` specified for this record, if any. */
  private string getRawQueryId() { result = getAChild("query-id").getTextValue() }

  string getQueryId() {
    if exists(getRawQueryId())
    then result = getRawQueryId()
    else
      if getADeviationPermit().hasQueryId()
      then result = getADeviationPermit().getQueryId()
      else result = ""
  }

  predicate hasQueryId() { not exists(string id | id = getQueryId() and id = "") }

  DeviationPermit getADeviationPermit() {
    exists(DeviationPermit dp | dp.getPermitId() = getPermitId() | result = dp)
  }

  predicate hasADeviationPermit() { exists(getADeviationPermit()) }

  /** If the record is invalid, get a string describing a reason for it being invalid. */
  string getAnInvalidRecordReason() {
    not hasRuleId() and
    not hasQueryId() and
    result = "No rule-id and query-id specified for this deviation record."
    or
    hasRuleId() and
    not exists(Query q | q.getRuleId() = getRuleId()) and
    result =
      "The rule-id `" + getRuleId() + "` for this deviation matches none of the available queries."
    or
    hasQueryId() and
    not hasRuleId() and
    result =
      "A query-id of `" + getQueryId() +
        "` is specified for this deviation, but not rule-id is specified."
    or
    hasRuleId() and
    hasQueryId() and
    not exists(Query q | q.getQueryId() = getQueryId() and q.getRuleId() = getRuleId()) and
    result =
      "There is no query which matches both the rule-id `" + getRuleId() + "` and the query-id `" +
        getQueryId() + "`."
    or
    hasRaisedBy() and
    not hasApprovedBy() and
    result = "A deviation `raised-by` is specified without providing an `approved-by`."
    or
    not hasRaisedBy() and
    hasApprovedBy() and
    result = "A deviation `approved-by` is specified without providing a `raised-by`."
    or
    hasRaisedBy() and
    not (exists(getRawRaisedByName()) and exists(getRawRaisedByDate())) and
    result = "A deviation `raised-by` is specified without providing both a `name` and `date`."
    or
    hasApprovedBy() and
    not (exists(getRawApprovedByName()) and exists(getRawApprovedByDate())) and
    result = "A deviation `approved-by` is specified without providing both a `name` and `date`."
    or
    exists(DeviationPermit dp |
      dp = getADeviationPermit() and
      not dp.isDeviationPermitValid() and
      result = "A deviation with an invalid deviation permit identified by `" + getPermitId() + "`."
    )
    or
    hasPermitId() and
    not hasADeviationPermit() and
    result = "There is no deviation permit with id `" + getPermitId() + "`."
    or
    exists(Query q | q.getQueryId() = getQueryId() |
      not q.getEffectiveCategory().permitsDeviation() and
      result =
        "The deviation is applied to a query with the rule category '" +
          q.getEffectiveCategory().toString() + "' that does not permit a deviation."
    )
  }

  /** Holds if the deviation record is valid */
  predicate isDeviationRecordValid() { not exists(getAnInvalidRecordReason()) }

  /**
   * Gets the query or queries to which this deviation record applies.
   */
  Query getQuery() {
    isDeviationRecordValid() and
    result.getRuleId() = getRuleId()
  }

  /** Gets a `Container` representing a path this record applies to, if any. */
  private Container getPathAContainer() {
    not this.getFile().getParentContainer().getRelativePath() = "" and
    result.getRelativePath() =
      this.getFile().getParentContainer().getRelativePath() + "/" +
        getAChild("paths").getAChild("paths-entry").getTextValue()
    or
    this.getFile().getParentContainer().getRelativePath() = "" and
    result.getRelativePath() = getAChild("paths").getAChild("paths-entry").getTextValue()
  }

  private string getADeviationPath0() {
    if exists(getPathAContainer())
    then
      // Use the path, which will be relative to this file, if specified
      result = getPathAContainer().getRelativePath()
    else (
      // Otherwise, if no code identifier was supplied, it applies to the parent container of the
      // file itself
      not exists(getCodeIdentifier()) and
      result = this.getFile().getParentContainer().getRelativePath()
    )
  }

  /** Gets a path to which this deviation applies. */
  string getADeviationPath() {
    exists(string res |
      res = getADeviationPath0() and
      if res = "" then result = "(root)" else result = res
    )
  }

  cached
  predicate isDeviated(Query query, string deviationPath) {
    query = getQuery() and
    deviationPath = getADeviationPath0()
  }
}
