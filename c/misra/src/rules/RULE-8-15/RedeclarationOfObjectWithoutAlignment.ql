/**
 * @id c/misra/redeclaration-of-object-without-alignment
 * @name RULE-8-15: Alignment should match between all declarations of an object
 * @description An object declared with an explicit alignment shall be explicitly aligned in all
 *              declarations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-15
 *       external/misra/c/2012/amendment3
 *       readability
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/**
 * Performance optimization; start query by joining attributes to declarations
 * rather than locations.
 *
 * Including the entry location also speeds up search.
 */
newtype TAttributeDeclLocation =
  TAttributeDeclLocationInfo(Attribute attribute, DeclarationEntry entry, Location entryLocation) {
    entry.getDeclaration().(Variable).getAnAttribute() = attribute and
    entryLocation = entry.getLocation()
  }

/**
 * Get a DeclarationEntry along with its explicitly declared Attributes.
 *
 * DeclarationEntry does not have a method for getting Attributes by default,
 * because an attribute declared on any DeclarationEntry affects all others,
 * and attributes really belong to the declared variable rather than the
 * declaration itself.
 *
 * In order to support this rule, we find for each attribute
 * - A declaration entry which
 * - corresponds to a variable associated with this attribute
 * - is in the same file as this attribute
 * - has identifier location after the attribute declaration
 * - has no other declaration entry between this one and the attribute.
 *
 * This should give us a highly reliable means of finding which attributes are
 * associated with which `DeclarationEntry`s.
 *
 * One note of caution: the location of the associated `Variable` must be
 * treated with caution, as calls to `getLocation()` on a redeclared `Variable`
 * can return multiple results. This class must act on `DeclarationEntry`s to
 * deliver reliable results.
 */
class DeclarationEntryAttribute extends Attribute {
  DeclarationEntry declarationEntry;
  Location location;
  Location declLocation;
  File file;
  TAttributeDeclLocation locInfo;

  DeclarationEntryAttribute() {
    locInfo = TAttributeDeclLocationInfo(this, declarationEntry, declLocation) and
    file = getFile() and
    location = getLocation() and
    declLocation = declarationEntry.getLocation() and
    declarationEntry.getDeclaration().(Variable).getAnAttribute() = this and
    declarationEntry.getFile() = file and
    location.isBefore(declLocation, _) and
    not exists(TAttributeDeclLocation blocInfo, DeclarationEntry betterFit, Location blocation |
      blocInfo = TAttributeDeclLocationInfo(this, betterFit, blocation) and
      not betterFit = declarationEntry and
      blocation = betterFit.getLocation() and
      betterFit.getFile() = file and
      betterFit.getDeclaration() = declarationEntry.getDeclaration() and
      blocation.isBefore(declLocation, _) and
      location.isBefore(blocation, _)
    )
  }

  DeclarationEntry getDeclarationEntry() { result = declarationEntry }
}

from DeclarationEntry unaligned, DeclarationEntry aligned, DeclarationEntryAttribute attribute
where
  not isExcluded(unaligned, AlignmentPackage::redeclarationOfObjectWithoutAlignmentQuery()) and
  attribute.hasName("_Alignas") and
  attribute.getDeclarationEntry() = aligned and
  aligned.getDeclaration() = unaligned.getDeclaration() and
  not exists(DeclarationEntryAttribute matchingAlignment |
    matchingAlignment.hasName("_Alignas") and
    matchingAlignment.getDeclarationEntry() = unaligned
  )
select unaligned,
  "Variable " + unaligned.getName() +
    " declared without explicit alignment to match $@ with alignment $@.", aligned,
  "other definition", attribute, attribute.toString()
