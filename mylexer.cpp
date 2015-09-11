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
* mylexer.cpp
* C++ source file generated from mylexer.l.
* 
* Date: 12/15/08
* Time: 08:20:04
* 
* ALex Version: 2.06
****************************************************************************/

#include <yyclex.h>

// namespaces
#ifdef YYSTDCPPLIB
using namespace std;
#endif
#ifdef YYNAMESPACE
using namespace yl;
#endif

#line 1 ".\\mylexer.l"

/****************************************************************************
mylexer.l
ParserWizard generated Lex file.

Date: 2008��12��14��
****************************************************************************/

#include "myparser.h"

#define MAXCHILDREN 4 //ÿһ���������ӵ�еĺ��ӽ���������

#define IDNUMMAX  100  //�ɴ洢�����������Ŀ

#define LETNUMMAX 999  //�洢�������ֵ������С


//������ű�Ԫ�ص����ݽṹ	
struct entry
{
	char *lexptr;		//��ָ��ָ��������ֵĴ洢λ��
	
	int  type;			//�ñ�������÷��ŵ�����(char��,bool��,int�ͻ�float��)(1:char,2:bool,3:int,4:float)
	
	float   token;		//�ı�������÷��ŵ�ֵ(��Ϊfloat�ͣ�����type��������)
};
	
extern entry symtable[IDNUMMAX];//������ű�

extern char  lexemes[LETNUMMAX];//����������ֵ�ʵ�ʴ洢����

extern int lastentry;    //symtable��������õ�λ��

int   lastchar = -1;	 //lexemes��������õ�λ��




//����������ö������
typedef enum nodeKind 
{	
	kind_prog,				//prog
	kind_lines,             //lines
	kind_expr,				//expr
	kind_stmt,				//stmt
	kind_rela_stmt,			//rela_stmt
	kind_type,				//type
	kind_const,				//const
	kind_ID,				//ID(��ʾ��)
	kind_const_value,		//����(���ַ�����:COUNTCHAR,�����ͳ���:true,false,���ͳ���:COUNTINTNUM,���㳣��:COUNTFLOATNUM)
}   NodeKind ;					
	

		
//���������ṹ
typedef struct treeNode
{   
    treeNode * child[MAXCHILDREN]; //ָ���亢�ӽ���ָ��
	
	treeNode * sibling;			  //����ָ�������ֵܽ���ָ��
	
	
	int Currnode_number;			   //����ý��ı��
	
	int lineno;					   //����ĳЩ����Ӧ�û�������к�	
	
	
	NodeKind nodekind;  //�������,ȡֵ��ΧΪNodeKind�е�ֵ
	
	int nodekind_kind;	//����һ��NodeKind����������������ͣ������(��nodekindȡkind_type����ֵʱ
	                    //�������nodekind_kindΪ1ʱ����ʾ��Ӧ�Ľ��Ϊchar��,nodekind_kindΪ2ʱ,��ʾ��Ӧ�Ľڵ�Ϊbool��.....)

	int stmt_type;		//��nodekindΪkind_stmtʱ,���ʽȡֵ���ñ�����ֵ��Ч.����stmt���ʽ������
	                    //(stmt_typeΪ1ʱ����ʾ��Ӧ��stmt���ʽΪchar��;Ϊ2ʱ����ʾ��Ϊbool��;Ϊ3ʱ����Ϊint��;Ϊ4ʱ����ʾ��Ϊfloat��)
	
	float node_value;	//�����ΪҶ���,����Ϊkind_node_valueʱ,�������泣����ֵ.
						//��nodekind_kindΪ1ʱ,��node_value��floatǿ��ת��Ϊint��,Ȼ��ȡ��Ӧ��char���ַ�;
						//��nodekind_kindΪ2ʱ,��node_value��floatǿ��ת��Ϊint��,��ת��Ϊbool��;
						//��nodekind_kindΪ3ʱ,��node_value��floatǿ��ת��Ϊint��
						//�����Ϊkind_stmtʱ,����������ʽ��ֵ,��ֵ�ɽ��stmt_typeת��Ϊ���ʽ����ʵֵ	 		
						//�����λkind_IDʱ,��������ID��Ӧ���ű��е��±�
}	TreeNode;



