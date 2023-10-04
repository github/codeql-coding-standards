import cpp

/**
 * This is a copy of HashCons module found the CodeQL standard library with the following changes:
 * - Extended the HashCons computation to statements and functions by implementing `HashConsStmt` and `HashConsFunc`.
 * - Modified how the `HCExpr` computes the hashcons for a `Variable`. Since we no longer compute hashcons in a single function
 *   we base the hascons on the name and type of a variable.
 */
private module HashCons {
  /*
   * Note to developers: the correctness of this module depends on the
   * definitions of HC, hashConsExpr, and analyzableExpr being kept in sync with
   * each other. If you change this module then make sure that the change is
   * symmetric across all three.
   */

  /** Used to represent the hash-cons of an expression. */
  cached
  private newtype HCExpr =
    HC_IntLiteral(int val, Type t) { mk_IntLiteral(val, t, _) } or
    HC_EnumConstantAccess(EnumConstant val, Type t) { mk_EnumConstantAccess(val, t, _) } or
    HC_FloatLiteral(float val, Type t) { mk_FloatLiteral(val, t, _) } or
    HC_StringLiteral(string val, Type t) { mk_StringLiteral(val, t, _) } or
    HC_Nullptr() { mk_Nullptr(_) } or
    HC_Variable(Type t, string name) { mk_Variable(t, name, _) } or
    HC_FieldAccess(HashConsExpr s, Field f) { mk_DotFieldAccess(s, f, _) } or
    HC_Deref(HashConsExpr p) { mk_Deref(p, _) } or
    HC_PointerFieldAccess(HashConsExpr qual, Field target) {
      mk_PointerFieldAccess(qual, target, _)
    } or
    HC_ThisExpr(Function fcn) { mk_ThisExpr(fcn, _) } or
    HC_ImplicitThisFieldAccess(Function fcn, Field target) {
      mk_ImplicitThisFieldAccess(fcn, target, _)
    } or
    HC_Conversion(Type t, HashConsExpr child) { mk_Conversion(t, child, _) } or
    HC_BinaryOp(HashConsExpr lhs, HashConsExpr rhs, string opname) {
      mk_BinaryOp(lhs, rhs, opname, _)
    } or
    HC_UnaryOp(HashConsExpr child, string opname) { mk_UnaryOp(child, opname, _) } or
    HC_ArrayAccess(HashConsExpr x, HashConsExpr i) { mk_ArrayAccess(x, i, _) } or
    HC_NonmemberFunctionCall(Function fcn, HC_Args args) { mk_NonmemberFunctionCall(fcn, args, _) } or
    HC_ExprCall(HashConsExpr hc, HC_Args args) { mk_ExprCall(hc, args, _) } or
    HC_MemberFunctionCall(Function trg, HashConsExpr qual, HC_Args args) {
      mk_MemberFunctionCall(trg, qual, args, _)
    } or
    // Hack to get around argument 0 of allocator calls being an error expression
    HC_AllocatorArgZero(Type t) { mk_AllocatorArgZero(t, _) } or
    HC_NewExpr(Type t, HC_Alloc alloc, HC_Init init) { mk_NewExpr(t, alloc, init, _) } or
    HC_NewArrayExpr(Type t, HC_Alloc alloc, HC_Extent extent, HC_Init init) {
      mk_NewArrayExpr(t, alloc, extent, init, _)
    } or
    HC_SizeofType(Type t) { mk_SizeofType(t, _) } or
    HC_SizeofExpr(HashConsExpr child) { mk_SizeofExpr(child, _) } or
    HC_AlignofType(Type t) { mk_AlignofType(t, _) } or
    HC_AlignofExpr(HashConsExpr child) { mk_AlignofExpr(child, _) } or
    HC_UuidofOperator(Type t) { mk_UuidofOperator(t, _) } or
    HC_TypeidType(Type t) { mk_TypeidType(t, _) } or
    HC_TypeidExpr(HashConsExpr child) { mk_TypeidExpr(child, _) } or
    HC_ClassAggregateLiteral(Class c, HC_Fields hcf) { mk_ClassAggregateLiteral(c, hcf, _) } or
    HC_ArrayAggregateLiteral(Type t, HC_Array hca) { mk_ArrayAggregateLiteral(t, hca, _) } or
    HC_DeleteExpr(HashConsExpr child) { mk_DeleteExpr(child, _) } or
    HC_DeleteArrayExpr(HashConsExpr child) { mk_DeleteArrayExpr(child, _) } or
    HC_ThrowExpr(HashConsExpr child) { mk_ThrowExpr(child, _) } or
    HC_ReThrowExpr() or
    HC_ConditionalExpr(HashConsExpr cond, HashConsExpr trueHC, HashConsExpr falseHC) {
      mk_ConditionalExpr(cond, trueHC, falseHC, _)
    } or
    HC_NoExceptExpr(HashConsExpr child) { mk_NoExceptExpr(child, _) } or
    // Any expression that is not handled by the cases above is
    // given a unique number based on the expression itself.
    HC_Unanalyzable(Expr e) { not analyzableExpr(e, _) }

  /** Used to implement optional init on `new` expressions */
  private newtype HC_Init =
    HC_NoInit() or
    HC_HasInit(HashConsExpr hc) { mk_HasInit(hc, _) }

  /**
   * Used to implement optional allocator call on `new` expressions
   */
  private newtype HC_Alloc =
    HC_NoAlloc() or
    HC_HasAlloc(HashConsExpr hc) { mk_HasAlloc(hc, _) }

  /**
   * Used to implement optional extent expression on `new[]` exprtessions
   */
  private newtype HC_Extent =
    HC_NoExtent() or
    HC_HasExtent(HashConsExpr hc) { mk_HasExtent(hc, _) }

  /** Used to implement hash-consing of argument lists */
  private newtype HC_Args =
    HC_EmptyArgs() { any() } or
    HC_ArgCons(HashConsExpr hc, int i, HC_Args list) { mk_ArgCons(hc, i, list, _) }

  /**
   * Used to implement hash-consing of struct initizializers.
   */
  private newtype HC_Fields =
    HC_EmptyFields(Class c) { exists(ClassAggregateLiteral cal | c = cal.getUnspecifiedType()) } or
    HC_FieldCons(Class c, int i, Field f, HashConsExpr hc, HC_Fields hcf) {
      mk_FieldCons(c, i, f, hc, hcf, _)
    }

  private newtype HC_Array =
    HC_EmptyArray(Type t) { exists(ArrayAggregateLiteral aal | aal.getUnspecifiedType() = t) } or
    HC_ArrayCons(Type t, int i, HashConsExpr hc, HC_Array hca) { mk_ArrayCons(t, i, hc, hca, _) }

