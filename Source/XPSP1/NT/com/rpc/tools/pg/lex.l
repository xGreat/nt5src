// Copyright (c) 1993-1999 Microsoft Corporation

%{
/*** 
 *** lexer for preprocessing the parser driver generated by yacc, in
 *** order to convert the big switch statement into individual semantic
 *** functions
 ***/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "lex.h"
#include "gram.h"

#define VC_PRINTF( x ) /** printf(x) **/

void		LexInstall_ID( void );
void		LexInstall_Number( void );
int			IsToken( void );
lextype_t	yylval;
int			Line = 0;
int			Incase = 0;
int			ActionSensed = 0;
char		LocalBuffer[ 100 ];

%}

letter						[a-z_A-Z]
digit						[0-9]
letter_or_digit				[a-zA-Z_0-9]
whitespace					[ \t]
other						.
%%

{letter}{letter_or_digit}*	{
							int	Token;

				VC_PRINTF(" Case 1\n");

							if( Token = IsToken() )
								{
								return Token;
								}
							else
								LexInstall_ID();
							return ID;
							}

"} break;\n"				{
				VC_PRINTF(" Case 2\n");
							Line++;
							return TOKEN_END_CASE;
							}
"} break;"{whitespace}*"\/\*"{whitespace}*"End of actions"{whitespace}*"\*\/\n" {
				VC_PRINTF(" Case 3\n");
							Line++;
							return TOKEN_END_CASE;
							}
{digit}{digit}*				{
				VC_PRINTF(" Case 4\n");
							LexInstall_Number();
							return NUMBER;
							}

"\n"						{
				VC_PRINTF(" Case 5\n");
							Line++;
							yylval.yycharval = '\n';
							return TOKEN_CHAR;
							}
{other}						{
				VC_PRINTF(" Case 6\n");
							yylval.yycharval = yytext[0];
							return TOKEN_CHAR;
							}
%%
/****************************************************************************
 *	utility routines
 ****************************************************************************/
/**************************************************************************
 *** install parser value stack
 **************************************************************************/

void
LexInstall_ID()
	{
	strncpy( LocalBuffer, yytext, yyleng );
	LocalBuffer[ yyleng ] = '\0';
	yylval.yystring = LocalBuffer;
	}
void
LexInstall_Number()
	{
	yylval.yynumber = atoi(yytext);
	}
/**************************************************************************
 *** token search
 **************************************************************************/
int
IsToken()
	{
static char *pTokens[] = 
	{
	 "case"
	,"___a_r_u_myact"
	,"___a_r_u_start"
	,"___a_r_u_end"
	};
static int	Tokens[] = 
	{
	 TOKEN_CASE
	,TOKEN_MYACT
	,TOKEN_START
	,TOKEN_END
	};

	int i = 0;
	int Token;

	while( i < sizeof(pTokens) / sizeof(char *) )
		{
		if(strcmp( pTokens[i] , yytext ) == 0 )
			{
			Token = Tokens[i];
			if(Token == TOKEN_CASE)
				{
				if(!ActionSensed || Incase)
					return 0;
				}
			return Token;
			}
		++i;
		}
	return 0;
	}
