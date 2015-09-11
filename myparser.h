/****************************************************************************
*                     U N R E G I S T E R E D   C O P Y
* 
* You are on day 84 of your 30 day trial period.
* 
* This file was produced by an UNREGISTERED COPY of Parser Generator. It is
* for evaluation purposes only. If you continue to use Parser Generator 30
* days after installation then you are required to purchase a license. For
* more information see the online help or go to the Bumble-Bee Software
* homepage at:
* 
* http://www.bumblebeesoftware.com
* 
* This notice must remain present in the file. It cannot be removed.
****************************************************************************/

/****************************************************************************
* myparser.h
* C++ header file generated from myparser.y.
* 
* Date: 12/15/08
* Time: 08:20:05
* 
* AYACC Version: 2.06
****************************************************************************/

#ifndef _MYPARSER_H
#define _MYPARSER_H

#include <yycpars.h>

/////////////////////////////////////////////////////////////////////////////
// myparser

#ifndef YYEXPPARSER
#define YYEXPPARSER
#endif

class YYEXPPARSER YYFAR myparser : public _YL yyfparser {
public:
	myparser();
	virtual ~myparser();

protected:
	void yytables();
	virtual void yyaction(int action);
#ifdef YYDEBUG
	void YYFAR* yyattribute1(int index) const;
	void yyinitdebug(void YYFAR** p, int count) const;
#endif

	// attribute functions
	virtual void yystacktoval(int index);
	virtual void yyvaltostack(int index);
	virtual void yylvaltoval();
	virtual void yyvaltolval();
	virtual void yylvaltostack(int index);

	virtual void YYFAR* yynewattribute(int count);
	virtual void yydeleteattribute(void YYFAR* attribute);
	virtual void yycopyattribute(void YYFAR* dest, const void YYFAR* src, int count);

public:
#line 147 ".\\myparser.y"

	// place any extra class members here

#line 69 "myparser.h"
};

#ifndef YYPARSERNAME
#define YYPARSERNAME myparser
#endif

#line 162 ".\\myparser.y"

#ifndef YYSTYPE
#define YYSTYPE TreeNode*
#endif

#line 82 "myparser.h"
#define VOID 257
#define MAIN 258
#define INT 259
#define CHAR 260
#define FLOAT 261
#define BOOL 262
#define IF 263
#define ELSE 264
#define WHILE 265
#define FOR 266
#define LSBRA 267
#define RSBRA 268
#define LLSBRA 269
#define RLSBRA 270
#define SEMIC 271
#define ADD 272
#define SUB 273
#define MUL 274
#define DIV 275
#define PERC 276
#define DADD 277
#define DSUB 278
#define GREAT 279
#define LESS 280
#define EQU 281
#define GEQU 282
#define LEQU 283
#define NEQU 284
#define NOT 285
#define AND 286
#define OR 287
#define COUNTINTNUM 288
#define COUNTFLOATNUM 289
#define COUNTCHAR 290
#define ID 291
#define TRUE 292
#define FALSE 293
#define EVALU 294
#define UMINUS 295
#endif
