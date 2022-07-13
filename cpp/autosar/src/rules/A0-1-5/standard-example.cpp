//% $Id: A0-1-5.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $
#include <cstdint>
#include <vector>
// Compressor.h
class Compressor {
public:
  using raw_memory_type = std::vector<uint8_t>;
  raw_memory_type Compress(const raw_memory_type &in, uint8_t ratio);

private:
  virtual raw_memory_type __Compress(const raw_memory_type &in,
                                     uint8_t ratio) = 0;
};
// Compressor.cpp
Compressor::raw_memory_type Compressor::Compress(const raw_memory_type &in,
                                                 uint8_t ratio) {
  return __Compress(in, ratio);
}
// JPEGCompressor.h
class JPEGCompressor : public Compressor {
private:
  raw_memory_type __Compress(const raw_memory_type &in, uint8_t ratio) override;
};
// JPEGCompressor.cpp
JPEGCompressor::raw_memory_type
JPEGCompressor::__Compress(const raw_memory_type &in, uint8_t ratio) {
  raw_memory_type ret;
  // jpeg compression, ratio used
  return ret;
}
// HuffmanCompressor.h
class HuffmanCompressor : public Compressor {
private:
  raw_memory_type __Compress(const raw_memory_type &in, uint8_t) override;
};
// JPEGCompressor.cpp
HuffmanCompressor::raw_memory_type
HuffmanCompressor::__Compress(const raw_memory_type &in, uint8_t) {
  raw_memory_type ret;
  // Huffman compression, no ratio parameter available in the algorithm
  return ret;
}