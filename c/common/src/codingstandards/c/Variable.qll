import cpp

class VlaVariable extends Variable {
  VlaVariable() { exists(VlaDeclStmt s | s.getVariable() = this) }

  /* Extractor workaround do determine if a VLA array has the specifier volatile.*/
  override predicate isVolatile() { this.getType().(ArrayType).getBaseType().isVolatile() }
}