  private newtype HCStmt =
    //HC_AsmStmt(AsmStmt s) or
    HC_BlockStmt(HC_Stmts stmts) { mk_BlockStmtCons(stmts, _) } or
    HC_CoReturnStmt(HashConsExpr operand, HC_OptCoReturnExpr expr) {
      mk_CoReturnStmtCons(operand, expr, _)
    } or
    HC_ComputedGotoStmt(HashConsExpr target) { mk_ComputedGotoStmtCons(target, _) } or
    /* Control Structure */
    /* ConditionalStmt */
    HC_ConstexprIfStmt(HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch) {
      mk_ConstexprIfStmtCons(condition, thenBranch, elseBranch, _)
    } or
    HC_IfStmt(HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch) {
      mk_IfStmtCons(condition, thenBranch, elseBranch, _)
    } or
    HC_SwitchStmt(HashConsExpr condition, HashConsStmt body) {
      mk_SwitchStmtCons(condition, body, _)
    } or
    /* End ConditionalStmt */
    /* Loop */
    HC_DoStmt(HashConsExpr condition, HashConsStmt body) { mk_DoStmtCons(condition, body, _) } or
    HC_ForStmt(HashConsStmt init, HashConsExpr condition, HashConsExpr update, HashConsStmt body) {
      mk_ForStmtCons(init, condition, update, body, _)
    } or
    HC_RangeBasedForStmt(HashConsExpr variable, HashConsExpr range, HashConsStmt body) {
      mk_RangeBasedForStmtCons(variable, range, body, _)
    } or
    HC_WhileStmt(HashConsExpr condition, HashConsStmt body) { mk_WhileStmtCons(condition, body, _) } or
    /* End Loop */
    /* End Control Structure */
    // HC_DeclStmt(DeclStmt s) or
    // HC_EmptyStmt(EmptyStmt s) or
    HC_ExprStmt(HashConsExpr e) { mk_ExprStmtCons(e, _) } or
    // Handler
    /* JumpStmt */
    HC_BreakStmt(HashConsStmt breakable) { mk_BreakStmtCons(breakable, _) } or
    HC_ContinueStmt(HashConsStmt continueable) { mk_ContinueStmtCons(continueable, _) } or
    HC_GotoStmt(HashConsStmt target, HC_OptGotoLabel label) { mk_GotoStmtCons(target, label, _) } or
    /* End JumpStmt */
    HC_LabelStmt(HC_OptLabelName name) { mk_LabelStmtCons(name, _) } or
    HC_MicrosoftTryStmt(HashConsStmt body) { mk_MicrosoftTryStmtCons(body, _) } or
    HC_ReturnStmt(HC_OptReturnExpr e) { mk_ReturnStmtCons(e, _) } or
    HC_SwitchCase(HashConsExpr e) { mk_SwitchCaseCons(e, _) } or
    // TODO: This relies on the TODO for the switch case where we need to hashcons the statements in a case.
    //HC_SwitchDefaultCase(DefaultCase s) or
    HC_TryStmt(HashConsStmt body) { mk_TryStmtCons(body, _) } or
    HC_CatchStmt(HashConsExpr parameter, HashConsStmt body) { mk_CatchStmtCons(parameter, body, _) } or
    // TODO implement hashcons for
    //HC_VlaDeclStmt(VlaDeclStmt s) or
    //HC_VlaDimensionStmt(VlaDimensionStmt s)
    HC_DeclStmt(HC_Decls d) { mk_DeclStmt(d, _) }

  private newtype HC_Decl =
    HC_VariableDecl(Type t, string name, HC_OptInitializer init) {
      mk_VariableDecl(t, name, init, _)
    }

  private newtype HC_Decls =
    HC_EmptyDecls() or
    HC_DeclCons(HC_Decl head, int i, HC_Decls list) { mk_DeclCons(head, i, list, _) }

  /* HashCons for sequences of statements. */
  private newtype HC_Stmts =
    HC_EmptyStmts() or
    HC_StmtCons(HashConsStmt hc, int i, HC_Stmts list) { mk_StmtCons(hc, i, list, _) }

  private newtype HC_OptCoReturnExpr =
    HC_NoCoReturnExpr() or
    HC_HasCoReturnExpr(HashConsExpr e) { exists(CoReturnStmt s | e = hashConsExpr(s.getExpr())) }

  private newtype HC_OptElseStmt =
    HC_NoElseStmt() or
    HC_HasElseStmt(HashConsStmt s) {
      exists(IfStmt ifStatement | s = hashConsStmt(ifStatement.getElse()))
      or
      exists(ConstexprIfStmt ifStatement | s = hashConsStmt(ifStatement.getElse()))
    }

  /* HashCons for optional expression. */
  private newtype HC_OptReturnExpr =
    HC_NoReturnExpr() or
    HC_HasReturnExpr(HashConsExpr hc) { exists(ReturnStmt s | hc = hashConsExpr(s.getExpr())) }

  private newtype HC_OptGotoLabel =
    HC_NoGotoLabel() or
    HC_HasGotoLabel(string label) { exists(GotoStmt s | label = s.getName()) }

  private newtype HC_OptLabelName =
    HC_NoLabelName() or
    HC_HasLabelName(string name) { exists(LabelStmt s | name = s.getName()) }

  private newtype HC_OptInitializer =
    HC_NoInitializer() or
    HC_HasInitializer(HashConsExpr hc) {
      exists(Variable v | hc = hashConsExpr(v.getInitializer().getExpr()))
    }

  private newtype HCFunc =
    HC_Function(Type t, string name, HC_Params params, HashConsStmt body) {
      mk_FunctionCons(t, name, params, body, _)
    }

  private newtype HC_Params =
    HC_NoParams() or
    HC_ParamCons(HashConsExpr hc, int i, HC_Params list) { mk_ParamCons(hc, i, list, _) }

  /**
   * HashConsExpr is the hash-cons of an expression. The relationship between `Expr`
   * and `HC` is many-to-one: every `Expr` has exactly one `HC`, but multiple
   * expressions can have the same `HC`. If two expressions have the same
   * `HC`, it means that they are structurally equal. The `HC` is an opaque
   * value. The only use for the `HC` of an expression is to find other
   * expressions that are structurally equal to it. Use the predicate
   * `hashConsExpr` to get the `HC` for an `Expr`.
   *
   * Note: `HC` has `toString` and `getLocation` methods, so that it can be
   * displayed in a results list. These work by picking an arbitrary
   * expression with this `HC` and using its `toString` and `getLocation`
   * methods.
   */
  class HashConsExpr extends HCExpr {
    /** Gets an expression that has this HC. */
    Expr getAnExpr() { this = hashConsExpr(result) }

    /** Gets the kind of the HC. This can be useful for debugging. */
    string getKind() {
      if this instanceof HC_IntLiteral
      then result = "IntLiteral"
      else
        if this instanceof HC_EnumConstantAccess
        then result = "EnumConstantAccess"
        else
          if this instanceof HC_FloatLiteral
          then result = "FloatLiteral"
          else
            if this instanceof HC_StringLiteral
            then result = "StringLiteral"
            else
              if this instanceof HC_Nullptr
              then result = "Nullptr"
              else
                if this instanceof HC_Variable
                then result = "Variable"
                else
                  if this instanceof HC_FieldAccess
                  then result = "FieldAccess"
                  else
                    if this instanceof HC_Deref
                    then result = "Deref"
                    else
                      if this instanceof HC_ThisExpr
                      then result = "ThisExpr"
                      else
                        if this instanceof HC_Conversion
                        then result = "Conversion"
                        else
                          if this instanceof HC_BinaryOp
                          then result = "BinaryOp"
                          else
                            if this instanceof HC_UnaryOp
                            then result = "UnaryOp"
                            else
                              if this instanceof HC_ArrayAccess
                              then result = "ArrayAccess"
                              else
                                if this instanceof HC_Unanalyzable
                                then result = "Unanalyzable"
                                else
                                  if this instanceof HC_NonmemberFunctionCall
                                  then result = "NonmemberFunctionCall"
                                  else
                                    if this instanceof HC_MemberFunctionCall
                                    then result = "MemberFunctionCall"
                                    else
                                      if this instanceof HC_NewExpr
                                      then result = "NewExpr"
                                      else
                                        if this instanceof HC_NewArrayExpr
                                        then result = "NewArrayExpr"
                                        else
                                          if this instanceof HC_SizeofType
                                          then result = "SizeofTypeOperator"
                                          else
                                            if this instanceof HC_SizeofExpr
                                            then result = "SizeofExprOperator"
                                            else
                                              if this instanceof HC_AlignofType
                                              then result = "AlignofTypeOperator"
                                              else
                                                if this instanceof HC_AlignofExpr
                                                then result = "AlignofExprOperator"
                                                else
                                                  if this instanceof HC_UuidofOperator
                                                  then result = "UuidofOperator"
                                                  else
                                                    if this instanceof HC_TypeidType
                                                    then result = "TypeidType"
                                                    else
                                                      if this instanceof HC_TypeidExpr
                                                      then result = "TypeidExpr"
                                                      else
                                                        if this instanceof HC_ArrayAggregateLiteral
                                                        then result = "ArrayAggregateLiteral"
                                                        else
                                                          if
                                                            this instanceof HC_ClassAggregateLiteral
                                                          then result = "ClassAggregateLiteral"
                                                          else
                                                            if this instanceof HC_DeleteExpr
                                                            then result = "DeleteExpr"
                                                            else
                                                              if this instanceof HC_DeleteArrayExpr
                                                              then result = "DeleteArrayExpr"
                                                              else
                                                                if this instanceof HC_ThrowExpr
                                                                then result = "ThrowExpr"
                                                                else
                                                                  if this instanceof HC_ReThrowExpr
                                                                  then result = "ReThrowExpr"
                                                                  else
                                                                    if this instanceof HC_ExprCall
                                                                    then result = "ExprCall"
                                                                    else
                                                                      if
                                                                        this instanceof
                                                                          HC_ConditionalExpr
                                                                      then
                                                                        result = "ConditionalExpr"
                                                                      else
                                                                        if
                                                                          this instanceof
                                                                            HC_NoExceptExpr
                                                                        then result = "NoExceptExpr"
                                                                        else
                                                                          if
                                                                            this instanceof
                                                                              HC_AllocatorArgZero
                                                                          then
                                                                            result =
                                                                              "AllocatorArgZero"
                                                                          else result = "error"
    }

