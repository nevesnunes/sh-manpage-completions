INCS = include
LEXERS = $(wildcard *.l)
SRCS = $(wildcard src/*.cpp)

CC = g++
CFLAGS = --std=c++11
TARGET = scanner

all: scanner

lex.yy.cc: $(LEXERS)
	flex $^

scanner: lex.yy.cc $(SRCS)
	$(CC) -I$(INCS) $(CFLAGS) -o $(TARGET) $^

clean:
	$(RM) $(TARGET) lex.yy.cc

.PHONY: clean
