import cpp
import codingstandards.cpp.Class

query predicate copyConstructible(Class c) {
    isCopyConstructible(c)
}

query predicate moveConstructible(Class c) {
    isMoveConstructible(c)
}

query predicate copyAssignable(Class c) {
    isCopyAssignable(c)
}

query predicate moveAssignable(Class c) {
    isMoveAssignable(c)
}