    /**
     * Gets an example of an expression with this HC.
     * This is useful for things like implementing toString().
     */
    private Expr exampleExpr() {
      // Pick the expression with the minimum source location string. This is
      // just an arbitrary way to pick an expression with this `HC`.
      result =
        min(Expr e |
          this = hashConsExpr(e)
        |
          e
          order by
            exampleLocationString(e.getLocation()), e.getLocation().getStartColumn(),
            e.getLocation().getEndLine(), e.getLocation().getEndColumn()
        )
    }

    /** Gets a textual representation of this element. */
    string toString() { result = exampleExpr().toString() }

    /** Gets the primary location of this element. */
    Location getLocation() { result = exampleExpr().getLocation() }
  }

  /**
   * HashConsStmt is the hash-cons of an statement. The relationship between `Stmt`
   * and `HC` is many-to-one: every `Stmt` has exactly one `HC`, but multiple
   * statements can have the same `HC`. If two statements have the same
   * `HC`, it means that they are structurally equal. The `HC` is an opaque
   * value. The only use for the `HC` of an statement is to find other
   * statements that are structurally equal to it. Use the predicate
   * `hashConsStmt` to get the `HC` for an `Stmt`.
   *
   * Note: `HC` has `toString` and `getLocation` methods, so that it can be
   * displayed in a results list. These work by picking an arbitrary
   * statement with this `HC` and using its `toString` and `getLocation`
   * methods.
   */
  class HashConsStmt extends HCStmt {
    Stmt getAStmt() { this = hashConsStmt(result) }

    /** Gets the kind of the HC. This can be useful for debugging. */
    string getKind() {
      if this instanceof HC_BlockStmt
      then result = "BlockStmt"
      else
        if this instanceof HC_CoReturnStmt
        then result = "CoReturnStmt"
        else
          if this instanceof HC_ComputedGotoStmt
          then result = "ComputedGotoStmt"
          else
            if this instanceof HC_ConstexprIfStmt
            then result = "ConstexprIfStmt"
            else
              if this instanceof HC_IfStmt
              then result = "IfStmt"
              else
                if this instanceof HC_SwitchStmt
                then result = "SwitchStmt"
                else
                  if this instanceof HC_DoStmt
                  then result = "DoStmt"
                  else
                    if this instanceof HC_ForStmt
                    then result = "ForStmt"
                    else
                      if this instanceof HC_RangeBasedForStmt
                      then result = "RangeBasedForStmt"
                      else
                        if this instanceof HC_WhileStmt
                        then result = "WhileStmt"
                        else
                          if this instanceof HC_ExprStmt
                          then result = "ExprStmt"
                          else
                            if this instanceof HC_BreakStmt
                            then result = "BreakStmt"
                            else
                              if this instanceof HC_ContinueStmt
                              then result = "ContinueStmt"
                              else
                                if this instanceof HC_GotoStmt
                                then result = "GotoStmt"
                                else
                                  if this instanceof HC_LabelStmt
                                  then result = "LabelStmt"
                                  else
                                    if this instanceof HC_MicrosoftTryStmt
                                    then result = "MicrosoftTryStmt"
                                    else
                                      if this instanceof HC_ReturnStmt
                                      then result = "ReturnStmt"
                                      else
                                        if this instanceof HC_SwitchCase
                                        then result = "SwitchCase"
                                        else
                                          if this instanceof HC_TryStmt
                                          then result = "TryStmt"
                                          else
                                            if this instanceof HC_CatchStmt
                                            then result = "CatchStmt"
                                            else
                                              if this instanceof HC_DeclStmt
                                              then result = "DeclStmt"
                                              else result = "error"
    }

    /**
     * Gets an example of a statement with this HC.
     * This is useful for things like implementing toString().
     */
    private Stmt exampleStmt() {
      // Pick the statement with the minimum source location string. This is
      // just an arbitrary way to pick an statement with this `HC`.
      result =
        min(Stmt s |
          this = hashConsStmt(s)
        |
          s
          order by
            exampleLocationString(s.getLocation()), s.getLocation().getStartColumn(),
            s.getLocation().getEndLine(), s.getLocation().getEndColumn()
        )
    }

    /** Gets a textual representation of this element. */
    string toString() { result = exampleStmt().toString() }

    /** Gets the primary location of this element. */
    Location getLocation() { result = exampleStmt().getLocation() }
  }

  class HashConsFunc extends HCFunc {
    Function getAFunction() { this = hashConsFunc(result) }

    /** Gets the kind of the HC. This can be useful for debugging. */
    string getKind() {
      if this instanceof HC_Function then result = "Function" else result = "error"
    }

    /**
     * Gets an example of a statement with this HC.
     * This is useful for things like implementing toString().
     */
    private Function exampleFunc() {
      // Pick the statement with the minimum source location string. This is
      // just an arbitrary way to pick an statement with this `HC`.
      result =
        min(Function f |
          this = hashConsFunc(f)
        |
          f
          order by
            exampleLocationString(f.getLocation()), f.getLocation().getStartColumn(),
            f.getLocation().getEndLine(), f.getLocation().getEndColumn()
        )
    }

    /** Gets a textual representation of this element. */
    string toString() { result = exampleFunc().toString() }

    /** Gets the primary location of this element. */
    Location getLocation() { result = exampleFunc().getLocation() }
  }

  /**
   * Gets the absolute path of a known location or "~" for an unknown location. This ensures that
   * expressions with unknown locations are ordered after expressions with known locations when
   * selecting an example expression for a HashConsExpr value.
   */
  private string exampleLocationString(Location l) {
    if l instanceof UnknownLocation then result = "~" else result = l.getFile().getAbsolutePath()
  }

  private predicate analyzableIntLiteral(Literal e) {
    strictcount(e.getValue().toInt()) = 1 and
    strictcount(e.getUnspecifiedType()) = 1 and
    e.getUnspecifiedType() instanceof IntegralType
  }

  private predicate mk_IntLiteral(int val, Type t, Expr e) {
    analyzableIntLiteral(e) and
    val = e.getValue().toInt() and
    t = e.getUnspecifiedType()
  }

  private predicate analyzableEnumConstantAccess(EnumConstantAccess e) {
    strictcount(e.getValue().toInt()) = 1 and
    strictcount(e.getUnspecifiedType()) = 1 and
    e.getUnspecifiedType() instanceof Enum
  }

  private predicate mk_EnumConstantAccess(EnumConstant val, Type t, Expr e) {
    analyzableEnumConstantAccess(e) and
    val = e.(EnumConstantAccess).getTarget() and
    t = e.getUnspecifiedType()
  }

  private predicate analyzableFloatLiteral(Literal e) {
    strictcount(e.getValue().toFloat()) = 1 and
    strictcount(e.getUnspecifiedType()) = 1 and
    e.getUnspecifiedType() instanceof FloatingPointType
  }

  private predicate mk_FloatLiteral(float val, Type t, Expr e) {
    analyzableFloatLiteral(e) and
    val = e.getValue().toFloat() and
    t = e.getUnspecifiedType()
  }

  private predicate analyzableNullptr(NullValue e) {
    strictcount(e.getUnspecifiedType()) = 1 and
    e.getType() instanceof NullPointerType
  }

  private predicate mk_Nullptr(Expr e) { analyzableNullptr(e) }

  private predicate analyzableStringLiteral(Literal e) {
    strictcount(e.getValue()) = 1 and
    strictcount(e.getUnspecifiedType()) = 1 and
    e.getUnspecifiedType().(ArrayType).getBaseType() instanceof CharType
  }

  private predicate mk_StringLiteral(string val, Type t, Expr e) {
    analyzableStringLiteral(e) and
    val = e.getValue() and
    t = e.getUnspecifiedType() and
    t.(ArrayType).getBaseType() instanceof CharType
  }

