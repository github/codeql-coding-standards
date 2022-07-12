/**
 * A module to reason about a SFINAE context.
 */

import cpp

predicate isInSFINAEContext(Element e) {
  exists(TemplateFunction f, Decltype t |
    (
      t = f.getType()
      or
      t = f.getAParameter().getType()
      // or default template arguments, but that information not available in the database.
    ) and
    (
      t = e or
      t.getExpr().getAChild*() = e
    )
  )
}
