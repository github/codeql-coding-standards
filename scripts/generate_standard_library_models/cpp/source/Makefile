CC=clang++
CFLAGS=-std=c++14 -fno-builtin -v
all: stdlibcxx14

stdlibcxx14: stdlibcxx14.cpp
	$(CC) $(CFLAGS) -o $@ $<

.PHONY: clean
clean:
	-rm stdlibcxx14