  private predicate analyzableDotFieldAccess(DotFieldAccess access) {
    strictcount(access.getTarget()) = 1 and
    strictcount(access.getQualifier().getFullyConverted()) = 1
  }

  private predicate mk_DotFieldAccess(HashConsExpr qualifier, Field target, DotFieldAccess access) {
    analyzableDotFieldAccess(access) and
    target = access.getTarget() and
    qualifier = hashConsExpr(access.getQualifier().getFullyConverted())
  }

  private predicate analyzablePointerFieldAccess(PointerFieldAccess access) {
    strictcount(access.getTarget()) = 1 and
    strictcount(access.getQualifier().getFullyConverted()) = 1
  }

  private predicate mk_PointerFieldAccess(
    HashConsExpr qualifier, Field target, PointerFieldAccess access
  ) {
    analyzablePointerFieldAccess(access) and
    target = access.getTarget() and
    qualifier = hashConsExpr(access.getQualifier().getFullyConverted())
  }

  private predicate analyzableImplicitThisFieldAccess(ImplicitThisFieldAccess access) {
    strictcount(access.getTarget()) = 1 and
    strictcount(access.getEnclosingFunction()) = 1
  }

  private predicate mk_ImplicitThisFieldAccess(
    Function fcn, Field target, ImplicitThisFieldAccess access
  ) {
    analyzableImplicitThisFieldAccess(access) and
    target = access.getTarget() and
    fcn = access.getEnclosingFunction()
  }

  private predicate analyzableVariable(VariableAccess access) {
    not access instanceof FieldAccess and
    strictcount(access.getTarget()) = 1
  }

  /* Note: This changed from the original HashCons module to be able to find structural equivalent expression. */
  private predicate mk_Variable(Type t, string name, VariableAccess access) {
    analyzableVariable(access) and
    exists(Variable v |
      v = access.getTarget() and t = v.getUnspecifiedType() and name = v.getName()
    )
  }

  private predicate analyzableConversion(Conversion conv) {
    strictcount(conv.getUnspecifiedType()) = 1 and
    strictcount(conv.getExpr()) = 1
  }

  private predicate mk_Conversion(Type t, HashConsExpr child, Conversion conv) {
    analyzableConversion(conv) and
    t = conv.getUnspecifiedType() and
    child = hashConsExpr(conv.getExpr())
  }

  private predicate analyzableBinaryOp(BinaryOperation op) {
    strictcount(op.getLeftOperand().getFullyConverted()) = 1 and
    strictcount(op.getRightOperand().getFullyConverted()) = 1 and
    strictcount(op.getOperator()) = 1
  }

  private predicate mk_BinaryOp(
    HashConsExpr lhs, HashConsExpr rhs, string opname, BinaryOperation op
  ) {
    analyzableBinaryOp(op) and
    lhs = hashConsExpr(op.getLeftOperand().getFullyConverted()) and
    rhs = hashConsExpr(op.getRightOperand().getFullyConverted()) and
    opname = op.getOperator()
  }

  private predicate analyzableUnaryOp(UnaryOperation op) {
    not op instanceof PointerDereferenceExpr and
    strictcount(op.getOperand().getFullyConverted()) = 1 and
    strictcount(op.getOperator()) = 1
  }

  private predicate mk_UnaryOp(HashConsExpr child, string opname, UnaryOperation op) {
    analyzableUnaryOp(op) and
    child = hashConsExpr(op.getOperand().getFullyConverted()) and
    opname = op.getOperator()
  }

  private predicate analyzableThisExpr(ThisExpr thisExpr) {
    strictcount(thisExpr.getEnclosingFunction()) = 1
  }

  private predicate mk_ThisExpr(Function fcn, ThisExpr thisExpr) {
    analyzableThisExpr(thisExpr) and
    fcn = thisExpr.getEnclosingFunction()
  }

  private predicate analyzableArrayAccess(ArrayExpr ae) {
    strictcount(ae.getArrayBase().getFullyConverted()) = 1 and
    strictcount(ae.getArrayOffset().getFullyConverted()) = 1
  }

  private predicate mk_ArrayAccess(HashConsExpr base, HashConsExpr offset, ArrayExpr ae) {
    analyzableArrayAccess(ae) and
    base = hashConsExpr(ae.getArrayBase().getFullyConverted()) and
    offset = hashConsExpr(ae.getArrayOffset().getFullyConverted())
  }

  private predicate analyzablePointerDereferenceExpr(PointerDereferenceExpr deref) {
    strictcount(deref.getOperand().getFullyConverted()) = 1
  }

  private predicate mk_Deref(HashConsExpr p, PointerDereferenceExpr deref) {
    analyzablePointerDereferenceExpr(deref) and
    p = hashConsExpr(deref.getOperand().getFullyConverted())
  }

  private predicate analyzableNonmemberFunctionCall(FunctionCall fc) {
    forall(int i | i in [0 .. fc.getNumberOfArguments() - 1] |
      strictcount(fc.getArgument(i).getFullyConverted()) = 1
    ) and
    strictcount(fc.getTarget()) = 1 and
    not exists(fc.getQualifier())
  }

  private predicate mk_NonmemberFunctionCall(Function fcn, HC_Args args, FunctionCall fc) {
    fc.getTarget() = fcn and
    analyzableNonmemberFunctionCall(fc) and
    (
      exists(HashConsExpr head, HC_Args tail |
        mk_ArgConsInner(head, tail, fc.getNumberOfArguments() - 1, args, fc)
      )
      or
      fc.getNumberOfArguments() = 0 and
      args = HC_EmptyArgs()
    )
  }

  private predicate analyzableExprCall(ExprCall ec) {
    forall(int i | i in [0 .. ec.getNumberOfArguments() - 1] |
      strictcount(ec.getArgument(i).getFullyConverted()) = 1
    ) and
    strictcount(ec.getExpr().getFullyConverted()) = 1
  }

  private predicate mk_ExprCall(HashConsExpr hc, HC_Args args, ExprCall ec) {
    hc.getAnExpr() = ec.getExpr() and
    (
      exists(HashConsExpr head, HC_Args tail |
        mk_ArgConsInner(head, tail, ec.getNumberOfArguments() - 1, args, ec)
      )
      or
      ec.getNumberOfArguments() = 0 and
      args = HC_EmptyArgs()
    )
  }

  private predicate analyzableMemberFunctionCall(FunctionCall fc) {
    forall(int i | i in [0 .. fc.getNumberOfArguments() - 1] |
      strictcount(fc.getArgument(i).getFullyConverted()) = 1
    ) and
    strictcount(fc.getTarget()) = 1 and
    strictcount(fc.getQualifier().getFullyConverted()) = 1
  }

  private predicate mk_MemberFunctionCall(
    Function fcn, HashConsExpr qual, HC_Args args, FunctionCall fc
  ) {
    fc.getTarget() = fcn and
    analyzableMemberFunctionCall(fc) and
    hashConsExpr(fc.getQualifier().getFullyConverted()) = qual and
    (
      exists(HashConsExpr head, HC_Args tail |
        mk_ArgConsInner(head, tail, fc.getNumberOfArguments() - 1, args, fc)
      )
      or
      fc.getNumberOfArguments() = 0 and
      args = HC_EmptyArgs()
    )
  }

  private predicate analyzableCall(Call c) {
    analyzableNonmemberFunctionCall(c)
    or
    analyzableMemberFunctionCall(c)
    or
    analyzableExprCall(c)
  }

  /**
   * Holds if `fc` is a call to `fcn`, `fc`'s first `i` arguments have hash-cons
   * `list`, and `fc`'s argument at index `i` has hash-cons `hc`.
   */
  private predicate mk_ArgCons(HashConsExpr hc, int i, HC_Args list, Call c) {
    analyzableCall(c) and
    hc = hashConsExpr(c.getArgument(i).getFullyConverted()) and
    (
      exists(HashConsExpr head, HC_Args tail |
        mk_ArgConsInner(head, tail, i - 1, list, c) and
        i > 0
      )
      or
      i = 0 and
      list = HC_EmptyArgs()
    )
  }

