%{
	//Roll no: 2019CSC1051 Name: Shubham Jha


	#include <stdio.h>
	#include <stdlib.h>
	#include "sqlite3.h"
	#include <string.h>
	
	typedef struct yy_buffer_state * YY_BUFFER_STATE;
	extern YY_BUFFER_STATE yy_scan_string(const char * str);
	extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
	
	int yylex();
	void yyerror(char*);
	void storevariable(char*);
%}

%union{
	int intval;
	double doubleval;
	char* strval;
}

%token <intval> PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%token <strval> VARIABLE
%token <doubleval> NUMBER

 
%start startnode

%%

startnode:  exp		{printf("\n\n---------- The expression is correct. ---------\n\n\n");}
			;

exp: exp PLUS exp				
	 |exp MINUS exp
	 |exp TIMES exp
	 |exp DIVIDE exp
	 |LPAREN exp RPAREN
	 |factor
	 ;

factor: VARIABLE		{storevariable($1);}						
		|NUMBER
		;


	 
	
%%

int idx=0;
char values[10][10];


void storevariable(char* s){
	strcpy(values[idx], s);
	idx++;
	
	sqlite3 *db2;
    char *err_msg2 = 0;
    sqlite3_stmt *res2;
    
    int rc2 = sqlite3_open("assignment.db", &db2);
	if (rc2 != SQLITE_OK){
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db2));
        sqlite3_close(db2);
        exit(0);
    }
    
    char *sql2 = "SELECT columnname FROM formulafields WHERE variablename=?";
	
	rc2 = sqlite3_prepare_v2(db2, sql2, -1, &res2, 0);
    
    if (rc2 == SQLITE_OK) {
        sqlite3_bind_text(res2, 1, s, -1, 0);
    } 
    else {
        fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db2));
    }
    
    int step2 = sqlite3_step(res2);
    char* colname;
    if (step2 != SQLITE_ROW) {
        printf("Error has occured....\n");
    }
    colname = (char*)sqlite3_column_text(res2, 0);
    
    strcpy(values[idx], colname);
    idx++;
	
	//********************
	
}	


int callback(void *NotUsed, int argc, char **argv, char **azColName) {
    NotUsed = 0;
    for (int i = 0; i < argc; i++) {
		printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
	printf("\n");
    return 0;
}

char* replace(char* s, char* oldW, char* newW){
    char* result;
    int i, cnt = 0;
    int newWlen = strlen(newW);
    int oldWlen = strlen(oldW);
  
    // Counting the number of times old word
    // occur in the string
    for (i = 0; s[i] != '\0'; i++) {
        if (strstr(&s[i], oldW) == &s[i]) {
            cnt++;
  
            // Jumping to index after the old word.
            i += oldWlen - 1;
        }
    }
  
    // Making new string of enough length
    result = (char*)malloc(i + cnt * (newWlen - oldWlen) + 1);
  
    i = 0;
    while (*s) {
        // compare the substring with the result
        if (strstr(s, oldW) == s) {
            strcpy(&result[i], newW);
            i += newWlen;
            s += oldWlen;
        }
        else
            result[i++] = *s++;
    }
  
    result[i] = '\0';
    return result;
}



int main(){
	sqlite3 *db;
    char *err_msg = 0;
    sqlite3_stmt *res;
    
    int rc = sqlite3_open("assignment.db", &db);
    
    if (rc != SQLITE_OK){
        fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return 1;
    }
    
	char *sql = "SELECT formula FROM formulae WHERE id=?";
	
	int idval;
	printf("Enter formula id: (1-7) ");
	scanf("%d", &idval); 
	
	rc = sqlite3_prepare_v2(db, sql, -1, &res, 0);
    
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(res, 1, idval);
    } 
    else {
        fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
    }
        
    int step = sqlite3_step(res);
    
    const char* input;
    if (step != SQLITE_ROW) {
        printf("Error has occured....\n");
    }
    input = sqlite3_column_text(res, 0);
        
    printf("\n\nGiven expression: %s\n\n", input);    
    
    YY_BUFFER_STATE buffer = yy_scan_string(input);
    yyparse();
    yy_delete_buffer(buffer);
    
    
    char* fr= (char*)input;
	
    for (int i=0; i<idx; i=i+2){
		fr =replace(fr, values[i], values[i+1]);
	}
	
	

	
	char sql3[200]="SELECT EID, EmployeeName, (";
	strcat(sql3, fr);
	strcat(sql3, ") as RESULT FROM salary");
	printf("Generated Query: %s\n\n", sql3);
		
	int choice=0;
	printf("\nEnter id value of employee to generate the result query and its output for that employee: \n");
	printf("The id value should be between 1 and 6. Enter 0 if you want result for all employees.\n\n");
	printf("Enter value: ");
	scanf("%d", &choice);

	
	
	if(choice ==0){
		rc = sqlite3_exec(db, sql3, callback, 0, &err_msg);
    
		if (rc != SQLITE_OK ) {
        
			fprintf(stderr, "Failed to select data\n");
			fprintf(stderr, "SQL error: %s\n", err_msg);

			sqlite3_free(err_msg);
			sqlite3_close(db);
        
			return 1;
		}
	}
	else if(choice>0 && choice<7){
		strcat(sql3, " where eid = ?");
		
		rc = sqlite3_prepare_v2(db, sql3, -1, &res, 0);
    
		if (rc == SQLITE_OK) {
			sqlite3_bind_int(res, 1, choice);
		} 
		else {
			fprintf(stderr, "Failed to execute statement: %s\n", sqlite3_errmsg(db));
		}
        
		int step = sqlite3_step(res);
    
		if (step != SQLITE_ROW) {
			printf("Error has occured....\n");
		}

		printf("\n\nQuery Output-->\nEmployee name: %s\n", sqlite3_column_text(res, 1));
		printf("Result: %s\n", sqlite3_column_text(res, 2));		
		
	}
	
	else{
		printf("\nProgram Exited......");
		exit(0);
	}
	
	 
	
	
	sqlite3_finalize(res);
    sqlite3_close(db);

}


void yyerror (char *s){
   fprintf(stderr, "%s has occured. The expression is not correct... \n", s);
   exit(0);
}
	 

