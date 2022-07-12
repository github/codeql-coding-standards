import cpp

/**
 * Models a class of functions that are either testers of characters
 * or standard library conversion functions.
 */
class CToOrIsCharFunction extends Function {
  CToOrIsCharFunction() {
    this instanceof CIsCharFunction or
    this instanceof CToCharFunction
  }
}

/**
 * Models a class of functions that test characters.
 */
class CIsCharFunction extends Function {
  CIsCharFunction() {
    getName() in [
        "isalnum", "isalpha", "isascii", "isblank", "iscntrl", "isdigit", "isgraph", "islower",
        "isprint", "ispunct", "isspace", "isupper", "isxdigit", "__isspace"
      ]
  }
}

/**
 * Models a class of functions convert characters.
 */
class CToCharFunction extends Function {
  CToCharFunction() { getName() in ["toascii", "toupper", "tolower"] }
}
