import cpp

module SideEffect {
  abstract class ExclusionRange extends Expr { }

  abstract class Range extends Expr { }
}

module LocalSideEffect {
  abstract class Range extends SideEffect::Range { }
}

module GlobalSideEffect {
  abstract class Range extends SideEffect::Range { }
}

module ExternalSideEffect {
  abstract class Range extends SideEffect::Range { }
}
