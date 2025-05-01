/**
 * @id cpp/cert/reuse-of-reserved-identifier
 * @name DCL51-CPP: Redefining or undefining of keyword, special identifier, or reserved attribute token
 * @description A translation unit shall not #define or #undef names lexically identical to
 *              keywords, special identifiers, or reserved attribute tokens.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl51-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Lex

from PreprocessorDirective d, string s, string t
where
  not isExcluded(d, NamingPackage::reuseOfReservedIdentifierQuery()) and
  (
    s = d.(Macro).getName()
    or
    s = d.(PreprocessorUndef).getName()
  ) and
  (
    s = Lex::Cpp14::keyword() and t = "keyword"
    or
    s = Lex::Cpp14::specialIdentfier() and t = "special identifier"
    or
    s = Lex::Cpp14::reservedAttributeToken() and t = "reserved attribute token"
  )
select d, "Redefinition of $@ lexically identical to " + t + ".", d, s
