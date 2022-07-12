//% $Id: A18-5-8.cpp 311792 2018-03-15 04:15:08Z christof.meerwald $
#include <cstdint>
#include <memory>
#include <vector>
class StackBitmap {
public:
  constexpr static size_t maxSize = 65535;
  using BitmapRawType = std::array<uint8_t, maxSize>;
  StackBitmap(const std::string &path, uint32_t bitmapSize) {
    // read bitmapSize bytes from the file path
  }
  const BitmapRawType &GetBitmap() const noexcept { return bmp; }

private:
  BitmapRawType bmp;
};
void AddWidgetToLayout(int32_t row, int32_t col) {
  auto idx = std::make_pair(row, col); // Compliant
  auto spIdx =
      std::make_shared<std::pair<int32_t, int32_t>>(row, col); // Non-compliant
  // addWidget to index idx
}
uint8_t CalcAverageBitmapColor(const std::string &path, uint32_t bitmapSize) {
  std::vector<uint8_t> bmp1(bitmapSize); // Compliant
  // read bitmap from path
  StackBitmap bmp2(path, bitmapSize); // Non-compliant
  bmp2.GetBitmap();
}
int main(int, char **) {
  AddWidgetToLayout(5, 8);
  CalcAverageBitmapColor("path/to/bitmap.bmp", 32000);
}