/**
 * A module for runtime configuration settings specified in a `conding-standards.yml` file.
 */

import cpp
import semmle.code.cpp.XML
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.deviations.Deviations

/** A `coding-standards.xml` configuration file (usually generated from an YAML configuration file). */
class CodingStandardsFile extends XmlFile {
  CodingStandardsFile() {
    this.getBaseName() = "coding-standards.xml" and
    // Must be within the users source code.
    exists(this.getRelativePath())
  }
}

class CodingStandardsConfigSection extends XmlElement {
  CodingStandardsConfigSection() { getParent() instanceof CodingStandardsConfig }
}

/** A "Coding Standards" configuration file */
class CodingStandardsConfig extends XmlElement {
  CodingStandardsConfig() {
    any(CodingStandardsFile csf).getARootElement() = this and
    this.getName() = "codingstandards"
  }

  /** Get a section in this configuration file. */
  CodingStandardsConfigSection getASection() { result.getParent() = this }
}
