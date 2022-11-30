# Coding Standards: Guideline Recategorization

- [Coding Standards: Guideline Recategorization](#coding-standards-guideline-recategorization)
  - [Document management](#document-management)
  - [Introduction](#introduction)
  - [Design](#design)
    - [Guideline Recategorization Plan](#guideline-recategorization-plan)
  - [Implementation](#implementation)
    - [Specification and deviation](#specification-and-deviation)
    - [Specification validation](#specification-validation)
    - [SARIF rewriting](#sarif-rewriting)
  - [Non-MISRA standards](#non-misra-standards)

## Document management

**ID**: codeql-coding-standards/design/grp<br/>
**Status**: Draft

| Version | Date       | Author(s)       | Reviewer (s) |
| ------- | ---------- | --------------- | ------------ |
| 0.1     | 08/10/2022 | Remco Vermeulen | \<redacted\> |
| 0.2     | 10/25/2022 | Remco Vermeulen | Mauro Baludo, John Singleton |
| 0.3     | 11/30/2022 | Remco Vermeulen | Robert C. Seacord |

## Introduction

Each MISRA guideline belongs to a category that defines a policy to be followed to determine whether a guideline may be violated or not and whether a deviation is required.
The document [MISRA Compliance:2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) defines the following guideline categories, and their associated policies, in addition to a mechanism to recategorize guidelines.

- Mandatory guidelines - guidelines for which violation is never permitted.
- Required guidelines - guidelines which can only be violated when supported by a deviation.
- Advisory guidelines - recommendations for which violations are identified but are not required to be supported by a deviation.

Guideline recategorization is possible by means of a guideline recategorization plan (GRP). A GRP is a contract between the acquirer and supplier to determine how guidelines are applied.
The GRP defines the additional category Disapplied to be used for Advisory guidelines which are to be ignored. Any other category can be recategorized into stricter categories to ensure that a guideline adheres to the associated policy.
The following table summarizes the possible recategorizations.

| Category  | Recategorizations               |
| --------- | ------------------------------- |
| Mandatory |                                 |
| Required  | Mandatory                       |
| Advisory  | Disapplied, Required, Mandatory |

Other recategorizations are invalid, not applied, and reported to the user.

## Design

CodeQL Coding Standards includes a GRP, logic to apply the category policy to associated guidelines, and a SARIF result rewriter to reflect the new category in the results.
The application of a policy will modify the behavior of a CodeQL queries implementing guidelines as follows:

| Category   | Effect                                                               |
| ---------- | -------------------------------------------------------------------- |
| Mandatory  | Violations are reported, even if a deviation is applicable!          |
| Required   | Violations are reported unless there exists an applicable deviation. |
| Advisory   | Violations are reported unless there exists an applicable deviation. |
| Disapplied | Violations are not reported.                                         |

The SARIF rewrite updates the guideline category  in a SARIF result file by updating the query's tag information.

### Guideline Recategorization Plan

The GRE builds upon the configuration specification introduced for deviations by adding the additional primary section `guideline-recategorizations` to the `codeql-standards.yml` configuration file.
The `guideline-recategorizations` section will be a series of compact mappings in YAML with the keys:

- `rule-id` - the recategorized rule identifier.
- `category` - the category assigned to the rule identified by rule-id

For example:

```yaml
guideline-recategorizations:
- rule-id: “M5-0-17”
  category: “mandatory”
```

## Implementation

This section discusses the implementation of the [design](#design).

### Specification and deviation

The implementation relies on the existing rule meta-data and query exclusion mechanisms to apply policies associated with a rule’s category.
The rule meta-data already includes both the `query-id` and `rule-id` associated with a query and is available during query evaluation.
The rule meta-data must be extended with a category that contains the guideline’s category.

For example:

```ql
 query =
    // `Query` instance for the `pointerSubtractionOnDifferentArrays` query
    PointersPackage::pointerSubtractionOnDifferentArraysQuery() and
  queryId =
    // `@id` for the `pointerSubtractionOnDifferentArrays` query
    "cpp/autosar/pointer-subtraction-on-different-arrays" and
  ruleId = "M5-0-17" and
  category = “required”
```

The category defined by the rule meta-data and the category defined in the `guideline-recategorizations` of the applicable `codeql-standards.yml` configuration file specifies the *effective category* of a query.
The *effective category* is the category whose policy is applied during the evaluation of a query.
The policy of a category dictates if a result can be deviated from and implements the effect described in the design section.
The existing exclusion mechanism implemented in the predicate `isExcluded` defined in the `Exclusions.qll` library will be updated to consider the applicable policy of a guideline.

Note: This changes the behavior of deviations which will no longer have an impact on Mandatory guidelines! However, this will only affect MISRA C rules because there are no MISRA C++ Guidelines with a Mandatory category.

### Specification validation

To assist users with correctly specifying a GRP specification we can implement two validations mechanisms that validate the specification at two different points in a GRP life cycle.
The first validation mechanism performs syntax validation of the specification provided in the guideline-recategorizations section of a `codeql-standards.yml` configuration file and can provide feedback in any editor that supports JSON schemas published at the [JSON schema store](https://www.schemastore.org/json/).
A schema for `codeql-standards.yml` can be extended with the definition of `guideline-category` and the property `guideline-recategorizations`:

```json
{
    "$schema": "http://json-schema.org/draft-07/schema",
    "additionalProperties": false,
    "definitions": {
        "guideline-category": {
            "enum": [
                "mandatory",
                "required",
                "advisory",
                "disapplied"
            ]
        }
    },
    "properties": {
        "report-deviated-alerts": {...},
        "deviations": {...},
        "deviation-permits": {...},
        "guideline-recategorizations": {
            "description": "A set of guideline recategorizations",
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "rule-id": {
                        "type": "string"
                    },
                    "category": {
                        "$ref": "#/definitions/guideline-category"
                    }
                }
            }
        }
    },
    "required": [],
    "type": "object"
}
```

The second validation mechanism is the generation of a `guideline-recategorization-plan-report.md` containing alerts on semantically incorrect recategorizations.
That is, possible recategorizations that are not described as valid in the introduction.
Semantically invalid recategorizations are detected by examining a query’s categorization and its effective categorization (i.e., its applied recategorization).

In addition, an update to the `deviations_report.md` report’s invalidate deviations table provides feedback to users that apply deviations to guidelines with an effective category equal to `mandatory` which cannot be deviated from.
The changes to generate the new report and update the existing report will be made in the report generation script `scripts/reports/analysis_report.py`.

### SARIF rewriting

The *effective category* of a guideline is a runtime property that is not reflected in the SARIF result file and therefore is not visible in any viewer used to view the results (e.g., [Code Scanning](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/about-code-scanning)).
To ensure that users can view the *effective category* we need to rewrite the `@tags` query metadata property in the SARIF result file.
The `@tags` value is a JSON array located at the [JSON path](https://datatracker.ietf.org/wg/jsonpath/about/):

`$.runs[?(@.tool.driver.name="CodeQL")].tool.driver.rules[*].properties.tags`

The category tag has the form `external/<standard>/obligation/<category>`
Each guideline has an `external/<standard>/id/<rule-id>` tag that can be used to determine if a recategorization is applicable by performing a case insensitive compare on the `<rule-id>` extracted from the query’s tags array and the value of the rule-id key in a `guideline-recategorizations` section.
The rewriting replaces the `<category>` part in `external/<standard>/obligation/<category>` with the newly specified category and adds a new tag `external/<standard>/original-obligation/<category>` with the rule’s original category.

The rewrite process translates each entry in the guideline recategorization specification into a [JSON Patch](https://datatracker.ietf.org/doc/html/rfc6902) specific to the processed SARIF file. The JSON Patch is SARIF file specific due to its reliance on [JSON Pointer](https://www.rfc-editor.org/rfc/rfc6901) to locate the obligation tags.

A new SARIF file is created by applying the JSON Patch to the processed SARIF file.

## Non-MISRA standards

Guideline recategorization applies to rules adhering to the MISRA categorizations.
For standards that deviate from these conventions the rules have an *effective category* equivalent to MISRA’s *required* category.

CERT rules, for example, are handled in the same way as MISRA's rules recategorized to *required*.