TreeNode * lnew_treeNode;//	��������һ���µ��﷨�����

TreeNode * lnew_TreeNode();//�ú�������һ�������,�����ؽ��ָ��,ͬʱ��ɽ�����ݳ�ʼ��
	
void error(char*m);	
int lookup(char*s);
int insert(char*s);

float change_to_float(char*m,int a);//�ú���������a��ȡֵ���ַ���ת��Ϊ��Ӧ��float��ֵ
	

#line 135 "mylexer.cpp"
// repeated because of possible precompiled header
#include <yyclex.h>

// namespaces
#ifdef YYSTDCPPLIB
using namespace std;
#endif
#ifdef YYNAMESPACE
using namespace yl;
#endif

#include ".\mylexer.h"

/////////////////////////////////////////////////////////////////////////////
// constructor

YYLEXERNAME::YYLEXERNAME()
{
	yytables();
#line 111 ".\\mylexer.l"

	// place any extra initialisation code here

#line 159 "mylexer.cpp"
}

/////////////////////////////////////////////////////////////////////////////
// destructor

YYLEXERNAME::~YYLEXERNAME()
{
#line 116 ".\\mylexer.l"

	// place any extra cleanup code here

#line 171 "mylexer.cpp"
}

#ifndef YYTEXT_SIZE
#define YYTEXT_SIZE 100
#endif
#ifndef YYUNPUT_SIZE
#define YYUNPUT_SIZE YYTEXT_SIZE
#endif
#ifndef YYTEXT_MAX
#define YYTEXT_MAX 0
#endif
#ifndef YYUNPUT_MAX
#define YYUNPUT_MAX YYTEXT_MAX
#endif

/****************************************************************************
* N O T E
* 
* If the compiler generates a YYLEXERNAME error then you have not declared
* the name of the lexical analyser. The easiest way to do this is to use a
* name declaration. This is placed in the declarations section of your Lex
* source file and is introduced with the %name keyword. For instance, the
* following name declaration declares the lexer mylexer:
* 
* %name mylexer
* 
* For more information see help.
****************************************************************************/

// backwards compatability with lex
#ifdef input
int YYLEXERNAME::yyinput()
{
	return input();
}
#else
#define input yyinput
#endif

#ifdef output
void YYLEXERNAME::yyoutput(int ch)
{
	output(ch);
}
#else
#define output yyoutput
#endif

#ifdef unput
void YYLEXERNAME::yyunput(int ch)
{
	unput(ch);
}
#else
#define unput yyunput
#endif

#ifndef YYNBORLANDWARN
#ifdef __BORLANDC__
#pragma warn -rch		// <warning: unreachable code> off
#endif
#endif

