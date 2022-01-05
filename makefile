all:
	clear
	rm -f lex.yy.c
	rm -f y.tab.c
	rm -f limbaj
	yacc -d limbaj.y
	lex limbaj.l
	gcc -Wno-implicit-function-declaration lex.yy.c  y.tab.c -o limbaj
rm:
	rm -f lex.yy.c
	rm -f y.tab.c
	rm -f limbaj
	rm y.tab.h
	rm symbol_table.txt
	rm symbol_table_functions.txt
