%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.
作者：NKU Jackshen  
Date: 2008年12月14日
****************************************************************************/
#include <stack>
#include "mylexer.h"
#include<iostream>
#include<fstream>
#include <string>

#define MAXCHILDREN 4 //每一个树结点所拥有的孩子结点的最大个数
#define IDNUMMAX  100  //可存储变量的最大数目
#define LETNUMMAX 999  //存储变量名字的区域大小
#define max(a,b) ((a)>=(b)?(a):(b)) //取二者中的大值
#define  vari_db "TEMP_DB_"    //字节型临时变量前缀
#define  vari_dd "TEMP_DD_"    //双字型临时变量前缀
#define    lab   "LABEL_"       //标号前缀


//定义符号表元素的数据结构	
struct entry
{
	char *lexptr;		//该指针指向符号名字的存储位置
	
	int  type;			//该变量保存该符号的类型(char型,bool型,int型或float型)(1:char,2:bool,3:int,4:float)
	
	float   token;		//改变量保存该符号的值(都为float型，依靠type来做区分)
};

entry symtable[IDNUMMAX];   //定义符号表,外部引用变量(全局变量)
	
char  lexemes[LETNUMMAX];   //定义变量名字的实际存储区域

int lastentry;       //符号表中最后引用的位置

stack <float> idstack;        //该堆栈用来存储ID对应符号表中的下标

stack <int> db_tempstack;     //存储字节型临时变量

stack <int> dd_tempstack;     //存储双字型临时变量

ofstream outfile("output.txt"); //写文件


//定义结点类型枚举类型
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
	
	int lineno;		    //保存某些结点对应用户程序的行号		
	
	NodeKind nodekind;  //结点类型,取值范围为NodeKind中的类型
	
	int nodekind_kind;	//保存一个NodeKind类中所属子类的编号(当nodekind取kind_type_specifier时,
                    	//当保存的nodekind_kind为1时，表示对应的结点为char型,nodekind_kind为2时,表示对应的节点为bool型.....)
	
	int stmt_type;		//当nodekind为kind_stmt时,表达式取值，该变量的值有效.保存stmt表达式的类型
	                    //(stmt_type为1时，表示对应的stmt表达式为char型;为2时，表示其为bool型;为3时，其为int型;为4时，表示其为float型)
	
	float node_value;	//当结点为叶结点,且其为kind_const_value时,用来保存常量的值.
	                    //当nodekind_kind为1时,则将node_value由float强制转换为int型,然后取对应的char型字符;
	                    //当nodekind_kind为2时,则将node_value由float强制转换为int型,再转换为bool型;
	                    //当nodekind_kind为3时,则将node_value由float强制转换为int型
	                    //当结点为kind_stmt时,用来保存表达式的值,该值可结合stmt_type转换为表达式的相应的真实值
	                    //当结点位kind_ID时,用来保存ID对应符号表中的下标	 		
}	TreeNode;
	
	
int whole_Currnode_number = 1;	//用来为各树结点的结点编号赋值
	
int ps_error_count = 0 ;    //用来保存错误次数


TreeNode * root = NULL;     //保存最终的语法树的根结点	
	
TreeNode * new_treeNode;    //用来生成一个新的语法树结点
	

	
void warning(char*m);		//该函数用来打印警告信息

void ps_error(char*m);		//该函数用来打印出错信息

TreeNode * new_TreeNode();	//该函数生成一个树结点,并返回结点指针,同时完成结点内容初始化



int label = 0;//保存汇编代码中标号的编号
int db_max = 0; //保存所用字节型变量中值最大的编号
int dd_max = 0; //

//计算表算术达式的值
void stmt_operation(TreeNode*$$,TreeNode*$1,TreeNode*$3,char a);

//计算关系表达式的值
void rela_stmt_operation(TreeNode*$$,TreeNode*$2,TreeNode*$4,int a);

//将表达式的值由浮点型转换为其真实类型
void change_to_original_asm(float a,int b);	//转变成汇编常量



void single_node_stmt_print(TreeNode * m,int serial_number);//该函数用来打印单个结点对应的汇编代码，serial_number产生保存运算结果的临时变量

void single_node_rela_print(TreeNode * m,int serial_number);

void single_node_other_print(TreeNode*m);//该函数负责打印单个节点(prog,lines,expr)对应的汇编代码


void assembly_language_print(); //输出源程序对应的汇编代码

	

%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

// parser name
%name myparser

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

// attribute type
%include {
#ifndef YYSTYPE
#define YYSTYPE TreeNode*
#endif
}


// place any declarations here
%token VOID  //void
%token MAIN  //main
%token INT	 //int
%token CHAR  //char
%token FLOAT //float
%token BOOL  //bool
%token IF	 //if
%token ELSE	 //else
%token WHILE //while
%token FOR   //for
%token LSBRA //'('
%token RSBRA //')'
%token LLSBRA //'{'
%token RLSBRA //'}'
%token SEMIC //';'
%token ADD   //'+'
%token SUB   //'-'
%token MUL   //'*'
%token DIV   //'/'
%token PERC  //'%'
%token DADD  //'++'
%token DSUB  //'--'
%token GREAT //'>'
%token LESS  //'<'
%token EQU   //'=='
%token GEQU  //'>='
%token LEQU  //'<='
%token NEQU  //'!='
%token NOT   //'!'
%token AND   //'&&'
%token OR    //'||'
%token COUNTINTNUM //'整型数字常量'
%token COUNTFLOATNUM //'浮点数字常量'
%token COUNTCHAR //'char型常量'
%token ID    //'标示符'
%token TRUE  //true
%token FALSE //false
%token EVALU //赋值

// place any declarations here

%left  OR
%left  AND
%left  EQU  NEQU
%left  GREAT LESS LEQU GEQU 
%left  ADD SUB
%left  MUL DIV PERC
%right NOT 
%right UMINUS
%right DADD
%right DSUB 
%right EVALU

%%

/////////////////////////////////////////////////////////////////////////////
// rules section

// place your YACC rules here (there must be at least one)

prog		:	VOID  MAIN LLSBRA lines RLSBRA	//整个语法树的根结点	
				{								//该根结点类型为kind_prog,nodekind_kind为1,有一个孩子结点:kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $4;
					$$->nodekind = kind_prog;
					$$->nodekind_kind = 1;
					root = $$ ;
				
					outfile<<endl;
					
					outfile<<"源程序对应的汇编代码如下:"<<endl;
					
					outfile<<endl;	
					
					assembly_language_print();	
				} 
			;

