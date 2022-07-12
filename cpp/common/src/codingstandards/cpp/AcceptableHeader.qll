import cpp

/**
 * An `AcceptableHeader` that has the permitted extension
 * of: h or hpp or hxx
 * as specified by A3-1-2
 */
class AcceptableHeader extends HeaderFile {
  AcceptableHeader() {
    this.getExtension() = "h" or
    this.getExtension() = "hpp" or
    this.getExtension() = "hxx"
  }
}
