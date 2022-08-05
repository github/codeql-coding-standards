//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype IO4Query =
  TToctouRaceConditionsWhileAccessingFilesQuery() or
  TUseValidFormatStringsQuery()

predicate isIO4QueryMetadata(Query query, string queryId, string ruleId) {
  query =
    // `Query` instance for the `toctouRaceConditionsWhileAccessingFiles` query
    IO4Package::toctouRaceConditionsWhileAccessingFilesQuery() and
  queryId =
    // `@id` for the `toctouRaceConditionsWhileAccessingFiles` query
    "c/cert/toctou-race-conditions-while-accessing-files" and
  ruleId = "FIO45-C"
  or
  query =
    // `Query` instance for the `useValidFormatStrings` query
    IO4Package::useValidFormatStringsQuery() and
  queryId =
    // `@id` for the `useValidFormatStrings` query
    "c/cert/use-valid-format-strings" and
  ruleId = "FIO47-C"
}

module IO4Package {
  Query toctouRaceConditionsWhileAccessingFilesQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `toctouRaceConditionsWhileAccessingFiles` query
      TQueryC(TIO4PackageQuery(TToctouRaceConditionsWhileAccessingFilesQuery()))
  }

  Query useValidFormatStringsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `useValidFormatStrings` query
      TQueryC(TIO4PackageQuery(TUseValidFormatStringsQuery()))
  }
}