lines		:	lines expr						//程序段结点								
				{								//该程序段结点类型为kind_lines,nodekind_kind为1,有两个孩子结点:kind_lines,kind_expr
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $2;
					$$->nodekind = kind_lines;
					$$->nodekind_kind = 1;
					$1->sibling = $2;			//lines的右兄弟结点为expr
					
				//	node_print($$);
				}
			|	expr
				{
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_lines;
					$$->nodekind_kind = 2;
				//	node_print($$);
				}	
			;

expr		:	type  ID  //SEMIC	//  变量声明					
				{								//  对应的expr语法树结点类型为kind_expr,nodekind_kind为1,有两个孩子结点:kind_type,kind_ID
					$2->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $2;
					$$->nodekind = kind_expr;
					$2->nodekind = kind_ID;
					$$->nodekind_kind = 1;
					$1->sibling = $2;			//type的右兄弟结点为ID
					
					if(symtable[int($2->node_value)].type>0)//检查ID是否已经定义,$2->node_entry->type大于0表明该ID类型已确定,即该ID已经定义
					{
						ps_error(("重定义"));//报错，但语法分析器将继续分析
					}
					
					symtable[int($2->node_value)].type = $1->nodekind_kind; //将type对应的类型赋值给ID对应的变量类型:1表示char型,2表示bool型,3表示int型,4表示float型
				//	node_print($2);
				//	node_print($$);
				}			
			|	type  ID EVALU stmt	 //SEMIC	//  带初值的变量声明	
				{						//  对应的expr语法树结点类型为kind_expr,nodekind_kind为2,有三个孩子结点:kind_type,kind_ID,kind_stmt
					$2->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $2;
					$$->child[2] = $4;
					$$->nodekind = kind_expr;
					$2->nodekind = kind_ID;
			    	
					$$->nodekind_kind = 2;
					$1->sibling = $2;
					$2->sibling = $4;
					if(symtable[int($2->node_value)].type>0)//检查ID是否已经定义,$2->node_entry->type大于0表明该ID类型已确定,即该ID已经定义
					{
						ps_error("重定义");//报错，但语法分析器将继续分析
					}
					symtable[int($2->node_value)].type = $1->nodekind_kind; //将type对应的类型赋值给ID对应的变量类型:1表示char型,2表示bool型,3表示int型,4表示float型
					
				
				
					//检查type的类型是否和stmt的类型相匹配,当类型不相匹配时,将尝试进行强制类型转换
			        //当强制转换导致信息丢失(float型转换为int型)时将打印警告信息
					//当强制转换导致错误(int型值大于等于128时转换成char型变量)时将打印错误信息，但语法分析器将继续工作(int型值大于127时转换成char型变量'0'即NULL)
					//但强制转换将留给符号表自身完成
					if((symtable[int($2->node_value)].type)!=($4->stmt_type))
					{
						if($4->stmt_type == 4) //当stmt为float型时，一定造成信息丢失，可能产生错误
						{
							if((symtable[int($2->node_value)].type) ==1)	//当ID为char型时
							{
								if($4->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int($2->node_value)].token = 0;
								}
								else
								{
									warning("类型转换导致信息丢失");
									symtable[int($2->node_value)].token = $4->node_value;
								}
							}
							else
							{
								warning("类型转换导致信息丢失");
								symtable[int($2->node_value)].token = $4->node_value;
							}
						}
						else
						{
							if($4->stmt_type == 3)	//当stmt为int型时,可能产生错误
							{
								if($4->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int($2->node_value)].token = 0;
								}
								else
								{
									symtable[int($2->node_value)].token = $4->node_value;  //正常赋值
								}	
							}
							else	  //正常赋值
							{
								symtable[int($2->node_value)].token = $4->node_value;  
							}
						}
					}
					else
					{
						symtable[int($2->node_value)].token = $4->node_value;  //正常赋值
					}
				//	node_print($2);
				//	node_print($$);
				}									 
			|	ID	  EVALU    stmt	 //SEMIC	//  赋值表达式
				{						//  对应的expr语法树结点类型为kind_expr,nodekind_kind为3,有两个孩子结点:kind_ID,kind_stmt
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $3;
					$$->nodekind = kind_expr;
					$1->nodekind = kind_ID;
				
					$$->nodekind_kind = 3;
					$1->sibling = $3;
					
					if(symtable[int($1->node_value)].type<=0)//检查ID是否已经定义,$2->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($1->node_value)].type = $3->stmt_type;	//此时,stmt将完全赋值给ID
						symtable[int($1->node_value)].token = $3->node_value;
					//	node_print($1);
					//	node_print($$);
						return;
					}
					
					//检查ID的类型是否和stmt的类型相匹配,当类型不相匹配时,将尝试进行强制类型转换
					//当强制转换导致信息丢失(float型转换为int型)时将打印警告信息
					//当强制转换导致错误(int型值大于等于128时转换成char型变量)时将打印错误信息，但语法分析器将继续工作(int型值大于127时转换成char型变量'0'即NULL)
					//但强制转换将留给符号表自身完成
					if((symtable[int($1->node_value)].type)!=($3->stmt_type))
					{
						if($3->stmt_type == 4) //当stmt为float型时，一定造成信息丢失，可能产生错误
						{
							if((symtable[int($1->node_value)].type) ==1)	//当ID为char型时
							{
								if($3->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int($1->node_value)].token = 0;
								}
							}
							else
							{
								warning("类型转换导致信息丢失");
								symtable[int($1->node_value)].token = $3->node_value;
							}
						}
						else
						{
							if($3->stmt_type == 3)	//当stmt为int型时,可能产生错误
							{
								if($3->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int($1->node_value)].token = 0;
								}
								else
								{
									symtable[int($1->node_value)].token = $3->node_value;  //正常赋值
								}	
							}
							else	  //正常赋值
							{
								symtable[int($1->node_value)].token = $3->node_value;  
							}
						}
					}
					else
					{
						symtable[int($1->node_value)].token = $3->node_value;  //正常赋值
					}
				//	node_print($1);
				//	node_print($$);
				}						
			|	IF LSBRA stmt RSBRA  LLSBRA lines RLSBRA  	//  条件表达式 if(stmt) { lines },其中的stmt为int型,char型或bool型
				{					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $3;
					$$->child[1] = $6;
					$$->nodekind = kind_expr;
				
					$$->nodekind_kind = 4;
					$3->sibling = $6;
					if($3->stmt_type == 4)
					{
						ps_error("IF 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				}						 
			|	IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA	  //  条件表达式 if(stmt) then { lines } else { lines },其中的stmt为int型,char型或bool型
				{					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为5,有三个孩子结点:kind_stmt,kind_lines,kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $3;
					$$->child[1] = $6;
					$$->child[2] = $10;
					$$->nodekind = kind_expr;
				
					$$->nodekind_kind = 5;
					$3->sibling = $6;
					$6->sibling = $10;
					if($3->stmt_type == 4)
					{
						ps_error("IF 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				}						
			|	FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA	  //  for循环 for(expr;stmt;expr) { lines },其中的stmt为int型,char型或bool型
				{					   //  对应的expr语法树结点类型为kind_expr,nodekind_kind为6,有四个孩子结点:kind_expr,kind_stmt,kind_expr,kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $3;
					$$->child[1] = $5;
					$$->child[2] = $7;
					$$->child[3] = $10;
					$$->nodekind = kind_expr;
			
					
					$$->nodekind_kind = 6;
					$3->sibling = $5;
					$5->sibling = $7;
					$7->sibling = $10;
					if($5->stmt_type == 4)
					{
						ps_error("IF-ELES 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				}						
			|	WHILE LSBRA stmt RSBRA LLSBRA lines RLSBRA	  //  while 循环 while(stmt) { lines },其中的stmt为int型,char型或bool型 
				{					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为7,有两个孩子结点:kind_stmt,kind_lines	
					$$ = new_TreeNode();
					$$->child[0] = $3;
					$$->child[1] = $6;
					$$->nodekind = kind_expr;
					$3->nodekind = kind_stmt;
					$6->nodekind = kind_lines;
					$$->nodekind_kind = 7;
					$3->sibling = $6;
					if($3->stmt_type == 4)
					{
						ps_error("WHILE 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				}						
			;
//  表达式(int,float,char,bool)
stmt		:   stmt ADD ID				//  stmt + ID
				{						//  对应的stmt语法树结点类型为kind_stmt,nodekind_kind为1,有两个孩子结点:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					
					$$->nodekind = kind_stmt;
					
					$$->nodekind_kind = 1;
					if(symtable[int($3->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($3->node_value)].type = $1->stmt_type;	//此时,stmt的类型将赋值给ID
						symtable[int($3->node_value)].token = 0;			//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push($3->node_value);
					$3->nodekind_kind = symtable[int($3->node_value)].type;
					$3->node_value = symtable[int($3->node_value)].token ;
					stmt_operation($$,$1,$3,'+');
					$3->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				}						
			|	stmt ADD const			//  stmt + 常量
				{						//	对应的stmt语法树节点类型为kind-stmt,nodekind_kind为2,有两个孩子结点:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 2;
					stmt_operation($$,$1,$3,'+');
				//	node_print($$);
				}						
			|	stmt SUB ID				//  stmt - ID
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为3,有两个孩子结点:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 3;
					if(symtable[int($3->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($3->node_value)].type = $1->stmt_type;	//此时,stmt的类型将赋值给ID
						symtable[int($3->node_value)].token = 0;			//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					
					idstack.push($3->node_value);
					$3->nodekind_kind = symtable[int($3->node_value)].type;
					$3->node_value = symtable[int($3->node_value)].token ;
					stmt_operation($$,$1,$3,'-');
					$3->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				}						
			|	stmt SUB const			//  stmt - 常量
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 4;
					stmt_operation($$,$1,$3,'-');
				//	node_print($$);
				}						
			|   stmt MUL ID				//  stmt * ID
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为5,有两个孩子结点:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 5;
					if(symtable[int($3->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($3->node_value)].type = $1->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int($3->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push($3->node_value);
					$3->nodekind_kind = symtable[int($3->node_value)].type;
					$3->node_value = symtable[int($3->node_value)].token ;
					stmt_operation($$,$1,$3,'*');
					$3->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				}						
			|	stmt MUL const			//  stmt * 常量
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为6,有两个孩子结点:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 6;
					stmt_operation($$,$1,$3,'*');
				//	node_print($$);
				}						
			|   stmt DIV ID				//  stmt / ID
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为7,有两个孩子结点:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 7;
					if(symtable[int($3->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($3->node_value)].type = $1->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int($3->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push($3->node_value);
					$3->nodekind_kind = symtable[int($3->node_value)].type;
					$3->node_value = symtable[int($3->node_value)].token ;
					stmt_operation($$,$1,$3,'/');
					$3->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				}						
			|	stmt DIV const			//  stmt / 常量
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为8,有两个孩子结点:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 8;
					stmt_operation($$,$1,$3,'/');
				//	node_print($$);
				}
			|	stmt PERC ID			//  stmt % ID,要求stmt和ID都不能为float型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为9,有两个孩子结点:kind_stmt,kind_const
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 9;
					if(symtable[int($3->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($3->node_value)].type = $1->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int($3->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push($3->node_value);
					$3->nodekind_kind = symtable[int($3->node_value)].type;
					$3->node_value = symtable[int($3->node_value)].token ;
					stmt_operation($$,$1,$3,'%');
					$3->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				}
			|	stmt PERC const			//  stmt % 常量,要求stmt和ID都不能为float型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为10,有两个孩子结点:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 10;
					stmt_operation($$,$1,$3,'%');
				//	node_print($$);
				}						
			|	SUB stmt %prec UMINUS	//  - stmt
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为11,有一个孩子结点:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 11;
					$$->stmt_type = $2->stmt_type;
					$$->node_value = - $2->node_value;
				//	node_print($$);
				}						
			|	stmt AND rela_stmt  	//  stmt && rela_stmt,stmt为char,bool,int型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为12,有两个孩子结点:kind_stmt,kind_rela_stmt
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 12;
					stmt_operation($$,$1,$3,'&');
				//	node_print($$);
				}						
			|	stmt OR  rela_stmt   	//  stmt || rela_stmt,stmt为char,bool,int型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为13,有两个孩子结点:kind_stmt,kind_rela_stmt
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 13;
					stmt_operation($$,$1,$3,'|');
				//	node_print($$);
				}						
			|	NOT	 stmt               //  ! stmt,stmt为char,bool,int型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为14,有一个孩子结点:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 14;
					$$->stmt_type = 2;
					if($2->stmt_type == 4)	//当stmt为float型时,报错
					{
						ps_error("逻辑表达式的不能为float型");
					}
					if($2->node_value > 0)
					{
						$$->node_value = 0;
					}
					else
					{
						$$->node_value = 1;
					}
				//	node_print($$);
				}						
			|   rela_stmt				//  rela_stmt 关系表达式
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为15,有一个孩子结点:kind_rela_stmt
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 15;
					$$->stmt_type = 2;
					$$->node_value = $1->node_value;
				//	node_print($$);
				}						
			|	ID						//  变量
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为16,有一个孩子结点:kind_ID
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 16;
					if(symtable[int($1->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($1->node_value)].type = 1;	//此时,将ID的类型强制赋值为char型
						symtable[int($1->node_value)].token = 0;		//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					$$->stmt_type = symtable[int($1->node_value)].type;
					$$->node_value = symtable[int($1->node_value)].token;
				//	node_print($1);
				//	node_print($$);
				}
			|	ID DADD					//  变量单增:ID++,要求该变量必须是int型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为17,有一个孩子结点:kind_ID	
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					TreeNode *test = $$;
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 17;
					if(symtable[int($1->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($1->node_value)].type = 1;			//此时,将ID的类型强制赋值为char型
						symtable[int($1->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					else
					{
						if(symtable[int($1->node_value)].type != 4)
						{
							ps_error("变量应为int型");
						}
						else
						{
							symtable[int($1->node_value)].token = symtable[int($1->node_value)].token + 1;
							$$->stmt_type = symtable[int($1->node_value)].type;
							$$->node_value = symtable[int($1->node_value)].token;
						}
					}
				//	node_print($1);
				//	node_print($$);
				}	
			|	ID DSUB					//  变量单增:ID--,要求该变量必须是int型
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为18,有一个孩子结点:kind_ID
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 18;
					if(symtable[int($1->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int($1->node_value)].type = 1;			//此时,将ID的类型强制赋值为char型
						symtable[int($1->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					else
					{
						if(symtable[int($1->node_value)].type != 4)
						{
							ps_error("变量应为int型");
						}
						else
						{
							symtable[int($1->node_value)].token = symtable[int($1->node_value)].token - 1;
							$$->stmt_type = symtable[int($1->node_value)].type;
							$$->node_value = symtable[int($1->node_value)].token;
						}
					}
				//	node_print($1);
				//	node_print($$);	
				}					
			|	const					//	常量
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为19,有一个孩子结点:kind_const
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 19;
					switch($1->nodekind_kind)
					{
						case 1:$$->stmt_type = 1;
							break;
			
						case 2:$$->stmt_type = 2;
							break;
						
						case 3:$$->stmt_type = 3;
							break;
						
						case 4:$$->stmt_type = 4;
							break;
						
						default:
							ps_error("编译器出错");
					}
					$$->node_value = $1->node_value;	
				//	node_print($$);
				}						
			|	LSBRA stmt RSBRA		//  ( stmt )
				{						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为20,有一个孩子结点:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 20;
					$$->stmt_type = $2->stmt_type;
					$$->node_value = $2->node_value;
				//	node_print($$);
				}						
			;
//关系表达式(比较同类型值间的大小,对于bool型变量:true > false,true >= false)
rela_stmt   :	LSBRA stmt   GREAT stmt RSBRA	//  比较大小	>
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为1,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,1);
				//	node_print($$);
				}								
			|	LSBRA stmt   LESS  stmt RSBRA	//  比较大小	<
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为2,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,2);
				//	node_print($$);
				}								
			|	LSBRA stmt   EQU   stmt	RSBRA	//  比较大小	==	
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为3,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,3);
				//	node_print($$);
				}								
			|	LSBRA stmt   GEQU  stmt	RSBRA	//  比较大小	>=
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,4);
				//	node_print($$);
				}								
			|	LSBRA stmt   LEQU  stmt	RSBRA	//  比较大小	<=
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为5,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,5);
				//	node_print($$);
				}									
			|	LSBRA stmt   NEQU  stmt	RSBRA	//  比较大小	!=
				{								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为6,有两个孩子结点:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,6);
				//	node_print($$);
				}								
			;
//type(类型)定义
type		:	CHAR					//  char
				{						//	对应的type语法树结点类型为kind_type,nodekind_kind为1,无孩子结点
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 1;
				//	node_print($$);
				}						
			|	BOOL					//  bool
				{						//	对应的type语法树结点类型为kind_type,nodekind_kind为2,无孩子结点
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 2;
				//	node_print($$);
				}						
			|	INT						//  int
				{						//	对应的type语法树结点类型为kind_type,nodekind_kind为3,无孩子结点
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 3;
				//	node_print($$);
				}						
			|	FLOAT					//  float
				{						//	对应的type语法树结点类型为kind_type,nodekind_kind为4,无孩子结点
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 4;
				//	node_print($$);
				}						
			;
//const(常量)定义
const		:	COUNTCHAR					//  单字符常量
				{						//	对应的const语法树结点类型为kind_const,nodekind_kind为1,有一个孩子结点:kind_const_value		
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 1;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 1;
					$$->node_value = $1->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				}						
			|	TRUE					//  bool型常量 true
				{						//	对应的const语法树结点类型为kind_const,nodekind_kind为2,有一个孩子结点:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 2;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 2;
					$$->node_value = $1->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				}						
			|	FALSE					//	bool型常量 false
				{						//	对应的const语法树结点类型为kind_const,nodekind_kind为3,有一个孩子结点:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 3;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 3;
					$$->node_value = $1->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				}							
			|	COUNTINTNUM					//  数字常量
				{						//	对应的const语法树结点类型为kind_const,nodekind_kind为4,有一个孩子结点:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 4;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 4;
					$$->node_value = $1->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				}						
			|	COUNTFLOATNUM					//  浮点常量
				{						//	对应的const语法树结点类型为kind_const,nodekind_kind为5,有一个孩子结点:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 5;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 5;
					$$->node_value = $1->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				}						
			;				

%%

/////////////////////////////////////////////////////////////////////////////
// programs section

void warning(char*m)					//该函数用来打印警告信息
{
	//打印警告信息
	cout<<m<<endl;	
}
void ps_error(char*m)					//该函数用来打印出错信息
{
	
	cout<<m<<endl;

	ps_error_count++;					//将出错次数增加1

}

TreeNode * new_TreeNode()				//该函数生成一个树结点,并返回结点指针,同时完成结点内容初始化
{	
	new_treeNode = new(TreeNode) ;

	for(int i=0;i<MAXCHILDREN;i++)		//为指向其孩子结点的指针赋初值
	{
		new_treeNode->child[i] = NULL;
	}

	new_treeNode->sibling = NULL;		//为指向其右兄弟结点的指针赋初值	

	new_treeNode->lineno = 0;			//为结点对应用户程序的行号赋初值

	new_treeNode->Currnode_number = whole_Currnode_number;

	whole_Currnode_number++;

	new_treeNode->nodekind_kind = 0;//为NodeKind类中所属子类的编号赋初值,正确的编号应该为正整数

	new_treeNode->stmt_type = 0;		//为保存stmt表达式的类型的变量赋初值,正确stmt表达式类型应为1-4之间的正整数

	return new_treeNode;
}

void stmt_operation(TreeNode*$$,TreeNode*$1,TreeNode*$3,char a)				//该函数用来计算表达式的值
{
	$$->child[0] = $1;

	$$->child[1] = $3;

	$1->sibling = $3;

	$$->stmt_type = (($1->stmt_type) > ($3->nodekind_kind))?($1->stmt_type):($3->nodekind_kind);//计算结果的类型为两个运算分量类型中较大的

	switch (a)
	{
		case '+':$$->node_value = $1->node_value + $3->node_value;
	
			break;
	
		case '-':$$->node_value = $1->node_value - $3->node_value;
	
			break;
	
		case '*':$$->node_value = $1->node_value * $3->node_value;
	
			break;
	
		case '/':
			if($3->node_value == 0)		//当除数为0时,报错,但将$1的值直接赋值给$$,以便语法分析器继续分析
			{
				ps_error("除零错");
	
				$$->node_value = $1->node_value;
	
				break;
			}
	
			$$->node_value = $1->node_value / $3->node_value;
	
			break;
	
		case '%':
			if(($1->stmt_type == 4) || ($3->nodekind_kind == 4))
			{
				ps_error("变量进行模运算时不能为float型值");
			}
		
			if($3->node_value == 0)		//当除数为0时,报错,但将$1的值直接赋值给$$,以便语法分析器继续分析
			{
				ps_error("除零错");
		
				$$->node_value = $1->node_value;
		
				break;
			}
		
			$$->node_value = int($1->node_value) % int($3->node_value);
		
			$$->stmt_type = 3 ;
		
			break;
		
		case '&':									//逻辑与运算&&
			if($1->stmt_type == 4)	//当stmt为float型时,报错
			{
				ps_error("逻辑表达式的不能为float型");
			}
		
			if(($1->node_value > 0) && ($3->node_value >0))
			{
				$$->node_value = 1;
			}
		
			else
			{
				$$->node_value = 0;
			}
		
			$$->stmt_type = 2;								
		
			break;
		
		case '|':									//逻辑或运算||
			if($1->stmt_type == 4)	//当stmt为float型时,报错
			{
				ps_error("逻辑表达式的不能为float型");
			}
		
			if(($1->node_value > 0) || ($3->node_value >0))
			{
				$$->node_value = 1;
			}
		
			else
			{
				$$->node_value = 0;
			}
		
			$$->stmt_type = 2;
		
			break;
		
		default:
			ps_error("编译器出错");
	}
}

void rela_stmt_operation(TreeNode*$$,TreeNode*$2,TreeNode*$4,int a)			//该函数用来计算关系表达式的值		
{
	$$->child[0] = $2;
	
	$$->child[1] = $4;
	
	$$->nodekind = kind_rela_stmt;
	
	$$->nodekind_kind = a;
	
	switch (a)
	{
		case 1:$$->node_value = (($2->node_value) > ($4->node_value)) ? 1: 0; // >
			break;
		case 2:$$->node_value = (($2->node_value) < ($4->node_value)) ? 1: 0; // <
			break;
		case 3:$$->node_value = (($2->node_value) == ($4->node_value)) ? 1: 0;// ==
			break;
		case 4:$$->node_value = (($2->node_value) >= ($4->node_value)) ? 1: 0;// >=
			break;
		case 5:$$->node_value = (($2->node_value) <= ($4->node_value)) ? 1: 0;// <=
			break;
		case 6:$$->node_value = (($2->node_value) != ($4->node_value)) ? 1: 0;// !=
			break;
		default:
			ps_error("编译器出错");
	}
}
void change_to_original_asm(float a,int b)	//该函数用来将源程序中常量转换为汇编语言中的常量
{
	switch(b)
	{
		case 1:outfile.width(10);outfile<<char(int(a));
			break;
		case 2:
			outfile.width(10);
			if(a > 0)
			{
				outfile<<"true";
			}
			else
			{
				outfile<<"false";
			}
			break;
	
		default:
			outfile.width(10);
			if(a < -100000)
			{
				outfile<<" ";
			}
			else
			{
				outfile<<a;
			}
	}
	return;
}

void single_node_rela_print(TreeNode * m,int serial_number)
{
	int num = 0;
	int num1 = 0;
	int temp_label1 = 0;
	int temp_label2 = 0;
	if(((m->child[0])->stmt_type<=2)&&((m->child[1])->stmt_type<=2))
	{
		num = db_tempstack.top();
		db_tempstack.pop();
		db_max = max(db_max,num);
		single_node_stmt_print(m->child[0],num);
		num1=db_tempstack.top();
		db_tempstack.pop();
		db_max = max(db_max,num1);
		single_node_stmt_print(m->child[1],num1);
		outfile<<"          MOV EAX "<<vari_db<<num<<endl;
		outfile<<"          CMP EAX "<<vari_db<<num1<<endl;
		temp_label1= label;
		label++;
		switch(m->nodekind_kind)
			{
				case 1 : outfile<<"         JG"<<lab<<temp_label1<<endl;
					break;
				case 2 : outfile<<"         JL"<<lab<<temp_label1<<endl;
					break;
				case 3 : outfile<<"         JE"<<lab<<temp_label1<<endl;
					break;
				case 4 : outfile<<"         JGE"<<lab<<temp_label1<<endl;
					break;
				case 5 : outfile<<"         JLE"<<lab<<temp_label1<<endl;
					break;
				case 6 : outfile<<"         JNE"<<lab<<temp_label1<<endl;
					break;
				default:ps_error("编译器出错");
			}
	    outfile<<"        MOV "<<vari_db<<serial_number<<",0"<<endl;
	    temp_label2=label;
	    label++;
	    outfile<<"        JMP "<<lab<<temp_label2<<endl;
	    outfile<<lab<<temp_label1<<":"<<endl;
	    outfile<<"        MOV "<<vari_db<<serial_number<<",1"<<endl;
	    outfile<<lab<<temp_label2<<":"<<endl;
	    db_tempstack.push(num);
	    db_tempstack.push(num1);
	}	
	else
	{
	    num=dd_tempstack.top();
	    dd_tempstack.pop();
	    dd_max=max(dd_max,num);    
	    single_node_stmt_print(m->child[0],num);
	    num1=dd_tempstack.top();
	    dd_tempstack.pop();
	    dd_max=max(dd_max,num1);
	    single_node_stmt_print(m->child[1],num1);
	    outfile<<"      MOV EAX "<<vari_dd<<num<<endl; 
	    outfile<<"      CMP EAX "<<vari_dd<<num1<<endl;
		temp_label1= label;
		label++;
		switch(m->nodekind_kind)
			{
				case 1 : outfile<<"         JG"<<lab<<temp_label1<<endl;
					break;
				case 2 : outfile<<"         JL"<<lab<<temp_label1<<endl;
					break;
				case 3 : outfile<<"         JE"<<lab<<temp_label1<<endl;
					break;
				case 4 : outfile<<"         JGE"<<lab<<temp_label1<<endl;
					break;
				case 5 : outfile<<"         JLE"<<lab<<temp_label1<<endl;
					break;
				case 6 : outfile<<"         JNE"<<lab<<temp_label1<<endl;
					break;
				default:ps_error("编译器出错");
			}
	    outfile<<"        MOV "<<vari_dd<<serial_number<<",0"<<endl;
	    temp_label2=label;
	    label++;
	    outfile<<"        JMP "<<lab<<temp_label2<<endl;
	    outfile<<lab<<temp_label1<<":"<<endl;
	    outfile<<"        MOV "<<vari_dd<<serial_number<<",1"<<endl;
	    outfile<<lab<<temp_label2<<":"<<endl;
	    db_tempstack.push(num);
	    db_tempstack.push(num1);
	}		
	return;
}			
		
void single_node_stmt_print(TreeNode * m,int serial_number)
{
    int num=0;
    int num1=0;
    int temp_label1=0;
    int temp_label2=0;
    switch(m->nodekind_kind)
    {
        case 1:    //stmt---->stmt+ID;
               switch((m->child[0])->stmt_type)
               {
                  case 1:  //char
                  case 2:  //bool
                        num=db_tempstack.top();
                        db_tempstack.pop();
                        db_max=max(db_max,num);
                        single_node_stmt_print(m->child[0],num);
                        db_tempstack.push(num);
                        outfile<<"      MOV AL,"<<vari_db<<num<<endl;  
                        outfile<<"      ADD AL,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
                        outfile<<"      MOV "<<vari_db<<serial_number<<" AL"<<endl;
                        break;
                  case 3:  //int
                  case 4:  //float
                        num=dd_tempstack.top();
                        dd_tempstack.pop();
                        dd_max=max(dd_max,num);
                        single_node_stmt_print(m->child[0],num);
                        dd_tempstack.push(num);
                       	outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					    outfile<<"		ADD EAX,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
				      	outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
				      	break;
				  default:ps_error("编译器出错");
				             	
               }
               break;
        case 2:       //stmt---->stmt+const
               switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		ADD AL,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		ADD EAX,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
        case 3:      //stmt---->stmt-ID
              switch((m->child[0])->stmt_type)
              {
                case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		SUB AL,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		SUB EAX,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
              }
              break;
        case 4:     //stmt---->stmt-const
              switch((m->child[0])->stmt_type)
              { 
                case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		SUB AL,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		SUB EAX,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
		 	}
			break;
		case 5:	    //stmt---->stmt * ID
              switch((m->child[0])->stmt_type)
			  {
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MOV BL,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		MUL BL"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		MOV EBX,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		MUL EBX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			  }
		   	  break;
		case 6:      //stmt---->stmt * const
		      switch((m->child[0])->stmt_type)
		      {
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MOV BL,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MUL BL"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		MOV EBX,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MUL EBX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			  }
			break;  	  
        case 7:			//stmt ---> stmt / ID";
	     	  switch((m->child[0])->stmt_type)
	 		  {
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MOV AH,0"<<endl;		
					outfile<<"		MOV BL,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		DIV BL"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		MOV BX,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		DIV BX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" AX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;         
      case 8:			//stmt ---> stmt / const";
			switch((m->child[0])->stmt_type)
			{
			   case 1:		//char
			   case 2:		//bool
				   num = db_tempstack.top();
				   db_tempstack.pop();
				   db_max = max(db_max,num);
				   single_node_stmt_print(m->child[0],num);
				   db_tempstack.push(num);
				   outfile<<"		MOV AL,"<<vari_db<<num<<endl;
				   outfile<<"		MOV AH,0"<<endl;		
				   outfile<<"		MOV BL,";
				   change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
				   outfile<<endl;
				   outfile<<"		DIV BL"<<endl;
				   outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
				   break;
				case 3:		//int
				case 4:		//float
				   num = dd_tempstack.top();
				   dd_tempstack.pop();
				   dd_max = max(dd_max,num);
				   single_node_stmt_print(m->child[0],num);
				   dd_tempstack.push(num);
				   outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
				   outfile<<"		MOV BX,";
				   change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
				   outfile<<endl;
				   outfile<<"		DIV BX"<<endl;
				   outfile<<"		MOV "<<vari_dd<<serial_number<<" AX"<<endl;
				   break;
				default:ps_error("编译器出错");
			}
			break;   
	case 9 :			//stmt ---> stmt % ID";
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MOV AH,0"<<endl;		
					outfile<<"		MOV BL,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		DIV BL"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AH"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		MOV BX,"<<symtable[int((m->child[1])->node_value)].lexptr<<endl;
					outfile<<"		DIV BX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAH"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 10 :			//stmt ---> stmt % const";
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
				    single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MOV AH,0"<<endl;		
					outfile<<"		MOV BL,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		DIV BL"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AH"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
					outfile<<"		MOV BX,";
					change_to_original_asm((m->child[1])->node_value,(m->child[1])->nodekind_kind);
					outfile<<endl;
					outfile<<"		DIV BX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAH"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 11 :			//stmt ---> - stmt;
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					db_tempstack.push(num);
					outfile<<"		MOV AL,"<<vari_db<<num<<endl;
					outfile<<"		MUL AL,-1"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<" AL"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					dd_tempstack.push(num);
					outfile<<"		MOV EAX,"<<vari_db<<num<<endl;
					outfile<<"		MUL EAX,-1"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<" EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 12 :			//stmt ---> stmt && rela_stmt;
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					num1 = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num1);
					single_node_rela_print(m->child[1],num1);
					outfile<<"		CMP"<<vari_db<<num<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		CMP"<<vari_db<<num1<<",0"<<endl;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<1<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<0<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					db_tempstack.push(num);
					db_tempstack.push(num1);
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					num1 = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num1);
					single_node_rela_print(m->child[1],num1);
					outfile<<"		CMP"<<vari_dd<<num<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		CMP"<<vari_dd<<num1<<",0"<<endl;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<1<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<0<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					dd_tempstack.push(num);
					dd_tempstack.push(num1);
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 13 :			//stmt ---> stmt || rela_stmt;
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					num = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num);
					single_node_stmt_print(m->child[0],num);
					num1 = db_tempstack.top();
					db_tempstack.pop();
					db_max = max(db_max,num1);
					single_node_rela_print(m->child[1],num1);
					outfile<<"		CMP"<<vari_db<<num<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JG "<<lab<<temp_label1<<endl;
					outfile<<"		CMP"<<vari_db<<num1<<",0"<<endl;
					outfile<<"		JG "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<0<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<1<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					db_tempstack.push(num);
					db_tempstack.push(num1);
					break;
				case 3:		//int
				case 4:		//float
					num = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num);
					single_node_stmt_print(m->child[0],num);
					num1 = dd_tempstack.top();
					dd_tempstack.pop();
					dd_max = max(dd_max,num1);
					single_node_rela_print(m->child[1],num1);
					outfile<<"		CMP"<<vari_dd<<num<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JG "<<lab<<temp_label1<<endl;
					outfile<<"		CMP"<<vari_dd<<num1<<",0"<<endl;
					outfile<<"		JG "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<0<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<1<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					dd_tempstack.push(num);
					dd_tempstack.push(num1);
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 14 :			//stmt ---> ! stmt;
			switch((m->child[0])->stmt_type)
			{
				case 1:		//char
				case 2:		//bool
					single_node_stmt_print(m->child[0],serial_number);
					outfile<<"		CMP "<<vari_db<<serial_number<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<",0"<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<",1"<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					break;
				case 3:		//int
				case 4:		//float
					single_node_stmt_print(m->child[0],serial_number);
					outfile<<"		CMP "<<vari_dd<<serial_number<<",0"<<endl;
					temp_label1 = label;
					label++;
					outfile<<"		JLE "<<lab<<temp_label1<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",0"<<endl;
					temp_label2 = label;
					label++;
					outfile<<"		JMP "<<lab<<temp_label2<<endl;
					outfile<<lab<<temp_label1<<":"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",1"<<endl;
					outfile<<lab<<temp_label2<<":"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 15 :			//stmt ---> rela_stmt;
			single_node_rela_print(m->child[0],serial_number);
			break;
		case 16 :			//stmt ---> ID";
			switch(m->stmt_type)
			{
				case 1:
				case 2:
					outfile<<"		MOV AL,"<<symtable[int((m->child[0])->node_value)].lexptr<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<",AL"<<endl;
					break;
				case 3:
				case 4:
					outfile<<"		MOV EAX,"<<symtable[int((m->child[0])->node_value)].lexptr<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;  
		case 17 :			//stmt ---> ID ++";
			switch(m->stmt_type)
			{

				case 3:

     				outfile<<"		MOV EAX,"<<symtable[int((m->child[0])->node_value)].lexptr<<endl;
					outfile<<"		ADD EAX,1"<<endl;
					outfile<<"		MOV "<<symtable[int((m->child[0])->node_value)].lexptr<<",EAX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 18 :			//stmt ---> ID --";
			switch(m->stmt_type)
			{
		        case 3:	    
		            outfile<<"		MOV EAX,"<<symtable[int((m->child[0])->node_value)].lexptr<<endl;
					outfile<<"		SUB EAX,1"<<endl;
					outfile<<"		MOV "<<symtable[int((m->child[0])->node_value)].lexptr<<",EAX"<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 19 :			//stmt ---> const";
			switch(m->stmt_type)
			{
				case 1:
				case 2:
					outfile<<"		MOV AL,";
					change_to_original_asm((m->child[0])->node_value,(m->child[0])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_db<<serial_number<<",AL"<<endl;
					break;
				case 3:
				case 4:
					outfile<<"		MOV EAX,";
					change_to_original_asm((m->child[0])->node_value,(m->child[0])->nodekind_kind);
					outfile<<endl;
					outfile<<"		MOV "<<vari_dd<<serial_number<<",EAX"<<endl;
					break;
				default:ps_error("编译器出错");
			}
			break;
		case 20 :			//stmt ---> ( stmt )";
			single_node_stmt_print(m->child[0],serial_number);
			break;
		default:ps_error("编译器出错");		
    }
    return;
}		
		
void single_node_other_print(TreeNode*m)//打印单个节点(prog,lines,expr)对应的汇编代码
{
    	if(m == NULL)
	{
		return;
	}
	int num = 0;
	int temp_label1 = 0;
	int temp_label2 = 0;
	switch(m->nodekind)
	{
		case kind_prog:				//prog
			single_node_other_print(m->child[0]);	//prog --> VOID  MAIN LLSBRA lines RLSBRA
			break;
		case kind_lines:           //lines
			switch(m->nodekind_kind)
			{
				case 1 :			//lines --> lines expr	
					single_node_other_print(m->child[0]);
					single_node_other_print(m->child[1]);
					break;
				case 2 :			//lines --> expr
					single_node_other_print(m->child[0]);
					break;
				default:ps_error("编译器出错");
			}
			break;
		case kind_expr:				//expr
			switch(m->nodekind_kind)
			{
				case 1 :			//expr --> type ID,变量声明已经在数据段作过了
					break;
				case 2 :			//expr --> type ID = stmt
					switch((m->child[0])->nodekind_kind)
					{
						case 1:		//char
						case 2:		//bool
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							single_node_stmt_print(m->child[2],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		MOV "<<symtable[int((m->child[1])->node_value)].lexptr<<" AL"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							single_node_stmt_print(m->child[2],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		MOV "<<symtable[int((m->child[1])->node_value)].lexptr<<" EAX"<<endl;
							break;
						default:ps_error("编译器出错");
					}
					break;
				case 3 :			//expr --> ID = stmt
					switch(symtable[int((m->child[0])->node_value)].type)
					{
						case 1:		//char
						case 2:		//bool
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							single_node_stmt_print(m->child[1],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		MOV "<<symtable[int((m->child[0])->node_value)].lexptr<<" AL"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							single_node_stmt_print(m->child[1],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		MOV "<<symtable[int((m->child[0])->node_value)].lexptr<<" EAX"<<endl;
							break;
						default:ps_error("编译器出错");
					}
					break;
				case 4 :			//expr --> if ( stmt ) { lines }
					switch((m->child[0])->stmt_type)
					{
						case 1:		//char
						case 2:		//bool
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							single_node_stmt_print(m->child[0],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		CMP AL,0"<<endl;
							temp_label1 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label1<<endl;
							single_node_other_print(m->child[1]);
							outfile<<lab<<temp_label1<<":"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							single_node_stmt_print(m->child[1],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		CMP EAX,0"<<endl;
							temp_label1 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label1<<endl;
							single_node_other_print(m->child[1]);
							outfile<<lab<<temp_label1<<":"<<endl;
							break;
						default:ps_error("编译器出错");	 
					}
					break;
				case 5 :			//expr --> if ( stmt ) { lines } else { lines }
					switch((m->child[0])->stmt_type)
					{
						case 1:		//char
						case 2:		//bool
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							single_node_stmt_print(m->child[0],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		CMP AL,0"<<endl;
							temp_label1 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label1<<endl;
							single_node_other_print(m->child[1]);
							temp_label2 = label;
							label++;
							outfile<<"		JMP "<<temp_label2<<label<<endl;
							outfile<<lab<<temp_label1<<":"<<endl;
							single_node_other_print(m->child[2]);
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							single_node_stmt_print(m->child[0],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		CMP EAX,0"<<endl;
							temp_label1 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label1<<endl;
							single_node_other_print(m->child[1]);
							temp_label2 = label;
							label++;
							outfile<<"		JMP "<<lab<<temp_label2<<endl;
							outfile<<lab<<temp_label1<<":"<<endl;
							single_node_other_print(m->child[2]);
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						default:ps_error("编译器出错");	
					}
					break;
				case 6 :			//expr --> for( expr;stmt;expr ) { lines }
					single_node_other_print(m->child[0]);
					switch((m->child[1])->stmt_type)
					{
						case 1:		//char
						case 2:		//bool
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							temp_label1 = label;
							label++;
							outfile<<"		"<<lab<<temp_label1<<":"<<endl;
							single_node_stmt_print(m->child[1],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		CMP AL,0"<<endl;
							temp_label2 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label2<<endl;	
							single_node_other_print(m->child[3]);
							single_node_other_print(m->child[2]);
							outfile<<"		JMP "<<lab<<temp_label1<<endl;
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							temp_label1 = label;
							label++;
							outfile<<"		"<<lab<<temp_label1<<":"<<endl;
							single_node_stmt_print(m->child[1],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		CMP EAX,0"<<endl;
							temp_label2 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label2<<endl;	
							single_node_other_print(m->child[3]);
							single_node_other_print(m->child[2]);
							outfile<<"		JMP "<<lab<<temp_label1<<endl;
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						default:ps_error("编译器出错");	 
					}
					break;
				case 7 :			//while ( stmt ) { lines };
					switch((m->child[0])->stmt_type)
					{
						case 1:		//char
						case 2:		//bool
							temp_label1 = label;
							label++;
							outfile<<lab<<temp_label1<<":"<<endl;
							num = db_tempstack.top();
							db_tempstack.pop();
							db_max = max(db_max,num);
							single_node_stmt_print(m->child[0],num);
							db_tempstack.push(num);
							outfile<<"		MOV AL,"<<vari_db<<num<<endl;
							outfile<<"		CMP AL,0"<<endl;
							temp_label2 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label2<<endl;
							single_node_other_print(m->child[1]);
							outfile<<"		JMP "<<lab<<temp_label1<<endl;
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						case 3:		//int
						case 4:		//float
							temp_label1 = label;
							label++;
							outfile<<lab<<temp_label1<<":"<<endl;
							num = dd_tempstack.top();
							dd_tempstack.pop();
							dd_max = max(dd_max,num);
							single_node_stmt_print(m->child[0],num);
							dd_tempstack.push(num);
							outfile<<"		MOV EAX,"<<vari_dd<<num<<endl;
							outfile<<"		CMP EAX,0"<<endl;
							temp_label2 = label;
							label++;
							outfile<<"		JLE "<<lab<<temp_label2<<endl;
							single_node_other_print(m->child[1]);
							outfile<<"		JMP "<<lab<<temp_label1<<endl;
							outfile<<lab<<temp_label2<<":"<<endl;
							break;
						default:ps_error("编译器出错");	 
					}
					break;
				default:ps_error("编译器出错");
			}
			break;
		default:ps_error("编译器出错");
	}
	return;
}			

void assembly_language_print()
{
  
	//符号表中的变量添加到数据段
	outfile<<"DATA		SEGMENT"<<endl;
	for(int i = 1;i <= lastentry;i++)
	{
		switch(symtable[i].type)
		{
		    case 1:outfile<<"	"<<symtable[i].lexptr<<" DB  "<<" ' "<<symtable[i].lexptr<<" ' "<<",0DH ,0AH,'$'"<<endl;
				break;
			case 2:outfile<<"	"<<symtable[i].lexptr<<" DB ?"<<endl;
				break;
			case 3:outfile<<"	"<<symtable[i].lexptr<<" DD ?"<<endl;
				break;
			case 4:outfile<<"	"<<symtable[i].lexptr<<" DD ?"<<endl;
				break;
			default:ps_error("编译器出错");
				exit(0);
		}
	}
	outfile<<"DATA		ENDS"<<endl;
	//下面开始输出代码段,首先装填数据段
	outfile<<"CODE		SEGMENT"<<endl;
	outfile<<"		ASSUME CS:CODE,DS:DATA"<<endl;
	outfile<<"BEGIN:		MOV AX,DATA"<<endl;
	outfile<<"		MOV DS,AX"<<endl;
	//下面开始输出正文段的代码
	for(i=500;i>=1;i--)//对临时变量对应标号的堆栈进行初始化
	{
		db_tempstack.push(i);//字节型变量
		dd_tempstack.push(i);//双字型变量
	}
	single_node_other_print(root);
	outfile<<"          MOVE AX,4CH"<<endl;
	outfile<<"          INT 21H"<<endl;
	outfile<<"CODE		ENDS"<<endl;
	outfile<<"		END BEGIN"<<endl;
	outfile.close();
	outfile.open("output.asm",ios::app); //1.ios::app     ----写入的数据将被追加在文件的末尾 
    
                                        //ios::app   多个线程或者进程对一个文件写的时候,假如文件原来的内容是abc
                                        //第一个线程(进程)往里面写了个d,第二个线程(进程)写了个e的话，结果是abcde  
     
    

	outfile.seekp(200,ios::beg);
	
	outfile<<endl;
	
	
	for(i = 1;i <= db_max;i++)
	{
		outfile<<"		"<<vari_db<<i<<" DB ?"<<endl;
	}
	for(i = 1;i <= dd_max;i++)
	{
		outfile<<"		"<<vari_dd<<i<<" DD ?"<<endl;
	}
	

	return;
}



int main(void)
{
    lastentry=0;
	
	int n = 1;
	
	mylexer lexer;
	
	myparser parser;
	
	if (parser.yycreate(&lexer)) {
		
		if (lexer.yycreate(&parser)) {
		
			lexer.yyin = new ifstream("yyinn.txt");
		    
			n = parser.yyparse();
		}
	}
	
	//lexer.yyin=new ifstream("output.txt");
	
	outfile.close();
	
	return n;
}

