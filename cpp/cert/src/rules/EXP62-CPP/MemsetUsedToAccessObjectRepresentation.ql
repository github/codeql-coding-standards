/**
 * @id cpp/cert/memset-used-to-access-object-representation
 * @name EXP62-CPP: Do not use memset to access bits that are not part of the object's value
 * @description Do not use memset to access the bits of an object representation that are not part
 *              of the object's value representation.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp62-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import semmle.code.cpp.padding.Padding
import semmle.code.cpp.security.BufferAccess
import VirtualTable

/*
 * Considerations for exp62-cpp
 * ==============================
 *  source:
 *  <https://wiki.sei.cmu.edu/confluence/display/cplusplus/EXP62-CPP.+Do+not+access+the+bits+of+an+object+representation+that+are+not+part+of+the+object%27s+value+representation>
 *  We encode the following checks using codeql; columns are independent
 *  unless marked.
 *                          Class grouping
 *  ----------------------------------------------------------------
 *   info        operation  padding         bit-fields       vtable
 *  ----------------------------------------------------------------
 *   read/read   memcmp     bad             bad(if padding)  bad
 *   read/write  memcpy     ok              ok               bad
 *   write       memset     ok              ok               bad
 *  Groups of functions: The generic `memcmp` familiy of functions is
 *  captured by `MemcmpBA`; the generic memcpy group is found by
 *  `MemcpyBA`, the memset group by `MemsetBA`.
 *  Group of classes:
 *  - Padding: Every C++ class has padding, unless types are word-aligned
 *    (hardware specific) and sorted in decreasing size order.
 *    On a 64-bit system, 8-byte word boundaries:
 *    ,----
 *    | struct no_padding {
 *    |     int64_t f1;
 *    |     int8_t f2;
 *    | }
 *    `----
 *    has layout
 *     byte    0   1   2   3   4   5   6   7     8  9  a  b  c  d  e
 *    ---------------------------------------------------------------
 *     value  f1  f1  f1  f1  f1  f1  f1  f1    f2
 *    while
 *    ,----
 *    | struct with_padding {
 *    |     int8_t f2;
 *    |     int64_t f1;
 *    | }
 *    `----
 *    has layout
 *     byte    0  1  2  3  4  5  6  7     8   9  a   b   c   d   e
 *    --------------------------------------------------------------
 *     value  f2  -  -  -  -  -  -  -    f1  f1  f1  f1  f1  f1  f1
 *    where `-` is padding.
 *    With mixed-sized types, checking this is too complex.  E.g., a
 *    struct with entries of sized 8,4,4,2 is ok (grouped as 8/4,4/2), but
 *    8, 4, 2, 4 has padding (grouped as 8/4,2,Padding/4).
 *  - Vtable: Classes with virtual functions have vtables
 *  - bit-fields: are explicit in classes
 *  Given the above decision table, only the vtable-using classes need
 *  explicit identification.
 */

//1 do not cmp object presentation of PaddedType
//2 do not write to the object presnetation  of type with Vtable(method is virtual
from MemsetBA set, Class cl1
where
  not isExcluded(set, RepresentationPackage::memsetUsedToAccessObjectRepresentationQuery()) and
  hasVirtualtable(cl1) and
  set.getBuffer(_, _).(VariableAccess).getTarget().getUnspecifiedType().(PointerType).getBaseType() =
    cl1 //pointer type cast to pointer type
select set, set + " accesses bits which are not part of the object's value representation."