  // avoid a join ordering issue
  pragma[noopt]
  private predicate mk_ArgConsInner(HashConsExpr head, HC_Args tail, int i, HC_Args list, Call c) {
    list = HC_ArgCons(head, i, tail) and
    mk_ArgCons(head, i, tail, c)
  }

  /**
   * The 0th argument of an allocator call in a new expression is always an error expression;
   * this works around it
   */
  private predicate analyzableAllocatorArgZero(ErrorExpr e) {
    exists(NewOrNewArrayExpr new |
      new.getAllocatorCall().getChild(0) = e and
      strictcount(new.getUnspecifiedType()) = 1
    ) and
    strictcount(NewOrNewArrayExpr new | new.getAllocatorCall().getChild(0) = e) = 1
  }

  private predicate mk_AllocatorArgZero(Type t, ErrorExpr e) {
    analyzableAllocatorArgZero(e) and
    exists(NewOrNewArrayExpr new |
      new.getAllocatorCall().getChild(0) = e and
      t = new.getUnspecifiedType()
    )
  }

  private predicate mk_HasInit(HashConsExpr hc, NewOrNewArrayExpr new) {
    hc = hashConsExpr(new.(NewExpr).getInitializer().getFullyConverted()) or
    hc = hashConsExpr(new.(NewArrayExpr).getInitializer().getFullyConverted())
  }

  private predicate mk_HasAlloc(HashConsExpr hc, NewOrNewArrayExpr new) {
    hc = hashConsExpr(new.(NewExpr).getAllocatorCall().getFullyConverted()) or
    hc = hashConsExpr(new.(NewArrayExpr).getAllocatorCall().getFullyConverted())
  }

  private predicate mk_HasExtent(HashConsExpr hc, NewArrayExpr new) {
    hc = hashConsExpr(new.(NewArrayExpr).getExtent().getFullyConverted())
  }

  private predicate analyzableNewExpr(NewExpr new) {
    strictcount(new.getAllocatedType().getUnspecifiedType()) = 1 and
    count(new.getAllocatorCall().getFullyConverted()) <= 1 and
    count(new.getInitializer().getFullyConverted()) <= 1
  }

  private predicate mk_NewExpr(Type t, HC_Alloc alloc, HC_Init init, NewExpr new) {
    analyzableNewExpr(new) and
    t = new.getAllocatedType().getUnspecifiedType() and
    (
      alloc = HC_HasAlloc(hashConsExpr(new.getAllocatorCall().getFullyConverted()))
      or
      not exists(new.getAllocatorCall().getFullyConverted()) and
      alloc = HC_NoAlloc()
    ) and
    (
      init = HC_HasInit(hashConsExpr(new.getInitializer().getFullyConverted()))
      or
      not exists(new.getInitializer().getFullyConverted()) and
      init = HC_NoInit()
    )
  }

  private predicate analyzableNewArrayExpr(NewArrayExpr new) {
    strictcount(new.getAllocatedType().getUnspecifiedType()) = 1 and
    count(new.getAllocatorCall().getFullyConverted()) <= 1 and
    count(new.getInitializer().getFullyConverted()) <= 1 and
    count(new.(NewArrayExpr).getExtent().getFullyConverted()) <= 1
  }

  private predicate mk_NewArrayExpr(
    Type t, HC_Alloc alloc, HC_Extent extent, HC_Init init, NewArrayExpr new
  ) {
    analyzableNewArrayExpr(new) and
    t = new.getAllocatedType() and
    (
      alloc = HC_HasAlloc(hashConsExpr(new.getAllocatorCall().getFullyConverted()))
      or
      not exists(new.getAllocatorCall().getFullyConverted()) and
      alloc = HC_NoAlloc()
    ) and
    (
      init = HC_HasInit(hashConsExpr(new.getInitializer().getFullyConverted()))
      or
      not exists(new.getInitializer().getFullyConverted()) and
      init = HC_NoInit()
    ) and
    (
      extent = HC_HasExtent(hashConsExpr(new.getExtent().getFullyConverted()))
      or
      not exists(new.getExtent().getFullyConverted()) and
      extent = HC_NoExtent()
    )
  }

  private predicate analyzableDeleteExpr(DeleteExpr e) {
    strictcount(e.getAChild().getFullyConverted()) = 1
  }

  private predicate mk_DeleteExpr(HashConsExpr hc, DeleteExpr e) {
    analyzableDeleteExpr(e) and
    hc = hashConsExpr(e.getAChild().getFullyConverted())
  }

  private predicate analyzableDeleteArrayExpr(DeleteArrayExpr e) {
    strictcount(e.getAChild().getFullyConverted()) = 1
  }

  private predicate mk_DeleteArrayExpr(HashConsExpr hc, DeleteArrayExpr e) {
    analyzableDeleteArrayExpr(e) and
    hc = hashConsExpr(e.getAChild().getFullyConverted())
  }

  private predicate analyzableSizeofType(SizeofTypeOperator e) {
    strictcount(e.getUnspecifiedType()) = 1 and
    strictcount(e.getTypeOperand()) = 1
  }

  private predicate mk_SizeofType(Type t, SizeofTypeOperator e) {
    analyzableSizeofType(e) and
    t = e.getTypeOperand()
  }

  private predicate analyzableSizeofExpr(Expr e) {
    e instanceof SizeofExprOperator and
    strictcount(e.getAChild().getFullyConverted()) = 1
  }

  private predicate mk_SizeofExpr(HashConsExpr child, SizeofExprOperator e) {
    analyzableSizeofExpr(e) and
    child = hashConsExpr(e.getAChild())
  }

  private predicate analyzableUuidofOperator(UuidofOperator e) {
    strictcount(e.getTypeOperand()) = 1
  }

  private predicate mk_UuidofOperator(Type t, UuidofOperator e) {
    analyzableUuidofOperator(e) and
    t = e.getTypeOperand()
  }

  private predicate analyzableTypeidType(TypeidOperator e) {
    count(e.getAChild()) = 0 and
    strictcount(e.getResultType()) = 1
  }

  private predicate mk_TypeidType(Type t, TypeidOperator e) {
    analyzableTypeidType(e) and
    t = e.getResultType()
  }

  private predicate analyzableTypeidExpr(Expr e) {
    e instanceof TypeidOperator and
    strictcount(e.getAChild().getFullyConverted()) = 1
  }

  private predicate mk_TypeidExpr(HashConsExpr child, TypeidOperator e) {
    analyzableTypeidExpr(e) and
    child = hashConsExpr(e.getAChild())
  }

  private predicate analyzableAlignofType(AlignofTypeOperator e) {
    strictcount(e.getUnspecifiedType()) = 1 and
    strictcount(e.getTypeOperand()) = 1
  }

  private predicate mk_AlignofType(Type t, AlignofTypeOperator e) {
    analyzableAlignofType(e) and
    t = e.getTypeOperand()
  }

  private predicate analyzableAlignofExpr(AlignofExprOperator e) {
    strictcount(e.getExprOperand()) = 1
  }

  private predicate mk_AlignofExpr(HashConsExpr child, AlignofExprOperator e) {
    analyzableAlignofExpr(e) and
    child = hashConsExpr(e.getAChild())
  }

  /**
   * Gets the hash cons of field initializer expressions [0..i), where i > 0, for
   * the class aggregate literal `cal` of type `c`, where `head` is the hash cons
   * of the i'th initializer expression.
   */
  HC_Fields aggInitExprsUpTo(ClassAggregateLiteral cal, Class c, int i) {
    exists(Field f, HashConsExpr head, HC_Fields tail |
      result = HC_FieldCons(c, i - 1, f, head, tail) and
      mk_FieldCons(c, i - 1, f, head, tail, cal)
    )
  }

  private predicate mk_FieldCons(
    Class c, int i, Field f, HashConsExpr hc, HC_Fields hcf, ClassAggregateLiteral cal
  ) {
    analyzableClassAggregateLiteral(cal) and
    cal.getUnspecifiedType() = c and
    exists(Expr e |
      e = cal.getAFieldExpr(f).getFullyConverted() and
      f.getInitializationOrder() = i and
      (
        hc = hashConsExpr(e) and
        hcf = aggInitExprsUpTo(cal, c, i)
        or
        hc = hashConsExpr(e) and
        i = 0 and
        hcf = HC_EmptyFields(c)
      )
    )
  }

