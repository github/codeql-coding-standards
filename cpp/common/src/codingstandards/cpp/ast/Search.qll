import cpp
import qtil.Qtil

module OutermostSearch<Qtil::Signature<Element>::Type Find> {
  Find find(Element e) {
    // Do not return a result if there are multiple siblings to different `Find`s.
    result = unique(Find found | found = outermostSearchImpl(e))
  }

  private Find outermostSearchImpl(Element e) {
    if e instanceof Find
    then result = e
    else (
      result = outermostSearchImpl(e.(ExprStmt).getExpr())
      or
      result = outermostSearchImpl(e.(Stmt).getAChild())
      or
      result = outermostSearchImpl(e.(Expr).getAChild())
    )
  }
}
