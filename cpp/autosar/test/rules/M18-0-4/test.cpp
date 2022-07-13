#include <ctime>
#include <string>

void test_banned_ctime_functions() {
  std::clock_t c = std::clock();
  std::time_t now, now2;
  struct std::tm *timeinfo;
  struct std::tm *gm_time;

  std::time(&now);
  std::time(&now2);

  std::time_t time_diff = std::difftime(now2, now);

  timeinfo = std::localtime(&now);
  gm_time = std::gmtime(&now);
  std::mktime(timeinfo);

  std::string timestring{std::asctime(timeinfo)};
  std::string timestring2{std::ctime(&now)};

  char buffer[80];
  strftime(buffer, 80, "Now it's %I:%M%p.", timeinfo);
}