  private predicate analyzableClassAggregateLiteral(ClassAggregateLiteral cal) {
    forall(int i | exists(cal.getChild(i)) |
      strictcount(cal.getChild(i).getFullyConverted()) = 1 and
      strictcount(Field f | cal.getChild(i) = cal.getAFieldExpr(f)) = 1 and
      strictcount(Field f, int j |
        cal.getAFieldExpr(f) = cal.getChild(i) and j = f.getInitializationOrder()
      ) = 1
    )
  }

  private predicate mk_ClassAggregateLiteral(Class c, HC_Fields hcf, ClassAggregateLiteral cal) {
    analyzableClassAggregateLiteral(cal) and
    c = cal.getUnspecifiedType() and
    (
      hcf = aggInitExprsUpTo(cal, c, cal.getNumChild())
      or
      cal.getNumChild() = 0 and
      hcf = HC_EmptyFields(c)
    )
  }

  private predicate analyzableArrayAggregateLiteral(ArrayAggregateLiteral aal) {
    forall(int i | exists(aal.getChild(i)) | strictcount(aal.getChild(i).getFullyConverted()) = 1) and
    strictcount(aal.getUnspecifiedType()) = 1
  }

  /**
   * Gets the hash cons of array elements in [0..i), where i > 0, for
   * the array aggregate literal `aal` of type `t`.
   */
  private HC_Array arrayElemsUpTo(ArrayAggregateLiteral aal, Type t, int i) {
    exists(HC_Array tail, HashConsExpr head |
      result = HC_ArrayCons(t, i - 1, head, tail) and
      mk_ArrayCons(t, i - 1, head, tail, aal)
    )
  }

  private predicate mk_ArrayCons(
    Type t, int i, HashConsExpr hc, HC_Array hca, ArrayAggregateLiteral aal
  ) {
    analyzableArrayAggregateLiteral(aal) and
    t = aal.getUnspecifiedType() and
    hc = hashConsExpr(aal.getChild(i)) and
    (
      hca = arrayElemsUpTo(aal, t, i)
      or
      i = 0 and
      hca = HC_EmptyArray(t)
    )
  }

  private predicate mk_ArrayAggregateLiteral(Type t, HC_Array hca, ArrayAggregateLiteral aal) {
    t = aal.getUnspecifiedType() and
    (
      exists(HashConsExpr head, HC_Array tail, int numElements |
        numElements = aal.getNumChild() and
        hca = HC_ArrayCons(t, numElements - 1, head, tail) and
        mk_ArrayCons(t, numElements - 1, head, tail, aal)
      )
      or
      aal.getNumChild() = 0 and
      hca = HC_EmptyArray(t)
    )
  }

  private predicate analyzableThrowExpr(ThrowExpr te) {
    strictcount(te.getExpr().getFullyConverted()) = 1
  }

  private predicate mk_ThrowExpr(HashConsExpr hc, ThrowExpr te) {
    analyzableThrowExpr(te) and
    hc.getAnExpr() = te.getExpr().getFullyConverted()
  }

  private predicate analyzableReThrowExpr(ReThrowExpr rte) { any() }

  private predicate mk_ReThrowExpr(ReThrowExpr te) { any() }

  private predicate analyzableConditionalExpr(ConditionalExpr ce) {
    strictcount(ce.getCondition().getFullyConverted()) = 1 and
    strictcount(ce.getThen().getFullyConverted()) = 1 and
    strictcount(ce.getElse().getFullyConverted()) = 1
  }

  private predicate mk_ConditionalExpr(
    HashConsExpr cond, HashConsExpr trueHc, HashConsExpr falseHc, ConditionalExpr ce
  ) {
    analyzableConditionalExpr(ce) and
    cond.getAnExpr() = ce.getCondition() and
    trueHc.getAnExpr() = ce.getThen() and
    falseHc.getAnExpr() = ce.getElse()
  }

  private predicate analyzableNoExceptExpr(NoExceptExpr nee) {
    strictcount(nee.getAChild().getFullyConverted()) = 1
  }

  private predicate mk_NoExceptExpr(HashConsExpr child, NoExceptExpr nee) {
    analyzableNoExceptExpr(nee) and
    nee.getExpr().getFullyConverted() = child.getAnExpr()
  }

  private predicate mk_StmtCons(HashConsStmt hc, int i, HC_Stmts list, BlockStmt block) {
    hc = hashConsStmt(block.getStmt(i)) and
    (
      exists(HashConsStmt head, HC_Stmts tail |
        mk_StmtConsInner(head, tail, i - 1, list, block) and
        i > 0
      )
      or
      i = 0 and
      list = HC_EmptyStmts()
    )
  }

  private predicate mk_StmtConsInner(
    HashConsStmt head, HC_Stmts tail, int i, HC_Stmts list, BlockStmt block
  ) {
    list = HC_StmtCons(head, i, tail) and
    mk_StmtCons(head, i, tail, block)
  }

  private predicate mk_BlockStmtCons(HC_Stmts hc, BlockStmt s) {
    if s.getNumStmt() > 0
    then
      exists(HashConsStmt head, HC_Stmts tail |
        mk_StmtConsInner(head, tail, s.getNumStmt() - 1, hc, s)
      )
    else hc = HC_EmptyStmts()
  }

  private predicate mk_CoReturnStmtCons(
    HashConsExpr operand, HC_OptCoReturnExpr expr, CoReturnStmt s
  ) {
    operand = hashConsExpr(s.getOperand()) and
    if s.hasExpr()
    then expr = HC_HasCoReturnExpr(hashConsExpr(s.getExpr()))
    else expr = HC_NoCoReturnExpr()
  }

  private predicate mk_ComputedGotoStmtCons(HashConsExpr expr, ComputedGotoStmt s) {
    expr = hashConsExpr(s.getExpr())
  }

  private predicate mk_ConstexprIfStmtCons(
    HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch, ConstexprIfStmt s
  ) {
    condition = hashConsExpr(s.getCondition()) and
    thenBranch = hashConsStmt(s.getThen()) and
    if s.hasElse()
    then elseBranch = HC_HasElseStmt(hashConsStmt(s.getElse()))
    else elseBranch = HC_NoElseStmt()
  }

  private predicate mk_IfStmtCons(
    HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch, IfStmt s
  ) {
    condition = hashConsExpr(s.getCondition()) and
    thenBranch = hashConsStmt(s.getThen()) and
    if s.hasElse()
    then elseBranch = HC_HasElseStmt(hashConsStmt(s.getElse()))
    else elseBranch = HC_NoElseStmt()
  }