int YYLEXERNAME::yyaction(int action)
{
#line 134 ".\\mylexer.l"

	// extract yylval for use later on in actions
	YYSTYPE YYFAR& yylval = *(YYSTYPE YYFAR*)yyparserptr->yylvalptr;

#line 242 "mylexer.cpp"
	yyreturnflg = yytrue;
	switch (action) {
	case 1:
		{
#line 141 ".\\mylexer.l"
return(INT);
#line 249 "mylexer.cpp"
		}
		break;
	case 2:
		{
#line 142 ".\\mylexer.l"
return(VOID);
#line 256 "mylexer.cpp"
		}
		break;
	case 3:
		{
#line 143 ".\\mylexer.l"
return(MAIN);
#line 263 "mylexer.cpp"
		}
		break;
	case 4:
		{
#line 144 ".\\mylexer.l"
return(CHAR);
#line 270 "mylexer.cpp"
		}
		break;
	case 5:
		{
#line 145 ".\\mylexer.l"
return(FLOAT);
#line 277 "mylexer.cpp"
		}
		break;
	case 6:
		{
#line 146 ".\\mylexer.l"
return(BOOL);
#line 284 "mylexer.cpp"
		}
		break;
	case 7:
		{
#line 147 ".\\mylexer.l"
return(IF);
#line 291 "mylexer.cpp"
		}
		break;
	case 8:
		{
#line 148 ".\\mylexer.l"
return(ELSE);
#line 298 "mylexer.cpp"
		}
		break;
	case 9:
		{
#line 149 ".\\mylexer.l"
return(WHILE);
#line 305 "mylexer.cpp"
		}
		break;
	case 10:
		{
#line 150 ".\\mylexer.l"
return(FOR);
#line 312 "mylexer.cpp"
		}
		break;
	case 11:
		{
#line 151 ".\\mylexer.l"
return(LSBRA);
#line 319 "mylexer.cpp"
		}
		break;
	case 12:
		{
#line 152 ".\\mylexer.l"
return(RSBRA);
#line 326 "mylexer.cpp"
		}
		break;
	case 13:
		{
#line 153 ".\\mylexer.l"
return(LLSBRA);
#line 333 "mylexer.cpp"
		}
		break;
	case 14:
		{
#line 154 ".\\mylexer.l"
return(RLSBRA);
#line 340 "mylexer.cpp"
		}
		break;
	case 15:
		{
#line 155 ".\\mylexer.l"
return(SEMIC);
#line 347 "mylexer.cpp"
		}
		break;
	case 16:
		{
#line 156 ".\\mylexer.l"
return(ADD);
#line 354 "mylexer.cpp"
		}
		break;
	case 17:
		{
#line 157 ".\\mylexer.l"
return(SUB);
#line 361 "mylexer.cpp"
		}
		break;
	case 18:
		{
#line 158 ".\\mylexer.l"
return(MUL);
#line 368 "mylexer.cpp"
		}
		break;
	case 19:
		{
#line 159 ".\\mylexer.l"
return(DIV);
#line 375 "mylexer.cpp"
		}
		break;
	case 20:
		{
#line 160 ".\\mylexer.l"
return(PERC);
#line 382 "mylexer.cpp"
		}
		break;
	case 21:
		{
#line 161 ".\\mylexer.l"
return(DADD);
#line 389 "mylexer.cpp"
		}
		break;
	case 22:
		{
#line 162 ".\\mylexer.l"
return(DSUB);
#line 396 "mylexer.cpp"
		}
		break;
	case 23:
		{
#line 163 ".\\mylexer.l"
return(GREAT);
#line 403 "mylexer.cpp"
		}
		break;
	case 24:
		{
#line 164 ".\\mylexer.l"
return(LESS);
#line 410 "mylexer.cpp"
		}
		break;
	case 25:
		{
#line 165 ".\\mylexer.l"
return(EQU);
#line 417 "mylexer.cpp"
		}
		break;
	case 26:
		{
#line 166 ".\\mylexer.l"
return(GEQU);
#line 424 "mylexer.cpp"
		}
		break;
	case 27:
		{
#line 167 ".\\mylexer.l"
return(LEQU);
#line 431 "mylexer.cpp"
		}
		break;
	case 28:
		{
#line 168 ".\\mylexer.l"
return(NEQU);
#line 438 "mylexer.cpp"
		}
		break;
	case 29:
		{
#line 169 ".\\mylexer.l"
return(NOT);
#line 445 "mylexer.cpp"
		}
		break;
	case 30:
		{
#line 170 ".\\mylexer.l"
return(AND);
#line 452 "mylexer.cpp"
		}
		break;
	case 31:
		{
#line 171 ".\\mylexer.l"
return(OR);
#line 459 "mylexer.cpp"
		}
		break;
	case 32:
		{
#line 172 ".\\mylexer.l"
return(EVALU);
#line 466 "mylexer.cpp"
		}
		break;
	case 33:
		{
#line 173 ".\\mylexer.l"

			char c;
		
			c = input();
			
			while(true)
			{
				c = input();
				
				if(c == '\n')
				{
					break;
				}
				
			}	
		
#line 488 "mylexer.cpp"
		}
		break;
	case 34:
		{
#line 189 ".\\mylexer.l"

            char c;
        
            label:
        
            do{
        
                 c = input();
        
              }while(c != '*');
            
            do
            {
                c = input();
        
                if(c == '/')
        
                    break;
        
                if(c != '*')
        
                    goto label;
        
            }while(c == '*');
            
        
#line 520 "mylexer.cpp"
		}
		break;
#line 215 ".\\mylexer.l"
        
#line 525 "mylexer.cpp"
	case 35:
		{
#line 216 ".\\mylexer.l"
;
#line 530 "mylexer.cpp"
		}
		break;
#line 217 ".\\mylexer.l"
	
#line 535 "mylexer.cpp"
	case 36:
		{
#line 219 ".\\mylexer.l"

	yylval = lnew_TreeNode();//�������ڵ�
	yylval->nodekind = kind_const_value;//�ڵ�����Ϊ��������
	yylval->node_value = change_to_float(yytext,1);
	return(COUNTCHAR);

#line 545 "mylexer.cpp"
		}
		break;
	case 37:
		{
#line 226 ".\\mylexer.l"

	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,2);
	return(TRUE);

#line 557 "mylexer.cpp"
		}
		break;
	case 38:
		{
#line 233 ".\\mylexer.l"

	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,3);
	return(FALSE);

#line 569 "mylexer.cpp"
		}
		break;
	case 39:
		{
#line 240 ".\\mylexer.l"

	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,4);
	return(COUNTINTNUM);

