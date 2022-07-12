import cpp

class NonUnionStruct extends Struct {
  NonUnionStruct() { not this instanceof Union }
}
