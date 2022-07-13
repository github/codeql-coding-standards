//% $Id: A7-2-5.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>
//compliant
enum class WebpageColors: std::uint32_t
{
    Red,
    Blue,
    Green
};
//non-compliant
enum class Misc: std::uint32_t
{
    Yellow,
    Monday,
    Holiday
};