#line 581 "mylexer.cpp"
		}
		break;
	case 40:
		{
#line 247 ".\\mylexer.l"

	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,5);
	return(COUNTFLOATNUM);

#line 593 "mylexer.cpp"
		}
		break;
	case 41:
		{
#line 254 ".\\mylexer.l"

	int a=lookup(yytext);//�����ű����Ƿ��Ѵ���
	
	if(a==0)//���ű����粻���ڸ��ַ�
	{
		a=insert(yytext);
	}
	
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_ID;
	yylval->node_value = float(a);
	return(ID);

#line 612 "mylexer.cpp"
		}
		break;
	case 42:
		{
#line 268 ".\\mylexer.l"

	;//do nothing

#line 621 "mylexer.cpp"
		}
		break;
	default:
		yyassert(0);
		break;
	}
	yyreturnflg = yyfalse;
	return 0;
}

#ifndef YYNBORLANDWARN
#ifdef __BORLANDC__
#pragma warn .rch		// <warning: unreachable code> to the old state
#endif
#endif

void YYLEXERNAME::yytables()
{
	yystext_size = YYTEXT_SIZE;
	yysunput_size = YYUNPUT_SIZE;
	yytext_max = YYTEXT_MAX;
	yyunput_max = YYUNPUT_MAX;

	static const yymatch_t YYNEARFAR YYBASED_CODE match[] = {
		0
	};
	yymatch = match;

	yytransitionmax = 269;
	static const yytransition_t YYNEARFAR YYBASED_CODE transition[] = {
		{ 0, 0 },
		{ 3, 1 },
		{ 4, 1 },
		{ 3, 57 },
		{ 48, 25 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 59, 59 },
		{ 49, 25 },
		{ 39, 14 },
		{ 0, 16 },
		{ 50, 25 },
		{ 51, 26 },
		{ 42, 18 },
		{ 40, 14 },
		{ 43, 19 },
		{ 44, 20 },
		{ 3, 1 },
		{ 5, 1 },
		{ 3, 57 },
		{ 52, 26 },
		{ 45, 22 },
		{ 6, 1 },
		{ 7, 1 },
		{ 8, 1 },
		{ 9, 1 },
		{ 10, 1 },
		{ 11, 1 },
		{ 12, 1 },
		{ 46, 23 },
		{ 13, 1 },
		{ 47, 24 },
		{ 14, 1 },
		{ 15, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 16, 1 },
		{ 37, 12 },
		{ 17, 1 },
		{ 18, 1 },
		{ 19, 1 },
		{ 20, 1 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 16, 16 },
		{ 38, 13 },
		{ 53, 27 },
		{ 54, 28 },
		{ 55, 29 },
		{ 56, 30 },
		{ 57, 32 },
		{ 58, 36 },
		{ 60, 45 },
		{ 61, 46 },
		{ 62, 47 },
		{ 63, 48 },
		{ 64, 49 },
		{ 65, 50 },
		{ 66, 52 },
		{ 67, 53 },
		{ 68, 54 },
		{ 69, 55 },
		{ 70, 56 },
		{ 35, 7 },
		{ 0, 15 },
		{ 71, 60 },
		{ 72, 61 },
		{ 73, 62 },
		{ 74, 63 },
		{ 75, 64 },
		{ 22, 1 },
		{ 23, 1 },
		{ 76, 67 },
		{ 24, 1 },
		{ 25, 1 },
		{ 77, 68 },
		{ 78, 69 },
		{ 26, 1 },
		{ 79, 70 },
		{ 80, 74 },
		{ 81, 75 },
		{ 27, 1 },
		{ 82, 79 },
		{ 34, 5 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 28, 1 },
		{ 0, 0 },
		{ 29, 1 },
		{ 30, 1 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 31, 1 },
		{ 32, 1 },
		{ 33, 1 },
		{ 3, 57 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 36, 8 },
		{ 0, 0 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 36, 8 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 0, 0 },
		{ 21, 82 },
		{ 0, 0 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 },
		{ 21, 82 }
	};
	yytransition = transition;

	static const yystate_t YYNEARFAR YYBASED_CODE state[] = {
		{ 0, 0, 0 },
		{ 82, -8, 0 },
		{ 1, 0, 0 },
		{ 57, 0, 42 },
		{ 0, 0, 35 },
		{ 0, 42, 29 },
		{ 0, 0, 20 },
		{ 0, 45, 0 },
		{ 0, 71, 0 },
		{ 0, 0, 11 },
		{ 0, 0, 12 },
		{ 0, 0, 18 },
		{ 0, 7, 16 },
		{ 0, 20, 17 },
		{ 0, -26, 19 },
		{ -41, 74, 39 },
		{ -41, 7, 39 },
		{ 0, 0, 15 },
		{ 0, -41, 24 },
		{ 0, -39, 32 },
		{ 0, -38, 23 },
		{ 82, 0, 41 },
		{ 82, -83, 41 },
		{ 82, -68, 41 },
		{ 82, -70, 41 },
		{ 82, -93, 41 },
		{ 82, -83, 41 },
		{ 82, -31, 41 },
		{ 82, -47, 41 },
		{ 82, -43, 41 },
		{ 82, -35, 41 },
		{ 0, 0, 13 },
		{ 57, -54, 42 },
		{ 0, 0, 14 },
		{ 0, 0, 28 },
		{ 0, 0, 30 },
		{ 0, 32, 0 },
		{ 0, 0, 21 },
		{ 0, 0, 22 },
		{ 0, 0, 34 },
		{ 0, 0, 33 },
		{ 59, 0, 0 },
		{ 0, 0, 27 },
		{ 0, 0, 25 },
		{ 0, 0, 26 },
		{ 82, -39, 41 },
		{ 82, -24, 41 },
		{ 82, -41, 41 },
		{ 82, -33, 41 },
		{ 82, -21, 41 },
		{ 82, -37, 41 },
		{ 82, 0, 7 },
		{ 82, -38, 41 },
		{ 82, -26, 41 },
		{ 82, -37, 41 },
		{ 82, -24, 41 },
		{ 82, -23, 41 },
		{ 0, -6, 31 },
		{ 0, 0, 36 },
		{ 0, -43, 40 },
		{ 82, -23, 41 },
		{ 82, -28, 41 },
		{ 82, -14, 41 },
		{ 82, -27, 41 },
		{ 82, -22, 41 },
		{ 82, 0, 10 },
		{ 82, 0, 1 },
		{ 82, -18, 41 },
		{ 82, -6, 41 },
		{ 82, -4, 41 },
		{ 82, -10, 41 },
		{ 82, 0, 6 },
		{ 82, 0, 4 },
		{ 82, 0, 8 },
		{ 82, -2, 41 },
		{ 82, -16, 41 },
		{ 82, 0, 3 },
		{ 82, 0, 37 },
		{ 82, 0, 2 },
		{ 82, 1, 41 },
		{ 82, 0, 38 },
		{ 82, 0, 5 },
		{ 0, 146, 9 }
	};
	yystate = state;

	static const yybackup_t YYNEARFAR YYBASED_CODE backup[] = {
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	};
	yybackup = backup;
}
#line 272 ".\\mylexer.l"