  private predicate mk_SwitchStmtCons(HashConsExpr condition, HashConsStmt body, SwitchStmt s) {
    condition = hashConsExpr(s.getExpr()) and
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_DoStmtCons(HashConsExpr condition, HashConsStmt body, WhileStmt s) {
    condition = hashConsExpr(s.getCondition()) and
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_ForStmtCons(
    HashConsStmt init, HashConsExpr condition, HashConsExpr update, HashConsStmt body, ForStmt s
  ) {
    init = hashConsStmt(s.getInitialization()) and
    condition = hashConsExpr(s.getCondition()) and
    update = hashConsExpr(s.getUpdate()) and
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_RangeBasedForStmtCons(
    HashConsExpr variable, HashConsExpr range, HashConsStmt body, RangeBasedForStmt s
  ) {
    variable = hashConsExpr(s.getVariable().getAnAccess()) and
    range = hashConsExpr(s.getRange()) and
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_WhileStmtCons(HashConsExpr condition, HashConsStmt body, WhileStmt s) {
    condition = hashConsExpr(s.getCondition()) and
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_ExprStmtCons(HashConsExpr e, ExprStmt s) { e = hashConsExpr(s.getExpr()) }

  private predicate mk_BreakStmtCons(HashConsStmt breakable, BreakStmt s) {
    breakable = hashConsStmt(s.getBreakable())
  }

  private predicate mk_ContinueStmtCons(HashConsStmt continueable, ContinueStmt s) {
    continueable = hashConsStmt(s.getContinuable())
  }

  private predicate mk_GotoStmtCons(HashConsStmt target, HC_OptGotoLabel label, GotoStmt s) {
    target = hashConsStmt(s.getTarget()) and
    if s.hasName() then label = HC_HasGotoLabel(s.getName()) else label = HC_NoGotoLabel()
  }

  private predicate mk_LabelStmtCons(HC_OptLabelName name, LabelStmt s) {
    if s.isNamed() then name = HC_HasLabelName(s.getName()) else name = HC_NoLabelName()
  }

  private predicate mk_MicrosoftTryStmtCons(HashConsStmt body, MicrosoftTryStmt s) {
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_ReturnStmtCons(HC_OptReturnExpr e, ReturnStmt s) {
    if s.hasExpr() then e = HC_HasReturnExpr(hashConsExpr(s.getExpr())) else e = HC_NoReturnExpr()
  }

  // TODO: determine how to HashCons the statements of a switch case.
  private predicate mk_SwitchCaseCons(HashConsExpr e, SwitchCase s) {
    e = hashConsExpr(s.getExpr())
  }

  private predicate mk_TryStmtCons(HashConsStmt body, TryStmt s) {
    body = hashConsStmt(s.getStmt())
  }

  private predicate mk_CatchStmtCons(HashConsExpr parameter, HashConsStmt body, Handler s) {
    parameter = hashConsExpr(s.getParameter().getAnAccess()) and
    body = hashConsStmt(s.getBlock())
  }

  private predicate mk_Decl(HC_Decl hc, Declaration d) {
    d instanceof Variable and
    exists(Type t, string name, HC_OptInitializer init |
      mk_VariableDecl(t, name, init, d) and
      hc = HC_VariableDecl(t, name, init)
    )
  }

  private predicate mk_DeclConsInner(HC_Decl head, HC_Decls tail, int i, HC_Decls list, DeclStmt s) {
    list = HC_DeclCons(head, i, tail) and
    mk_DeclCons(head, i, tail, s)
  }

  private predicate mk_DeclCons(HC_Decl hc, int i, HC_Decls list, DeclStmt s) {
    mk_Decl(hc, s.getDeclaration(i)) and
    (
      i = 0 and
      list = HC_EmptyDecls()
      or
      i > 0 and
      exists(HC_Decl head, HC_Decls tail | mk_DeclConsInner(head, tail, i - 1, list, s))
    )
  }

  private predicate mk_VariableDecl(Type t, string name, HC_OptInitializer init, Variable v) {
    t = v.getUnspecifiedType() and
    name = v.getName() and
    if v.hasInitializer()
    then init = HC_HasInitializer(hashConsExpr(v.getInitializer().getExpr()))
    else init = HC_NoInitializer()
  }

  private predicate mk_DeclStmt(HC_Decls hc, DeclStmt s) {
    mk_DeclConsInner(_, _, s.getNumDeclarations() - 1, hc, s)
  }

  private predicate mk_ParamCons(HashConsExpr hc, int i, HC_Params list, Function f) {
    hc = hashConsExpr(f.getParameter(i).getAnAccess()) and
    (
      exists(HashConsExpr head, HC_Params tail |
        mk_ParamConsInner(head, tail, i - 1, list, f) and
        i > 0
      )
      or
      i = 0 and
      list = HC_NoParams()
    )
  }

  private predicate mk_ParamConsInner(
    HashConsExpr head, HC_Params tail, int i, HC_Params list, Function f
  ) {
    list = HC_ParamCons(head, i, tail) and
    mk_ParamCons(head, i, tail, f)
  }

  private predicate mk_FunctionCons(
    Type t, string name, HC_Params params, HashConsStmt body, Function f
  ) {
    t = f.getUnspecifiedType() and
    name = f.getName() and
    body = hashConsStmt(f.getBlock()) and
    if f.getNumberOfParameters() > 0
    then mk_ParamConsInner(_, _, f.getNumberOfParameters() - 1, params, f)
    else params = HC_NoParams()
  }

  /** Gets the hash-cons of expression `e`. */
  cached
  HashConsExpr hashConsExpr(Expr e) {
    exists(int val, Type t |
      mk_IntLiteral(val, t, e) and
      result = HC_IntLiteral(val, t)
    )
    or
    exists(EnumConstant val, Type t |
      mk_EnumConstantAccess(val, t, e) and
      result = HC_EnumConstantAccess(val, t)
    )
    or
    exists(float val, Type t |
      mk_FloatLiteral(val, t, e) and
      result = HC_FloatLiteral(val, t)
    )
    or
    exists(string val, Type t |
      mk_StringLiteral(val, t, e) and
      result = HC_StringLiteral(val, t)
    )
    or
    exists(Type t, string name |
      mk_Variable(t, name, e) and
      result = HC_Variable(t, name)
    )
    or
    exists(HashConsExpr qualifier, Field target |
      mk_DotFieldAccess(qualifier, target, e) and
      result = HC_FieldAccess(qualifier, target)
    )
    or
    exists(HashConsExpr qualifier, Field target |
      mk_PointerFieldAccess(qualifier, target, e) and
      result = HC_PointerFieldAccess(qualifier, target)
    )
    or
    exists(Function fcn, Field target |
      mk_ImplicitThisFieldAccess(fcn, target, e) and
      result = HC_ImplicitThisFieldAccess(fcn, target)
    )
    or
    exists(Function fcn |
      mk_ThisExpr(fcn, e) and
      result = HC_ThisExpr(fcn)
    )
    or
    exists(Type t, HashConsExpr child |
      mk_Conversion(t, child, e) and
      result = HC_Conversion(t, child)
    )
    or
    exists(HashConsExpr lhs, HashConsExpr rhs, string opname |
      mk_BinaryOp(lhs, rhs, opname, e) and
      result = HC_BinaryOp(lhs, rhs, opname)
    )
    or
    exists(HashConsExpr child, string opname |
      mk_UnaryOp(child, opname, e) and
      result = HC_UnaryOp(child, opname)
    )
    or
    exists(HashConsExpr x, HashConsExpr i |
      mk_ArrayAccess(x, i, e) and
      result = HC_ArrayAccess(x, i)
    )
    or
    exists(HashConsExpr p |
      mk_Deref(p, e) and
      result = HC_Deref(p)
    )
    or
    exists(Function fcn, HC_Args args |
      mk_NonmemberFunctionCall(fcn, args, e) and
      result = HC_NonmemberFunctionCall(fcn, args)
    )
    or
    exists(HashConsExpr hc, HC_Args args |
      mk_ExprCall(hc, args, e) and
      result = HC_ExprCall(hc, args)
    )
    or
    exists(Function fcn, HashConsExpr qual, HC_Args args |
      mk_MemberFunctionCall(fcn, qual, args, e) and
      result = HC_MemberFunctionCall(fcn, qual, args)
    )
    or
    // works around an extractor issue
    exists(Type t |
      mk_AllocatorArgZero(t, e) and
      result = HC_AllocatorArgZero(t)
    )
    or
    exists(Type t, HC_Alloc alloc, HC_Init init |
      mk_NewExpr(t, alloc, init, e) and
      result = HC_NewExpr(t, alloc, init)
    )
    or
    exists(Type t, HC_Alloc alloc, HC_Extent extent, HC_Init init |
      mk_NewArrayExpr(t, alloc, extent, init, e) and
      result = HC_NewArrayExpr(t, alloc, extent, init)
    )
    or
    exists(Type t |
      mk_SizeofType(t, e) and
      result = HC_SizeofType(t)
    )
    or
    exists(HashConsExpr child |
      mk_SizeofExpr(child, e) and
      result = HC_SizeofExpr(child)
    )
    or
    exists(Type t |
      mk_TypeidType(t, e) and
      result = HC_TypeidType(t)
    )
    or
    exists(HashConsExpr child |
      mk_TypeidExpr(child, e) and
      result = HC_TypeidExpr(child)
    )
    or
    exists(Type t |
      mk_UuidofOperator(t, e) and
      result = HC_UuidofOperator(t)
    )
    or
    exists(Type t |
      mk_AlignofType(t, e) and
      result = HC_AlignofType(t)
    )
    or
    exists(HashConsExpr child |
      mk_AlignofExpr(child, e) and
      result = HC_AlignofExpr(child)
    )
    or
    exists(Class c, HC_Fields hfc |
      mk_ClassAggregateLiteral(c, hfc, e) and
      result = HC_ClassAggregateLiteral(c, hfc)
    )
    or
    exists(Type t, HC_Array hca |
      mk_ArrayAggregateLiteral(t, hca, e) and
      result = HC_ArrayAggregateLiteral(t, hca)
    )
    or
    exists(HashConsExpr child |
      mk_DeleteExpr(child, e) and
      result = HC_DeleteExpr(child)
    )
    or
    exists(HashConsExpr child |
      mk_DeleteArrayExpr(child, e) and
      result = HC_DeleteArrayExpr(child)
    )
    or
    exists(HashConsExpr child |
      mk_ThrowExpr(child, e) and
      result = HC_ThrowExpr(child)
    )
    or
    mk_ReThrowExpr(e) and
    result = HC_ReThrowExpr()
    or
    exists(HashConsExpr cond, HashConsExpr thenHC, HashConsExpr elseHC |
      mk_ConditionalExpr(cond, thenHC, elseHC, e) and
      result = HC_ConditionalExpr(cond, thenHC, elseHC)
    )
    or
    mk_Nullptr(e) and
    result = HC_Nullptr()
    or
    not analyzableExpr(e, _) and result = HC_Unanalyzable(e)
  }

  cached
  HashConsStmt hashConsStmt(Stmt s) {
    exists(HC_Stmts list |
      mk_BlockStmtCons(list, s) and
      result = HC_BlockStmt(list)
    )
    or
    exists(HashConsExpr operand, HC_OptCoReturnExpr expr |
      mk_CoReturnStmtCons(operand, expr, s) and
      result = HC_CoReturnStmt(operand, expr)
    )
    or
    exists(HashConsExpr target |
      mk_ComputedGotoStmtCons(target, s) and
      result = HC_ComputedGotoStmt(target)
    )
    or
    exists(HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch |
      mk_ConstexprIfStmtCons(condition, thenBranch, elseBranch, s) and
      result = HC_ConstexprIfStmt(condition, thenBranch, elseBranch)
    )
    or
    exists(HashConsExpr condition, HashConsStmt thenBranch, HC_OptElseStmt elseBranch |
      mk_IfStmtCons(condition, thenBranch, elseBranch, s) and
      result = HC_IfStmt(condition, thenBranch, elseBranch)
    )
    or
    exists(HashConsExpr condition, HashConsStmt body |
      mk_SwitchStmtCons(condition, body, s) and
      result = HC_SwitchStmt(condition, body)
    )
    or
    exists(HashConsExpr condition, HashConsStmt body |
      mk_DoStmtCons(condition, body, s) and
      result = HC_DoStmt(condition, body)
    )
    or
    exists(HashConsStmt init, HashConsExpr condition, HashConsExpr update, HashConsStmt body |
      mk_ForStmtCons(init, condition, update, body, s) and
      result = HC_ForStmt(init, condition, update, body)
    )
    or
    exists(HashConsExpr variable, HashConsExpr range, HashConsStmt body |
      mk_RangeBasedForStmtCons(variable, range, body, s) and
      result = HC_RangeBasedForStmt(variable, range, body)
    )
    or
    exists(HashConsExpr condition, HashConsStmt body |
      mk_WhileStmtCons(condition, body, s) and
      result = HC_WhileStmt(condition, body)
    )
    or
    exists(HashConsExpr e |
      mk_ExprStmtCons(e, s) and
      result = HC_ExprStmt(e)
    )
    or
    exists(HashConsStmt breakable |
      mk_BreakStmtCons(breakable, s) and
      result = HC_BreakStmt(breakable)
    )
    or
    exists(HashConsStmt continueable |
      mk_ContinueStmtCons(continueable, s) and
      result = HC_ContinueStmt(continueable)
    )
    or
    exists(HashConsStmt target, HC_OptGotoLabel label |
      mk_GotoStmtCons(target, label, s) and
      result = HC_GotoStmt(target, label)
    )
    or
    exists(HC_OptLabelName name |
      mk_LabelStmtCons(name, s) and
      result = HC_LabelStmt(name)
    )
    or
    exists(HashConsStmt body |
      mk_MicrosoftTryStmtCons(body, s) and
      result = HC_MicrosoftTryStmt(body)
    )
    or
    exists(HC_OptReturnExpr e |
      mk_ReturnStmtCons(e, s) and
      result = HC_ReturnStmt(e)
    )
    or
    exists(HashConsExpr e |
      mk_SwitchCaseCons(e, s) and
      result = HC_SwitchCase(e)
    )
    or
    exists(HashConsStmt body |
      mk_TryStmtCons(body, s) and
      result = HC_TryStmt(body)
    )
    or
    exists(HashConsExpr parameter, HashConsStmt body |
      mk_CatchStmtCons(parameter, body, s) and
      result = HC_CatchStmt(parameter, body)
    )
    or
    exists(HC_Decls decls |
      mk_DeclStmt(decls, s) and
      result = HC_DeclStmt(decls)
    )
  }

  cached
  HashConsFunc hashConsFunc(Function f) {
    exists(Type t, string name, HC_Params params, HashConsStmt body |
      mk_FunctionCons(t, name, params, body, f) and
      result = HC_Function(t, name, params, body)
    )
  }

  /**
   * Holds if the expression is explicitly handled by `hashConsExpr`.
   * Unanalyzable expressions still need to be given a hash-cons,
   * but it will be a unique number that is not shared with any other
   * expression.
   */
  predicate analyzableExpr(Expr e, string kind) {
    analyzableIntLiteral(e) and kind = "IntLiteral"
    or
    analyzableEnumConstantAccess(e) and kind = "EnumConstantAccess"
    or
    analyzableFloatLiteral(e) and kind = "FloatLiteral"
    or
    analyzableStringLiteral(e) and kind = "StringLiteral"
    or
    analyzableNullptr(e) and kind = "Nullptr"
    or
    analyzableDotFieldAccess(e) and kind = "DotFieldAccess"
    or
    analyzablePointerFieldAccess(e) and kind = "PointerFieldAccess"
    or
    analyzableImplicitThisFieldAccess(e) and kind = "ImplicitThisFieldAccess"
    or
    analyzableVariable(e) and kind = "Variable"
    or
    analyzableConversion(e) and kind = "Conversion"
    or
    analyzableBinaryOp(e) and kind = "BinaryOp"
    or
    analyzableUnaryOp(e) and kind = "UnaryOp"
    or
    analyzableThisExpr(e) and kind = "ThisExpr"
    or
    analyzableArrayAccess(e) and kind = "ArrayAccess"
    or
    analyzablePointerDereferenceExpr(e) and kind = "PointerDereferenceExpr"
    or
    analyzableNonmemberFunctionCall(e) and kind = "NonmemberFunctionCall"
    or
    analyzableMemberFunctionCall(e) and kind = "MemberFunctionCall"
    or
    analyzableExprCall(e) and kind = "ExprCall"
    or
    analyzableNewExpr(e) and kind = "NewExpr"
    or
    analyzableNewArrayExpr(e) and kind = "NewArrayExpr"
    or
    analyzableSizeofType(e) and kind = "SizeofTypeOperator"
    or
    analyzableSizeofExpr(e) and kind = "SizeofExprOperator"
    or
    analyzableAlignofType(e) and kind = "AlignofTypeOperator"
    or
    analyzableAlignofExpr(e) and kind = "AlignofExprOperator"
    or
    analyzableUuidofOperator(e) and kind = "UuidofOperator"
    or
    analyzableTypeidType(e) and kind = "TypeidType"
    or
    analyzableTypeidExpr(e) and kind = "TypeidExpr"
    or
    analyzableClassAggregateLiteral(e) and kind = "ClassAggregateLiteral"
    or
    analyzableArrayAggregateLiteral(e) and kind = "ArrayAggregateLiteral"
    or
    analyzableDeleteExpr(e) and kind = "DeleteExpr"
    or
    analyzableDeleteArrayExpr(e) and kind = "DeleteArrayExpr"
    or
    analyzableThrowExpr(e) and kind = "ThrowExpr"
    or
    analyzableReThrowExpr(e) and kind = "ReThrowExpr"
    or
    analyzableConditionalExpr(e) and kind = "ConditionalExpr"
    or
    analyzableNoExceptExpr(e) and kind = "NoExceptExpr"
    or
    analyzableAllocatorArgZero(e) and kind = "AllocatorArgZero"
  }
}

HashCons::HashConsFunc getFunctionHashCons(Function f) { result = HashCons::hashConsFunc(f) }
