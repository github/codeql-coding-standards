import cpp
import Allocations
import Concurrency
import Const
import Conditionals
import Functions
import BannedFunctions
import BannedLibraries
import BannedTypes
import BannedSyntax
import Classes
import Comments
import DeadCode
import Declarations
import Exceptions1
import Exceptions2
import ExceptionSafety
import Expressions
import Freed
import Includes
import Inheritance
import Initialization
import IntegerConversion
import Invariants
import IO
import Iterators
import Lambdas
import Literals
import Loops
import Macros
import MoveForward
import Naming
import Null
import Operators
import OperatorInvariants
import OrderOfEvaluation
import OutOfBounds
import Pointers
import Representation
import Scope
import SideEffects1
import SideEffects2
import SmartPointers1
import SmartPointers2
import Strings
import Templates
import Toolchain
import TrustBoundaries
import TypeRanges
import Uninitialized
import VirtualFunctions

newtype TQuery =
  TAllocationsPackageQuery(AllocationsQuery a) or
  TClassesPackageQuery(ClassesQuery cl) or
  TConcurrencyPackageQuery(ConcurrencyQuery c) or
  TConditionalsPackageQuery(ConditionalsQuery cq) or
  TConstPackageQuery(ConstQuery co) or
  TFunctionsPackageQuery(FunctionsQuery f) or
  TBannedFunctionsPackageQuery(BannedFunctionsQuery bf) or
  TBannedLibrariesPackageQuery(BannedLibrariesQuery bl) or
  TBannedSyntaxPackageQuery(BannedSyntaxQuery bs) or
  TBannedTypesPackageQuery(BannedTypesQuery bt) or
  TCommentsPackageQuery(CommentsQuery c) or
  TDeadCodePackageQuery(DeadCodeQuery dc) or
  TDeclarationsPackageQuery(DeclarationsQuery d) or
  TExceptions1PackageQuery(Exceptions1Query e1) or
  TExceptions2PackageQuery(Exceptions2Query e2) or
  TExceptionSafetyPackageQuery(ExceptionSafetyQuery es) or
  TExpressionsPackageQuery(ExpressionsQuery e) or
  TFreedPackageQuery(FreedQuery f) or
  TIncludesPackageQuery(IncludesQuery i) or
  TInheritancePackageQuery(InheritanceQuery i) or
  TInitializationPackageQuery(InitializationQuery init) or
  TIntegerConversionPackageQuery(IntegerConversionQuery ic) or
  TInvariantsPackageQuery(InvariantsQuery i) or
  TIOPackageQuery(IOQuery io) or
  TIteratorsPackageQuery(IteratorsQuery iter) or
  TLambdasPackageQuery(LambdasQuery lambda) or
  TLiteralsPackageQuery(LiteralsQuery l) or
  TLoopsPackageQuery(LoopsQuery loop) or
  TMacrosPackageQuery(MacrosQuery m) or
  TMoveForwardPackageQuery(MoveForwardQuery mv) or
  TNamingPackageQuery(NamingQuery n) or
  TNullPackageQuery(NullQuery null) or
  TOperatorsPackageQuery(OperatorsQuery o) or
  TOperatorInvariantsPackageQuery(OperatorInvariantsQuery oi) or
  TOrderOfEvaluationPackageQuery(OrderOfEvaluationQuery oe) or
  TOutOfBoundsPackageQuery(OutOfBoundsQuery oob) or
  TPointersPackageQuery(PointersQuery pt) or
  TRepresentationPackageQuery(RepresentationQuery r) or
  TScopePackageQuery(ScopeQuery sc) or
  TSideEffects1PackageQuery(SideEffects1Query se1) or
  TSideEffects2PackageQuery(SideEffects2Query se2) or
  TSmartPointers1PackageQuery(SmartPointers1Query sp1) or
  TSmartPointers2PackageQuery(SmartPointers2Query sp2) or
  TStringsPackageQuery(StringsQuery st) or
  TTemplatesPackageQuery(TemplatesQuery t) or
  TToolchainPackageQuery(ToolchainQuery tc) or
  TTrustBoundariesPackageQuery(TrustBoundariesQuery tb) or
  TTypeRangesPackageQuery(TypeRangesQuery tr) or
  TUninitializedPackageQuery(UninitializedQuery uinit) or
  TVirtualFunctionsPackageQuery(VirtualFunctionsQuery vf)

