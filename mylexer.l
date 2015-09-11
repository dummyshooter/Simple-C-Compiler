%{
/****************************************************************************
mylexer.l
ParserWizard generated Lex file.
作者:NKU Jackshen
Date: 2008年12月14日
****************************************************************************/

#include "myparser.h"

#define MAXCHILDREN 4 //每一个树结点所拥有的孩子结点的最大个数

#define IDNUMMAX  100  //可存储变量的最大数目

#define LETNUMMAX 999  //存储变量名字的区域大小


//定义符号表元素的数据结构	
struct entry
{
	char *lexptr;		//该指针指向符号名字的存储位置
	
	int  type;			//该变量保存该符号的类型(char型,bool型,int型或float型)(1:char,2:bool,3:int,4:float)
	
	float   token;		//改变量保存该符号的值(都为float型，依靠type来做区分)
};
	
extern entry symtable[IDNUMMAX];//定义符号表

extern char  lexemes[LETNUMMAX];//定义变量名字的实际存储区域

extern int lastentry;    //symtable中最后引用的位置

int   lastchar = -1;	 //lexemes中最后引用的位置




//定义结点种类枚举类型
typedef enum nodeKind 
{	
	kind_prog,				//prog
	kind_lines,             //lines
	kind_expr,				//expr
	kind_stmt,				//stmt
	kind_rela_stmt,			//rela_stmt
	kind_type,				//type
	kind_const,				//const
	kind_ID,				//ID(标示浮)
	kind_const_value,		//常量(单字符常量:COUNTCHAR,布尔型常量:true,false,整型常量:COUNTINTNUM,浮点常量:COUNTFLOATNUM)
}   NodeKind ;					
	

		
//定义树结点结构
typedef struct treeNode
{   
    treeNode * child[MAXCHILDREN]; //指向其孩子结点的指针
	
	treeNode * sibling;			  //保存指向其右兄弟结点的指针
	
	
	int Currnode_number;			   //保存该结点的编号
	
	int lineno;					   //保存某些结点对应用户程序的行号	
	
	
	NodeKind nodekind;  //结点类型,取值范围为NodeKind中的值
	
	int nodekind_kind;	//保存一个NodeKind类中所属子类的类型，即编号(当nodekind取kind_type具体值时
	                    //当保存的nodekind_kind为1时，表示对应的结点为char型,nodekind_kind为2时,表示对应的节点为bool型.....)

	int stmt_type;		//当nodekind为kind_stmt时,表达式取值，该变量的值有效.保存stmt表达式的类型
	                    //(stmt_type为1时，表示对应的stmt表达式为char型;为2时，表示其为bool型;为3时，其为int型;为4时，表示其为float型)
	
	float node_value;	//当结点为叶结点,且其为kind_node_value时,用来保存常量的值.
						//当nodekind_kind为1时,则将node_value由float强制转换为int型,然后取对应的char型字符;
						//当nodekind_kind为2时,则将node_value由float强制转换为int型,再转换为bool型;
						//当nodekind_kind为3时,则将node_value由float强制转换为int型
						//当结点为kind_stmt时,用来保存表达式的值,该值可结合stmt_type转换为表达式的真实值	 		
						//当结点位kind_ID时,用来保存ID对应符号表中的下标
}	TreeNode;



TreeNode * lnew_treeNode;//	用来生成一个新的语法树结点

TreeNode * lnew_TreeNode();//该函数生成一个树结点,并返回结点指针,同时完成结点内容初始化
	
void error(char*m);	
int lookup(char*s);
int insert(char*s);

float change_to_float(char*m,int a);//该函数将根据a的取值将字符串转换为对应的float型值
	
%}


/////////////////////////////////////////////////////////////////////////////
// declarations section

// lexical analyser name
%name mylexer

// class definition
{
	// place any extra class members here
}

// constructor
{
	// place any extra initialisation code here
}

// destructor
{
	// place any extra cleanup code here
}

digit       [0-9]
nonzerodig  [1-9]
letter      [a-zA-Z_]	
whitespace  [ |\t]+

// place any declarations here



%%

/////////////////////////////////////////////////////////////////////////////
// rules section

%{
	// extract yylval for use later on in actions
	YYSTYPE YYFAR& yylval = *(YYSTYPE YYFAR*)yyparserptr->yylvalptr;
%}

// place your Lex rules here

