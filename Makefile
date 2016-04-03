CON = config
SRC = src
BIN = bin

CC = gcc
LEX = flex -i -I
YACC = bison -d 
CFLAGS = -g -I ./include -O2
TARGET = parser

$(BIN)/$(TARGET): $(SRC)/main.c $(SRC)/lib.c $(SRC)/tree.c $(SRC)/list.c $(CON)/syntax.y $(CON)/lexical.l
	$(YACC) -o $(SRC)/syntax.tab.c $(CON)/syntax.y
	$(LEX) -o $(SRC)/lex.yy.c $(CON)/lexical.l
	mkdir $(BIN)
	$(CC) $(CFLAGS) -o $@ $< $(SRC)/lib.c $(SRC)/tree.c $(SRC)/list.c $(SRC)/lex.yy.c $(SRC)/syntax.tab.c -lfl -ly

clean :
	rm -f $(SRC)/*.tab.h $(SRC)/*.tab.c $(SRC)/*.yy.c
	rm -rf $(BIN) 