class Query extends TQuery {
  string getQueryId() { isQueryMetadata(this, result, _) }

  string getRuleId() { isQueryMetadata(this, _, result) }

  string toString() { result = getQueryId() }
}

private predicate isQueryMetadata(Query query, string queryId, string ruleId) {
  isAllocationsQueryMetadata(query, queryId, ruleId) or
  isClassesQueryMetadata(query, queryId, ruleId) or
  isConcurrencyQueryMetadata(query, queryId, ruleId) or
  isConditionalsQueryMetadata(query, queryId, ruleId) or
  isConstQueryMetadata(query, queryId, ruleId) or
  isFunctionsQueryMetadata(query, queryId, ruleId) or
  isBannedFunctionsQueryMetadata(query, queryId, ruleId) or
  isBannedLibrariesQueryMetadata(query, queryId, ruleId) or
  isBannedSyntaxQueryMetadata(query, queryId, ruleId) or
  isBannedTypesQueryMetadata(query, queryId, ruleId) or
  isCommentsQueryMetadata(query, queryId, ruleId) or
  isDeadCodeQueryMetadata(query, queryId, ruleId) or
  isDeclarationsQueryMetadata(query, queryId, ruleId) or
  isExceptions1QueryMetadata(query, queryId, ruleId) or
  isExceptions2QueryMetadata(query, queryId, ruleId) or
  isExceptionSafetyQueryMetadata(query, queryId, ruleId) or
  isExpressionsQueryMetadata(query, queryId, ruleId) or
  isFreedQueryMetadata(query, queryId, ruleId) or
  isIncludesQueryMetadata(query, queryId, ruleId) or
  isInheritanceQueryMetadata(query, queryId, ruleId) or
  isInitializationQueryMetadata(query, queryId, ruleId) or
  isIntegerConversionQueryMetadata(query, queryId, ruleId) or
  isInvariantsQueryMetadata(query, queryId, ruleId) or
  isIOQueryMetadata(query, queryId, ruleId) or
  isIteratorsQueryMetadata(query, queryId, ruleId) or
  isLambdasQueryMetadata(query, queryId, ruleId) or
  isLiteralsQueryMetadata(query, queryId, ruleId) or
  isLoopsQueryMetadata(query, queryId, ruleId) or
  isMacrosQueryMetadata(query, queryId, ruleId) or
  isMoveForwardQueryMetadata(query, queryId, ruleId) or
  isNamingQueryMetadata(query, queryId, ruleId) or
  isNullQueryMetadata(query, queryId, ruleId) or
  isOperatorsQueryMetadata(query, queryId, ruleId) or
  isOperatorInvariantsQueryMetadata(query, queryId, ruleId) or
  isOrderOfEvaluationQueryMetadata(query, queryId, ruleId) or
  isOutOfBoundsQueryMetadata(query, queryId, ruleId) or
  isPointersQueryMetadata(query, queryId, ruleId) or
  isRepresentationQueryMetadata(query, queryId, ruleId) or
  isScopeQueryMetadata(query, queryId, ruleId) or
  isSideEffects1QueryMetadata(query, queryId, ruleId) or
  isSideEffects2QueryMetadata(query, queryId, ruleId) or
  isSmartPointers1QueryMetadata(query, queryId, ruleId) or
  isSmartPointers2QueryMetadata(query, queryId, ruleId) or
  isStringsQueryMetadata(query, queryId, ruleId) or
  isTemplatesQueryMetadata(query, queryId, ruleId) or
  isToolchainQueryMetadata(query, queryId, ruleId) or
  isTrustBoundariesQueryMetadata(query, queryId, ruleId) or
  isTypeRangesQueryMetadata(query, queryId, ruleId) or
  isUninitializedQueryMetadata(query, queryId, ruleId) or
  isVirtualFunctionsQueryMetadata(query, queryId, ruleId)
}
