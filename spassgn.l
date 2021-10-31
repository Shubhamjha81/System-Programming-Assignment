%{
	//Roll no: 2019CSC1051 Name: Shubham Jha
	#include <stdio.h>
	#include "spassgn.tab.h"
%}


%%

"+"							{return PLUS;}
"-"							{return MINUS;}
"*"							{return TIMES;}
"/"							{return DIVIDE;}
"("							{return LPAREN;}
")"							{return RPAREN;}
[0-9]+|[0-9]*\.[0-9]+		{yylval.doubleval=atof(yytext); return NUMBER;}
(<A[0-9]+>)					{yylval.strval=yytext; return VARIABLE;}
\n							{return 0;}
[ \t]						{}
.							{printf("Invalid token......\n"); exit(0);}

%%


int yywrap(){
	return 1;
}



