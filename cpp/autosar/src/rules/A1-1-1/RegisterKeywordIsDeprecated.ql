/**
 * @id cpp/autosar/register-keyword-is-deprecated
 * @name A1-1-1: The `register` keyword is deprecated
 * @description The `register` keyword is deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v
where
  not isExcluded(v, ToolchainPackage::registerKeywordIsDeprecatedQuery()) and
  v.hasSpecifier("register")
/*
 * Note: function parameters that are qualified by the 'register' keyword are
 * currently not supported by this query as there is no way to query for this
 * property in CodeQL yet.
 */

select v, "Use of the `register` specifier is deprecated in ISO C++14."