int		{return(INT);}
void    {return(VOID);} //void
main    {return(MAIN);} //main
char    {return(CHAR);}//char
flaot   {return(FLOAT);}//float
bool    {return(BOOL);}//bool
if		{return(IF);}//if
else	{return(ELSE);}//else
while   {return(WHILE);}//}//while
for     {return(FOR);}//for
"("		{return(LSBRA);}//'('
")"		{return(RSBRA);}//')'	
"{"		{return(LLSBRA);}//'{'	
"}"		{return(RLSBRA);}//'}'	
";"		{return(SEMIC);}//';'	
"+"     {return(ADD);}//'+'
"-"		{return(SUB);}//'-'
"*"		{return(MUL);}//'*'	
"/"     {return(DIV);}//'/'
"%"		{return(PERC);}//'%'
"++"    {return(DADD);}//'++'
--		{return(DSUB);}//'--'
">"	    {return(GREAT);}//'>'
"<"		{return(LESS);}//'<'
"=="	{return(EQU);}//'=='
">="	{return(GEQU);}//'>='
"<="	{return(LEQU);}//'<='
"!="	{return(NEQU);}//'!='
"!"		{return(NOT);}//'!'	
"&&"	{return(AND);}//'&&'
"||"	{return(OR);}//'||'	
"="		{return(EVALU);}//赋值
"//"	{
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
		}
"/*"    {
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
            
        }
        
"\n"	{;}	//回车符 	
	
'({letter}|{digit})'						
{
	yylval = lnew_TreeNode();//生成树节点
	yylval->nodekind = kind_const_value;//节点类型为常量类型
	yylval->node_value = change_to_float(yytext,1);
	return(COUNTCHAR);
}
true										
{
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,2);
	return(TRUE);
}
false										
{
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,3);
	return(FALSE);
}	
({nonzerodig}{digit}*)|0					
{
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,4);
	return(COUNTINTNUM);
}
(({nonzerodig}{digit}*)|0).{digit}+			
{
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_const_value;
	yylval->node_value = change_to_float(yytext,5);
	return(COUNTFLOATNUM);
}
{letter}({letter}|{digit})*					
{
	int a=lookup(yytext);//看符号表中是否已存在
	
	if(a==0)//符号表中如不存在该字符
	{
		a=insert(yytext);
	}
	
	yylval = lnew_TreeNode();
	yylval->nodekind = kind_ID;
	yylval->node_value = float(a);
	return(ID);
}
{whitespace}								
{
	;//do nothing
}

%%

/////////////////////////////////////////////////////////////////////////////
// programs section
TreeNode * lnew_TreeNode(void)				//该函数生成一个树结点,并返回结点指针,同时完成结点内容初始化
{	
	lnew_treeNode = new(TreeNode) ;
	
	for(int i=0;i<MAXCHILDREN;i++)		//为指向其孩子结点的指针赋初值
	{
		lnew_treeNode->child[i] = NULL;
	}
	
	lnew_treeNode->sibling = NULL;		//为指向其右兄弟结点的指针赋初值	
	
	lnew_treeNode->lineno = 0;			//为结点对应用户程序的行号赋初值
	
	lnew_treeNode->Currnode_number = 0;
	
	lnew_treeNode->nodekind_kind = 0;//为NodeKind类中所属子类的编号赋初值,正确的编号应该为正整数
	
	lnew_treeNode->stmt_type = 0; //为保存stmt表达式的类型的变量赋初值,正确stmt表达式类型应为1-4之间的正整数
	
	return lnew_treeNode;
}


float change_to_float(char*m,int a)//该函数根据a的取值，将字符串转换为对应的float型的值
{
	float b = 0;
	float c = 0;
	int i = 0;
	int j = 0;
	
	switch(a)
	{
		case 1:						//将单字符常量(即对应数值为1)转换为对应的ASCII码,然后进一步转换为float型值,并返回
			b = float(int(*m));						
			break;
		case 4:						//将int型（即对应数值为4）常量对应的字符串转换为对应的float型值,
			for(i = 0;m[i]!='\0';i++)					
			{
				b = b * 10 + m[i] - '0'; 
			}
			break;
		case 5:						//将float型（即对应数值为5）常量对应的字符串转换为对应的float型值
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
			error("编译器出错");
	}
	return b;
}


//一如既往的函数 
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