/////////////////////////////////////////////////////////////////////////////
// programs section
TreeNode * lnew_TreeNode(void)				//�ú�������һ�������,�����ؽ��ָ��,ͬʱ��ɽ�����ݳ�ʼ��
{	
	lnew_treeNode = new(TreeNode) ;
	
	for(int i=0;i<MAXCHILDREN;i++)		//Ϊָ���亢�ӽ���ָ�븳��ֵ
	{
		lnew_treeNode->child[i] = NULL;
	}
	
	lnew_treeNode->sibling = NULL;		//Ϊָ�������ֵܽ���ָ�븳��ֵ	
	
	lnew_treeNode->lineno = 0;			//Ϊ����Ӧ�û�������кŸ���ֵ
	
	lnew_treeNode->Currnode_number = 0;
	
	lnew_treeNode->nodekind_kind = 0;//ΪNodeKind������������ı�Ÿ���ֵ,��ȷ�ı��Ӧ��Ϊ������
	
	lnew_treeNode->stmt_type = 0; //Ϊ����stmt���ʽ�����͵ı�������ֵ,��ȷstmt���ʽ����ӦΪ1-4֮���������
	
	return lnew_treeNode;
}


float change_to_float(char*m,int a)//�ú�������a��ȡֵ�����ַ���ת��Ϊ��Ӧ��float�͵�ֵ
{
	float b = 0;
	float c = 0;
	int i = 0;
	int j = 0;
	
	switch(a)
	{
		case 1:						//�����ַ�����(����Ӧ��ֵΪ1)ת��Ϊ��Ӧ��ASCII��,Ȼ���һ��ת��Ϊfloat��ֵ,������
			b = float(int(*m));						
			break;
		case 4:						//��int�ͣ�����Ӧ��ֵΪ4��������Ӧ���ַ���ת��Ϊ��Ӧ��float��ֵ,
			for(i = 0;m[i]!='\0';i++)					
			{
				b = b * 10 + m[i] - '0'; 
			}
			break;
		case 5:						//��float�ͣ�����Ӧ��ֵΪ5��������Ӧ���ַ���ת��Ϊ��Ӧ��float��ֵ
			for(i = 0;(m[i]!='.')&&(m[i]!='/0');i++ )
			{
				b = b * 10 + m[i] - '0';
			}
			for(;m[i]!='/0';i++)
			{
				i++;
				c = c * 10 + m[i] - '0';
				j++; 
			}
			for(;j>0;j--)
			{
				c = c / 10;
			}
			b = b + c;
			break;
		default:
			error("����������");
	}
	return b;
}


//һ������ĺ��� 
void error(char*m)
{
	cout<<m;
	exit(1);
}

int lookup(char*s)
{
	int p;
	
	for(p=1;p<=lastentry;p++)
	{
		if(strcmp(symtable[p].lexptr,s)==0)
		{
			return p;
		}
	}
	
	return 0;
}

int insert(char*s)
{
	int len;
	
	len=strlen(s);
	
	if(lastentry+1>=IDNUMMAX)
	{
		error("symbol table full \n");
	}
	
	if(lastchar+len+1>=LETNUMMAX)
	{
		error("lexemes array full \n");
	}
	
	lastentry++;
	
	symtable[lastentry].lexptr=lexemes+lastchar+1;
	
	lastchar=lastchar+len+1;
	
	strcpy(symtable[lastentry].lexptr,s);
	
	return lastentry;
}

