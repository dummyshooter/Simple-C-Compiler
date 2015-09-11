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
* myparser.cpp
* C++ source file generated from myparser.y.
* 
* Date: 12/15/08
* Time: 08:20:05
* 
* AYACC Version: 2.06
****************************************************************************/

#include <yycpars.h>

// namespaces
#ifdef YYSTDCPPLIB
using namespace std;
#endif
#ifdef YYNAMESPACE
using namespace yl;
#endif

#line 1 ".\\myparser.y"

/****************************************************************************
myparser.y
ParserWizard generated YACC file.

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

ofstream outfile("output.asm"); //写文件

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

	


#line 177 "myparser.cpp"
// repeated because of possible precompiled header
#include <yycpars.h>

// namespaces
#ifdef YYSTDCPPLIB
using namespace std;
#endif
#ifdef YYNAMESPACE
using namespace yl;
#endif

#include ".\myparser.h"

/////////////////////////////////////////////////////////////////////////////
// constructor

YYPARSERNAME::YYPARSERNAME()
{
	yytables();
#line 152 ".\\myparser.y"

	// place any extra initialisation code here

#line 201 "myparser.cpp"
}

/////////////////////////////////////////////////////////////////////////////
// destructor

YYPARSERNAME::~YYPARSERNAME()
{
	// allows virtual functions to be called properly for correct cleanup
	yydestroy();
#line 157 ".\\myparser.y"

	// place any extra cleanup code here

#line 215 "myparser.cpp"
}

#ifndef YYSTYPE
#define YYSTYPE int
#endif
#ifndef YYSTACK_SIZE
#define YYSTACK_SIZE 100
#endif
#ifndef YYSTACK_MAX
#define YYSTACK_MAX 0
#endif

/****************************************************************************
* N O T E
* 
* If the compiler generates a YYPARSERNAME error then you have not declared
* the name of the parser. The easiest way to do this is to use a name
* declaration. This is placed in the declarations section of your YACC
* source file and is introduced with the %name keyword. For instance, the
* following name declaration declares the parser myparser:
* 
* %name myparser
* 
* For more information see help.
****************************************************************************/

// yyattribute
#ifdef YYDEBUG
void YYFAR* YYPARSERNAME::yyattribute1(int index) const
{
	YYSTYPE YYFAR* p = &((YYSTYPE YYFAR*)yyattributestackptr)[yytop + index];
	return p;
}
#define yyattribute(index) (*(YYSTYPE YYFAR*)yyattribute1(index))
#else
#define yyattribute(index) (((YYSTYPE YYFAR*)yyattributestackptr)[yytop + (index)])
#endif

void YYPARSERNAME::yystacktoval(int index)
{
	yyassert(index >= 0);
	*(YYSTYPE YYFAR*)yyvalptr = ((YYSTYPE YYFAR*)yyattributestackptr)[index];
}

void YYPARSERNAME::yyvaltostack(int index)
{
	yyassert(index >= 0);
	((YYSTYPE YYFAR*)yyattributestackptr)[index] = *(YYSTYPE YYFAR*)yyvalptr;
}

void YYPARSERNAME::yylvaltoval()
{
	*(YYSTYPE YYFAR*)yyvalptr = *(YYSTYPE YYFAR*)yylvalptr;
}

void YYPARSERNAME::yyvaltolval()
{
	*(YYSTYPE YYFAR*)yylvalptr = *(YYSTYPE YYFAR*)yyvalptr;
}

void YYPARSERNAME::yylvaltostack(int index)
{
	yyassert(index >= 0);
	((YYSTYPE YYFAR*)yyattributestackptr)[index] = *(YYSTYPE YYFAR*)yylvalptr;
}

void YYFAR* YYPARSERNAME::yynewattribute(int count)
{
	yyassert(count >= 0);
	return new YYFAR YYSTYPE[count];
}

void YYPARSERNAME::yydeleteattribute(void YYFAR* attribute)
{
	delete[] (YYSTYPE YYFAR*)attribute;
}

void YYPARSERNAME::yycopyattribute(void YYFAR* dest, const void YYFAR* src, int count)
{
	for (int i = 0; i < count; i++) {
		((YYSTYPE YYFAR*)dest)[i] = ((YYSTYPE YYFAR*)src)[i];
	}
}

#ifdef YYDEBUG
void YYPARSERNAME::yyinitdebug(void YYFAR** p, int count) const
{
	yyassert(p != NULL);
	yyassert(count >= 1);

	YYSTYPE YYFAR** p1 = (YYSTYPE YYFAR**)p;
	for (int i = 0; i < count; i++) {
		p1[i] = &((YYSTYPE YYFAR*)yyattributestackptr)[yytop + i - (count - 1)];
	}
}
#endif

void YYPARSERNAME::yyaction(int action)
{
	switch (action) {
	case 0:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 231 ".\\myparser.y"
								//该根结点类型为kind_prog,nodekind_kind为1,有一个孩子结点:kind_lines
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(4 - 5);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_prog;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
					root = (*(YYSTYPE YYFAR*)yyvalptr) ;
				
					outfile<<endl;
					
					outfile<<"源程序对应的汇编代码如下:"<<endl;
					
					outfile<<endl;	
					
					assembly_language_print();	
				
#line 339 "myparser.cpp"
			}
		}
		break;
	case 1:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 249 ".\\myparser.y"
								//该程序段结点类型为kind_lines,nodekind_kind为1,有两个孩子结点:kind_lines,kind_expr
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(2 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_lines;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
					yyattribute(1 - 2)->sibling = yyattribute(2 - 2);			//lines的右兄弟结点为expr
					
				//	node_print($$);
				
#line 361 "myparser.cpp"
			}
		}
		break;
	case 2:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 260 ".\\myparser.y"

					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 1);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_lines;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 2;
				//	node_print($$);
				
#line 380 "myparser.cpp"
			}
		}
		break;
	case 3:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 270 ".\\myparser.y"
								//  对应的expr语法树结点类型为kind_expr,nodekind_kind为1,有两个孩子结点:kind_type,kind_ID
					yyattribute(2 - 2)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(2 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
					yyattribute(2 - 2)->nodekind = kind_ID;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
					yyattribute(1 - 2)->sibling = yyattribute(2 - 2);			//type的右兄弟结点为ID
					
					if(symtable[int(yyattribute(2 - 2)->node_value)].type>0)//检查ID是否已经定义,$2->node_entry->type大于0表明该ID类型已确定,即该ID已经定义
					{
						ps_error(("重定义"));//报错，但语法分析器将继续分析
					}
					
					symtable[int(yyattribute(2 - 2)->node_value)].type = yyattribute(1 - 2)->nodekind_kind; //将type对应的类型赋值给ID对应的变量类型:1表示char型,2表示bool型,3表示int型,4表示float型
				//	node_print($2);
				//	node_print($$);
				
#line 412 "myparser.cpp"
			}
		}
		break;
	case 4:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[5];
			yyinitdebug((void YYFAR**)yya, 5);
#endif
			{
#line 291 ".\\myparser.y"
						//  对应的expr语法树结点类型为kind_expr,nodekind_kind为2,有三个孩子结点:kind_type,kind_ID,kind_stmt
					yyattribute(2 - 4)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 4);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(2 - 4);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[2] = yyattribute(4 - 4);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
					yyattribute(2 - 4)->nodekind = kind_ID;
			    	
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 2;
					yyattribute(1 - 4)->sibling = yyattribute(2 - 4);
					yyattribute(2 - 4)->sibling = yyattribute(4 - 4);
					if(symtable[int(yyattribute(2 - 4)->node_value)].type>0)//检查ID是否已经定义,$2->node_entry->type大于0表明该ID类型已确定,即该ID已经定义
					{
						ps_error("重定义");//报错，但语法分析器将继续分析
					}
					symtable[int(yyattribute(2 - 4)->node_value)].type = yyattribute(1 - 4)->nodekind_kind; //将type对应的类型赋值给ID对应的变量类型:1表示char型,2表示bool型,3表示int型,4表示float型
					
				
				
					//检查type的类型是否和stmt的类型相匹配,当类型不相匹配时,将尝试进行强制类型转换
			        //当强制转换导致信息丢失(float型转换为int型)时将打印警告信息
					//当强制转换导致错误(int型值大于等于128时转换成char型变量)时将打印错误信息，但语法分析器将继续工作(int型值大于127时转换成char型变量'0'即NULL)
					//但强制转换将留给符号表自身完成
					if((symtable[int(yyattribute(2 - 4)->node_value)].type)!=(yyattribute(4 - 4)->stmt_type))
					{
						if(yyattribute(4 - 4)->stmt_type == 4) //当stmt为float型时，一定造成信息丢失，可能产生错误
						{
							if((symtable[int(yyattribute(2 - 4)->node_value)].type) ==1)	//当ID为char型时
							{
								if(yyattribute(4 - 4)->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int(yyattribute(2 - 4)->node_value)].token = 0;
								}
								else
								{
									warning("类型转换导致信息丢失");
									symtable[int(yyattribute(2 - 4)->node_value)].token = yyattribute(4 - 4)->node_value;
								}
							}
							else
							{
								warning("类型转换导致信息丢失");
								symtable[int(yyattribute(2 - 4)->node_value)].token = yyattribute(4 - 4)->node_value;
							}
						}
						else
						{
							if(yyattribute(4 - 4)->stmt_type == 3)	//当stmt为int型时,可能产生错误
							{
								if(yyattribute(4 - 4)->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int(yyattribute(2 - 4)->node_value)].token = 0;
								}
								else
								{
									symtable[int(yyattribute(2 - 4)->node_value)].token = yyattribute(4 - 4)->node_value;  //正常赋值
								}	
							}
							else	  //正常赋值
							{
								symtable[int(yyattribute(2 - 4)->node_value)].token = yyattribute(4 - 4)->node_value;  
							}
						}
					}
					else
					{
						symtable[int(yyattribute(2 - 4)->node_value)].token = yyattribute(4 - 4)->node_value;  //正常赋值
					}
				//	node_print($2);
				//	node_print($$);
				
#line 499 "myparser.cpp"
			}
		}
		break;
	case 5:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 367 ".\\myparser.y"
						//  对应的expr语法树结点类型为kind_expr,nodekind_kind为3,有两个孩子结点:kind_ID,kind_stmt
					yyattribute(1 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 3);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(3 - 3);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
					yyattribute(1 - 3)->nodekind = kind_ID;
				
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 3;
					yyattribute(1 - 3)->sibling = yyattribute(3 - 3);
					
					if(symtable[int(yyattribute(1 - 3)->node_value)].type<=0)//检查ID是否已经定义,$2->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(1 - 3)->node_value)].type = yyattribute(3 - 3)->stmt_type;	//此时,stmt将完全赋值给ID
						symtable[int(yyattribute(1 - 3)->node_value)].token = yyattribute(3 - 3)->node_value;
					//	node_print($1);
					//	node_print($$);
						return;
					}
					
					//检查ID的类型是否和stmt的类型相匹配,当类型不相匹配时,将尝试进行强制类型转换
					//当强制转换导致信息丢失(float型转换为int型)时将打印警告信息
					//当强制转换导致错误(int型值大于等于128时转换成char型变量)时将打印错误信息，但语法分析器将继续工作(int型值大于127时转换成char型变量'0'即NULL)
					//但强制转换将留给符号表自身完成
					if((symtable[int(yyattribute(1 - 3)->node_value)].type)!=(yyattribute(3 - 3)->stmt_type))
					{
						if(yyattribute(3 - 3)->stmt_type == 4) //当stmt为float型时，一定造成信息丢失，可能产生错误
						{
							if((symtable[int(yyattribute(1 - 3)->node_value)].type) ==1)	//当ID为char型时
							{
								if(yyattribute(3 - 3)->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int(yyattribute(1 - 3)->node_value)].token = 0;
								}
							}
							else
							{
								warning("类型转换导致信息丢失");
								symtable[int(yyattribute(1 - 3)->node_value)].token = yyattribute(3 - 3)->node_value;
							}
						}
						else
						{
							if(yyattribute(3 - 3)->stmt_type == 3)	//当stmt为int型时,可能产生错误
							{
								if(yyattribute(3 - 3)->node_value >= 128)	//int型值大于等于128时转换成char型变量,产生错误	
								{
									ps_error("类型转换导致错误");
									symtable[int(yyattribute(1 - 3)->node_value)].token = 0;
								}
								else
								{
									symtable[int(yyattribute(1 - 3)->node_value)].token = yyattribute(3 - 3)->node_value;  //正常赋值
								}	
							}
							else	  //正常赋值
							{
								symtable[int(yyattribute(1 - 3)->node_value)].token = yyattribute(3 - 3)->node_value;  
							}
						}
					}
					else
					{
						symtable[int(yyattribute(1 - 3)->node_value)].token = yyattribute(3 - 3)->node_value;  //正常赋值
					}
				//	node_print($1);
				//	node_print($$);
				
#line 582 "myparser.cpp"
			}
		}
		break;
	case 6:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[8];
			yyinitdebug((void YYFAR**)yya, 8);
#endif
			{
#line 439 ".\\myparser.y"
					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_lines
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(3 - 7);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(6 - 7);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
				
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 4;
					yyattribute(3 - 7)->sibling = yyattribute(6 - 7);
					if(yyattribute(3 - 7)->stmt_type == 4)
					{
						ps_error("IF 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				
#line 608 "myparser.cpp"
			}
		}
		break;
	case 7:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[12];
			yyinitdebug((void YYFAR**)yya, 12);
#endif
			{
#line 454 ".\\myparser.y"
					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为5,有三个孩子结点:kind_stmt,kind_lines,kind_lines
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(3 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(6 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[2] = yyattribute(10 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
				
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 5;
					yyattribute(3 - 11)->sibling = yyattribute(6 - 11);
					yyattribute(6 - 11)->sibling = yyattribute(10 - 11);
					if(yyattribute(3 - 11)->stmt_type == 4)
					{
						ps_error("IF 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				
#line 636 "myparser.cpp"
			}
		}
		break;
	case 8:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[12];
			yyinitdebug((void YYFAR**)yya, 12);
#endif
			{
#line 471 ".\\myparser.y"
					   //  对应的expr语法树结点类型为kind_expr,nodekind_kind为6,有四个孩子结点:kind_expr,kind_stmt,kind_expr,kind_lines
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(3 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(5 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[2] = yyattribute(7 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[3] = yyattribute(10 - 11);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
			
					
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 6;
					yyattribute(3 - 11)->sibling = yyattribute(5 - 11);
					yyattribute(5 - 11)->sibling = yyattribute(7 - 11);
					yyattribute(7 - 11)->sibling = yyattribute(10 - 11);
					if(yyattribute(5 - 11)->stmt_type == 4)
					{
						ps_error("IF-ELES 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				
#line 667 "myparser.cpp"
			}
		}
		break;
	case 9:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[8];
			yyinitdebug((void YYFAR**)yya, 8);
#endif
			{
#line 491 ".\\myparser.y"
					//  对应的expr语法树结点类型为kind_expr,nodekind_kind为7,有两个孩子结点:kind_stmt,kind_lines	
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(3 - 7);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[1] = yyattribute(6 - 7);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_expr;
					yyattribute(3 - 7)->nodekind = kind_stmt;
					yyattribute(6 - 7)->nodekind = kind_lines;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 7;
					yyattribute(3 - 7)->sibling = yyattribute(6 - 7);
					if(yyattribute(3 - 7)->stmt_type == 4)
					{
						ps_error("WHILE 语句中表达式的值不能为float型"); //当stmt为float型时，打印错误信息
					}
				//	node_print($$);
				
#line 694 "myparser.cpp"
			}
		}
		break;
	case 10:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 509 ".\\myparser.y"
						//  对应的stmt语法树结点类型为kind_stmt,nodekind_kind为1,有两个孩子结点:kind_stmt,kind_ID
					yyattribute(3 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
					if(symtable[int(yyattribute(3 - 3)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(3 - 3)->node_value)].type = yyattribute(1 - 3)->stmt_type;	//此时,stmt的类型将赋值给ID
						symtable[int(yyattribute(3 - 3)->node_value)].token = 0;			//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push(yyattribute(3 - 3)->node_value);
					yyattribute(3 - 3)->nodekind_kind = symtable[int(yyattribute(3 - 3)->node_value)].type;
					yyattribute(3 - 3)->node_value = symtable[int(yyattribute(3 - 3)->node_value)].token ;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'+');
					yyattribute(3 - 3)->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				
#line 731 "myparser.cpp"
			}
		}
		break;
	case 11:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 535 ".\\myparser.y"
						//	对应的stmt语法树节点类型为kind-stmt,nodekind_kind为2,有两个孩子结点:kind_stmt,kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 2;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'+');
				//	node_print($$);
				
#line 752 "myparser.cpp"
			}
		}
		break;
	case 12:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 545 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为3,有两个孩子结点:kind_stmt,kind_ID
					yyattribute(3 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 3;
					if(symtable[int(yyattribute(3 - 3)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(3 - 3)->node_value)].type = yyattribute(1 - 3)->stmt_type;	//此时,stmt的类型将赋值给ID
						symtable[int(yyattribute(3 - 3)->node_value)].token = 0;			//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					
					idstack.push(yyattribute(3 - 3)->node_value);
					yyattribute(3 - 3)->nodekind_kind = symtable[int(yyattribute(3 - 3)->node_value)].type;
					yyattribute(3 - 3)->node_value = symtable[int(yyattribute(3 - 3)->node_value)].token ;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'-');
					yyattribute(3 - 3)->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				
#line 788 "myparser.cpp"
			}
		}
		break;
	case 13:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 570 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 4;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'-');
				//	node_print($$);
				
#line 809 "myparser.cpp"
			}
		}
		break;
	case 14:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 580 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为5,有两个孩子结点:kind_stmt,kind_ID
					yyattribute(3 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 5;
					if(symtable[int(yyattribute(3 - 3)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(3 - 3)->node_value)].type = yyattribute(1 - 3)->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int(yyattribute(3 - 3)->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push(yyattribute(3 - 3)->node_value);
					yyattribute(3 - 3)->nodekind_kind = symtable[int(yyattribute(3 - 3)->node_value)].type;
					yyattribute(3 - 3)->node_value = symtable[int(yyattribute(3 - 3)->node_value)].token ;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'*');
					yyattribute(3 - 3)->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				
#line 844 "myparser.cpp"
			}
		}
		break;
	case 15:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 604 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为6,有两个孩子结点:kind_stmt,kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 6;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'*');
				//	node_print($$);
				
#line 865 "myparser.cpp"
			}
		}
		break;
	case 16:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 614 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为7,有两个孩子结点:kind_stmt,kind_ID
					yyattribute(3 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 7;
					if(symtable[int(yyattribute(3 - 3)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(3 - 3)->node_value)].type = yyattribute(1 - 3)->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int(yyattribute(3 - 3)->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push(yyattribute(3 - 3)->node_value);
					yyattribute(3 - 3)->nodekind_kind = symtable[int(yyattribute(3 - 3)->node_value)].type;
					yyattribute(3 - 3)->node_value = symtable[int(yyattribute(3 - 3)->node_value)].token ;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'/');
					yyattribute(3 - 3)->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				
#line 900 "myparser.cpp"
			}
		}
		break;
	case 17:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 638 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为8,有两个孩子结点:kind_stmt,kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 8;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'/');
				//	node_print($$);
				
#line 921 "myparser.cpp"
			}
		}
		break;
	case 18:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 648 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为9,有两个孩子结点:kind_stmt,kind_const
					yyattribute(3 - 3)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 9;
					if(symtable[int(yyattribute(3 - 3)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(3 - 3)->node_value)].type = yyattribute(1 - 3)->stmt_type;			//此时,stmt的类型将赋值给ID
						symtable[int(yyattribute(3 - 3)->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					idstack.push(yyattribute(3 - 3)->node_value);
					yyattribute(3 - 3)->nodekind_kind = symtable[int(yyattribute(3 - 3)->node_value)].type;
					yyattribute(3 - 3)->node_value = symtable[int(yyattribute(3 - 3)->node_value)].token ;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'%');
					yyattribute(3 - 3)->node_value = idstack.top();
					idstack.pop();
				//	node_print($3);
				//	node_print($$);
				
#line 956 "myparser.cpp"
			}
		}
		break;
	case 19:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 672 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为10,有两个孩子结点:kind_stmt,kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 10;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'%');
				//	node_print($$);
				
#line 977 "myparser.cpp"
			}
		}
		break;
	case 20:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 682 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为11,有一个孩子结点:kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(2 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 11;
					(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = yyattribute(2 - 2)->stmt_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = - yyattribute(2 - 2)->node_value;
				//	node_print($$);
				
#line 998 "myparser.cpp"
			}
		}
		break;
	case 21:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 692 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为12,有两个孩子结点:kind_stmt,kind_rela_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 12;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'&');
				//	node_print($$);
				
#line 1019 "myparser.cpp"
			}
		}
		break;
	case 22:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 702 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为13,有两个孩子结点:kind_stmt,kind_rela_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 13;
					stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(1 - 3),yyattribute(3 - 3),'|');
				//	node_print($$);
				
#line 1040 "myparser.cpp"
			}
		}
		break;
	case 23:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 712 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为14,有一个孩子结点:kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(2 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 14;
					(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 2;
					if(yyattribute(2 - 2)->stmt_type == 4)	//当stmt为float型时,报错
					{
						ps_error("逻辑表达式的不能为float型");
					}
					if(yyattribute(2 - 2)->node_value > 0)
					{
						(*(YYSTYPE YYFAR*)yyvalptr)->node_value = 0;
					}
					else
					{
						(*(YYSTYPE YYFAR*)yyvalptr)->node_value = 1;
					}
				//	node_print($$);
				
#line 1072 "myparser.cpp"
			}
		}
		break;
	case 24:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 733 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为15,有一个孩子结点:kind_rela_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 1);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 15;
					(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 2;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;
				//	node_print($$);
				
#line 1093 "myparser.cpp"
			}
		}
		break;
	case 25:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 743 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为16,有一个孩子结点:kind_ID
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 1);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 16;
					if(symtable[int(yyattribute(1 - 1)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(1 - 1)->node_value)].type = 1;	//此时,将ID的类型强制赋值为char型
						symtable[int(yyattribute(1 - 1)->node_value)].token = 0;		//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = symtable[int(yyattribute(1 - 1)->node_value)].type;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = symtable[int(yyattribute(1 - 1)->node_value)].token;
				//	node_print($1);
				//	node_print($$);
				
#line 1123 "myparser.cpp"
			}
		}
		break;
	case 26:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 762 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为17,有一个孩子结点:kind_ID	
					yyattribute(1 - 2)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					TreeNode *test = (*(YYSTYPE YYFAR*)yyvalptr);
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 17;
					if(symtable[int(yyattribute(1 - 2)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(1 - 2)->node_value)].type = 1;			//此时,将ID的类型强制赋值为char型
						symtable[int(yyattribute(1 - 2)->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					else
					{
						if(symtable[int(yyattribute(1 - 2)->node_value)].type != 4)
						{
							ps_error("变量应为int型");
						}
						else
						{
							symtable[int(yyattribute(1 - 2)->node_value)].token = symtable[int(yyattribute(1 - 2)->node_value)].token + 1;
							(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = symtable[int(yyattribute(1 - 2)->node_value)].type;
							(*(YYSTYPE YYFAR*)yyvalptr)->node_value = symtable[int(yyattribute(1 - 2)->node_value)].token;
						}
					}
				//	node_print($1);
				//	node_print($$);
				
#line 1165 "myparser.cpp"
			}
		}
		break;
	case 27:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[3];
			yyinitdebug((void YYFAR**)yya, 3);
#endif
			{
#line 793 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为18,有一个孩子结点:kind_ID
					yyattribute(1 - 2)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 2);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 18;
					if(symtable[int(yyattribute(1 - 2)->node_value)].type<=0)//检查ID是否已经定义,$3->node_entry->type小于等于0表明该ID类型未确定,即该ID未定义
					{
						ps_error("未定义");//报错，但语法分析器将继续分析
						symtable[int(yyattribute(1 - 2)->node_value)].type = 1;			//此时,将ID的类型强制赋值为char型
						symtable[int(yyattribute(1 - 2)->node_value)].token = 0;					//将为定义的ID初值赋为0,以便语法分析器继续分析
					}
					else
					{
						if(symtable[int(yyattribute(1 - 2)->node_value)].type != 4)
						{
							ps_error("变量应为int型");
						}
						else
						{
							symtable[int(yyattribute(1 - 2)->node_value)].token = symtable[int(yyattribute(1 - 2)->node_value)].token - 1;
							(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = symtable[int(yyattribute(1 - 2)->node_value)].type;
							(*(YYSTYPE YYFAR*)yyvalptr)->node_value = symtable[int(yyattribute(1 - 2)->node_value)].token;
						}
					}
				//	node_print($1);
				//	node_print($$);	
				
#line 1206 "myparser.cpp"
			}
		}
		break;
	case 28:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 823 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为19,有一个孩子结点:kind_const
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(1 - 1);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 19;
					switch(yyattribute(1 - 1)->nodekind_kind)
					{
						case 1:(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 1;
							break;
			
						case 2:(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 2;
							break;
						
						case 3:(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 3;
							break;
						
						case 4:(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = 4;
							break;
						
						default:
							ps_error("编译器出错");
					}
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	
				//	node_print($$);
				
#line 1243 "myparser.cpp"
			}
		}
		break;
	case 29:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[4];
			yyinitdebug((void YYFAR**)yya, 4);
#endif
			{
#line 849 ".\\myparser.y"
						//	对应的stmt语法树结点类型为kind_stmt,nodekind_kind为20,有一个孩子结点:kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->child[0] = yyattribute(2 - 3);
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_stmt;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 20;
					(*(YYSTYPE YYFAR*)yyvalptr)->stmt_type = yyattribute(2 - 3)->stmt_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(2 - 3)->node_value;
				//	node_print($$);
				
#line 1264 "myparser.cpp"
			}
		}
		break;
	case 30:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 861 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为1,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),1);
				//	node_print($$);
				
#line 1281 "myparser.cpp"
			}
		}
		break;
	case 31:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 867 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为2,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),2);
				//	node_print($$);
				
#line 1298 "myparser.cpp"
			}
		}
		break;
	case 32:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 873 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为3,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),3);
				//	node_print($$);
				
#line 1315 "myparser.cpp"
			}
		}
		break;
	case 33:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 879 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为4,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),4);
				//	node_print($$);
				
#line 1332 "myparser.cpp"
			}
		}
		break;
	case 34:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 885 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为5,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),5);
				//	node_print($$);
				
#line 1349 "myparser.cpp"
			}
		}
		break;
	case 35:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[6];
			yyinitdebug((void YYFAR**)yya, 6);
#endif
			{
#line 891 ".\\myparser.y"
								//	对应的rela_stmt语法树结点类型为kind_rela_stmt,nodekind_kind为6,有两个孩子结点:kind_stmt,kind_stmt
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					rela_stmt_operation((*(YYSTYPE YYFAR*)yyvalptr),yyattribute(2 - 5),yyattribute(4 - 5),6);
				//	node_print($$);
				
#line 1366 "myparser.cpp"
			}
		}
		break;
	case 36:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 899 ".\\myparser.y"
						//	对应的type语法树结点类型为kind_type,nodekind_kind为1,无孩子结点
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
				//	node_print($$);
				
#line 1384 "myparser.cpp"
			}
		}
		break;
	case 37:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 906 ".\\myparser.y"
						//	对应的type语法树结点类型为kind_type,nodekind_kind为2,无孩子结点
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 2;
				//	node_print($$);
				
#line 1402 "myparser.cpp"
			}
		}
		break;
	case 38:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 913 ".\\myparser.y"
						//	对应的type语法树结点类型为kind_type,nodekind_kind为3,无孩子结点
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 3;
				//	node_print($$);
				
#line 1420 "myparser.cpp"
			}
		}
		break;
	case 39:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 920 ".\\myparser.y"
						//	对应的type语法树结点类型为kind_type,nodekind_kind为4,无孩子结点
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_type;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 4;
				//	node_print($$);
				
#line 1438 "myparser.cpp"
			}
		}
		break;
	case 40:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 929 ".\\myparser.y"
						//	对应的const语法树结点类型为kind_const,nodekind_kind为1,有一个孩子结点:kind_const_value		
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					yyattribute(1 - 1)->nodekind_kind = 1;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_const;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 1;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				
#line 1461 "myparser.cpp"
			}
		}
		break;
	case 41:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 941 ".\\myparser.y"
						//	对应的const语法树结点类型为kind_const,nodekind_kind为2,有一个孩子结点:kind_const_value
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					yyattribute(1 - 1)->nodekind_kind = 2;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_const;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 2;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				
#line 1484 "myparser.cpp"
			}
		}
		break;
	case 42:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 953 ".\\myparser.y"
						//	对应的const语法树结点类型为kind_const,nodekind_kind为3,有一个孩子结点:kind_const_value
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					yyattribute(1 - 1)->nodekind_kind = 3;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_const;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 3;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				
#line 1507 "myparser.cpp"
			}
		}
		break;
	case 43:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 965 ".\\myparser.y"
						//	对应的const语法树结点类型为kind_const,nodekind_kind为4,有一个孩子结点:kind_const_value
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					yyattribute(1 - 1)->nodekind_kind = 4;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_const;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 4;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				
#line 1530 "myparser.cpp"
			}
		}
		break;
	case 44:
		{
#ifdef YYDEBUG
			YYSTYPE YYFAR* yya[2];
			yyinitdebug((void YYFAR**)yya, 2);
#endif
			{
#line 977 ".\\myparser.y"
						//	对应的const语法树结点类型为kind_const,nodekind_kind为5,有一个孩子结点:kind_const_value
					yyattribute(1 - 1)->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					yyattribute(1 - 1)->nodekind_kind = 5;
					(*(YYSTYPE YYFAR*)yyvalptr) = new_TreeNode();
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind = kind_const;
					(*(YYSTYPE YYFAR*)yyvalptr)->nodekind_kind = 5;
					(*(YYSTYPE YYFAR*)yyvalptr)->node_value = yyattribute(1 - 1)->node_value;	//	该值由lex返回
				//	node_print($1);
				//	node_print($$);
				
#line 1553 "myparser.cpp"
			}
		}
		break;
	default:
		yyassert(0);
		break;
	}
}

void YYPARSERNAME::yytables()
{
	yyattribute_size = sizeof(YYSTYPE);
	yysstack_size = YYSTACK_SIZE;
	yystack_max = YYSTACK_MAX;

#ifdef YYDEBUG
	static const yysymbol_t YYNEARFAR YYBASED_CODE symbol[] = {
		{ "$end", 0 },
		{ "error", 256 },
		{ "VOID", 257 },
		{ "MAIN", 258 },
		{ "INT", 259 },
		{ "CHAR", 260 },
		{ "FLOAT", 261 },
		{ "BOOL", 262 },
		{ "IF", 263 },
		{ "ELSE", 264 },
		{ "WHILE", 265 },
		{ "FOR", 266 },
		{ "LSBRA", 267 },
		{ "RSBRA", 268 },
		{ "LLSBRA", 269 },
		{ "RLSBRA", 270 },
		{ "SEMIC", 271 },
		{ "ADD", 272 },
		{ "SUB", 273 },
		{ "MUL", 274 },
		{ "DIV", 275 },
		{ "PERC", 276 },
		{ "DADD", 277 },
		{ "DSUB", 278 },
		{ "GREAT", 279 },
		{ "LESS", 280 },
		{ "EQU", 281 },
		{ "GEQU", 282 },
		{ "LEQU", 283 },
		{ "NEQU", 284 },
		{ "NOT", 285 },
		{ "AND", 286 },
		{ "OR", 287 },
		{ "COUNTINTNUM", 288 },
		{ "COUNTFLOATNUM", 289 },
		{ "COUNTCHAR", 290 },
		{ "ID", 291 },
		{ "TRUE", 292 },
		{ "FALSE", 293 },
		{ "EVALU", 294 },
		{ "UMINUS", 295 },
		{ NULL, 0 }
	};
	yysymbol = symbol;

	static const char* const YYNEARFAR YYBASED_CODE rule[] = {
		"$accept: prog",
		"prog: VOID MAIN LLSBRA lines RLSBRA",
		"lines: lines expr",
		"lines: expr",
		"expr: type ID",
		"expr: type ID EVALU stmt",
		"expr: ID EVALU stmt",
		"expr: IF LSBRA stmt RSBRA LLSBRA lines RLSBRA",
		"expr: IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA",
		"expr: FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA",
		"expr: WHILE LSBRA stmt RSBRA LLSBRA lines RLSBRA",
		"stmt: stmt ADD ID",
		"stmt: stmt ADD const",
		"stmt: stmt SUB ID",
		"stmt: stmt SUB const",
		"stmt: stmt MUL ID",
		"stmt: stmt MUL const",
		"stmt: stmt DIV ID",
		"stmt: stmt DIV const",
		"stmt: stmt PERC ID",
		"stmt: stmt PERC const",
		"stmt: SUB stmt",
		"stmt: stmt AND rela_stmt",
		"stmt: stmt OR rela_stmt",
		"stmt: NOT stmt",
		"stmt: rela_stmt",
		"stmt: ID",
		"stmt: ID DADD",
		"stmt: ID DSUB",
		"stmt: const",
		"stmt: LSBRA stmt RSBRA",
		"rela_stmt: LSBRA stmt GREAT stmt RSBRA",
		"rela_stmt: LSBRA stmt LESS stmt RSBRA",
		"rela_stmt: LSBRA stmt EQU stmt RSBRA",
		"rela_stmt: LSBRA stmt GEQU stmt RSBRA",
		"rela_stmt: LSBRA stmt LEQU stmt RSBRA",
		"rela_stmt: LSBRA stmt NEQU stmt RSBRA",
		"type: CHAR",
		"type: BOOL",
		"type: INT",
		"type: FLOAT",
		"const: COUNTCHAR",
		"const: TRUE",
		"const: FALSE",
		"const: COUNTINTNUM",
		"const: COUNTFLOATNUM"
	};
	yyrule = rule;
#endif

	static const yyreduction_t YYNEARFAR YYBASED_CODE reduction[] = {
		{ 0, 1, -1 },
		{ 1, 5, 0 },
		{ 2, 2, 1 },
		{ 2, 1, 2 },
		{ 3, 2, 3 },
		{ 3, 4, 4 },
		{ 3, 3, 5 },
		{ 3, 7, 6 },
		{ 3, 11, 7 },
		{ 3, 11, 8 },
		{ 3, 7, 9 },
		{ 4, 3, 10 },
		{ 4, 3, 11 },
		{ 4, 3, 12 },
		{ 4, 3, 13 },
		{ 4, 3, 14 },
		{ 4, 3, 15 },
		{ 4, 3, 16 },
		{ 4, 3, 17 },
		{ 4, 3, 18 },
		{ 4, 3, 19 },
		{ 4, 2, 20 },
		{ 4, 3, 21 },
		{ 4, 3, 22 },
		{ 4, 2, 23 },
		{ 4, 1, 24 },
		{ 4, 1, 25 },
		{ 4, 2, 26 },
		{ 4, 2, 27 },
		{ 4, 1, 28 },
		{ 4, 3, 29 },
		{ 5, 5, 30 },
		{ 5, 5, 31 },
		{ 5, 5, 32 },
		{ 5, 5, 33 },
		{ 5, 5, 34 },
		{ 5, 5, 35 },
		{ 6, 1, 36 },
		{ 6, 1, 37 },
		{ 6, 1, 38 },
		{ 6, 1, 39 },
		{ 7, 1, 40 },
		{ 7, 1, 41 },
		{ 7, 1, 42 },
		{ 7, 1, 43 },
		{ 7, 1, 44 }
	};
	yyreduction = reduction;

	yytokenaction_size = 95;

	static const yytokenaction_t YYNEARFAR YYBASED_CODE tokenaction[] = {
		{ 85, YYAT_SHIFT, 45 },
		{ 85, YYAT_SHIFT, 46 },
		{ 85, YYAT_SHIFT, 47 },
		{ 85, YYAT_SHIFT, 48 },
		{ 85, YYAT_SHIFT, 49 },
		{ 29, YYAT_SHIFT, 42 },
		{ 29, YYAT_SHIFT, 43 },
		{ 85, YYAT_SHIFT, 56 },
		{ 85, YYAT_SHIFT, 57 },
		{ 85, YYAT_SHIFT, 58 },
		{ 85, YYAT_SHIFT, 59 },
		{ 85, YYAT_SHIFT, 60 },
		{ 85, YYAT_SHIFT, 61 },
		{ 101, YYAT_SHIFT, 103 },
		{ 85, YYAT_SHIFT, 50 },
		{ 85, YYAT_SHIFT, 51 },
		{ 102, YYAT_SHIFT, 5 },
		{ 102, YYAT_SHIFT, 6 },
		{ 102, YYAT_SHIFT, 7 },
		{ 102, YYAT_SHIFT, 8 },
		{ 102, YYAT_SHIFT, 9 },
		{ 100, YYAT_ERROR, 0 },
		{ 102, YYAT_SHIFT, 10 },
		{ 102, YYAT_SHIFT, 11 },
		{ 83, YYAT_SHIFT, 93 },
		{ 98, YYAT_SHIFT, 100 },
		{ 97, YYAT_SHIFT, 99 },
		{ 102, YYAT_SHIFT, 104 },
		{ 73, YYAT_SHIFT, 23 },
		{ 54, YYAT_SHIFT, 45 },
		{ 54, YYAT_SHIFT, 46 },
		{ 54, YYAT_SHIFT, 47 },
		{ 54, YYAT_SHIFT, 48 },
		{ 54, YYAT_SHIFT, 49 },
		{ 73, YYAT_SHIFT, 24 },
		{ 83, YYAT_ERROR, 0 },
		{ 83, YYAT_ERROR, 0 },
		{ 83, YYAT_ERROR, 0 },
		{ 83, YYAT_ERROR, 0 },
		{ 83, YYAT_ERROR, 0 },
		{ 83, YYAT_ERROR, 0 },
		{ 96, YYAT_SHIFT, 98 },
		{ 77, YYAT_ERROR, 0 },
		{ 54, YYAT_SHIFT, 50 },
		{ 54, YYAT_SHIFT, 51 },
		{ 77, YYAT_SHIFT, 87 },
		{ 73, YYAT_SHIFT, 25 },
		{ 94, YYAT_SHIFT, 97 },
		{ 102, YYAT_SHIFT, 12 },
		{ 73, YYAT_SHIFT, 26 },
		{ 73, YYAT_SHIFT, 27 },
		{ 73, YYAT_SHIFT, 28 },
		{ 73, YYAT_SHIFT, 29 },
		{ 73, YYAT_SHIFT, 30 },
		{ 73, YYAT_SHIFT, 31 },
		{ 37, YYAT_SHIFT, 45 },
		{ 37, YYAT_SHIFT, 46 },
		{ 37, YYAT_SHIFT, 47 },
		{ 37, YYAT_SHIFT, 48 },
		{ 37, YYAT_SHIFT, 49 },
		{ 49, YYAT_ERROR, 0 },
		{ 86, YYAT_SHIFT, 95 },
		{ 84, YYAT_SHIFT, 94 },
		{ 82, YYAT_SHIFT, 92 },
		{ 81, YYAT_SHIFT, 91 },
		{ 80, YYAT_SHIFT, 90 },
		{ 49, YYAT_ERROR, 0 },
		{ 79, YYAT_SHIFT, 89 },
		{ 78, YYAT_SHIFT, 88 },
		{ 37, YYAT_SHIFT, 50 },
		{ 37, YYAT_SHIFT, 51 },
		{ 52, YYAT_SHIFT, 76 },
		{ 51, YYAT_SHIFT, 73 },
		{ 48, YYAT_SHIFT, 69 },
		{ 47, YYAT_SHIFT, 67 },
		{ 46, YYAT_SHIFT, 65 },
		{ 45, YYAT_SHIFT, 63 },
		{ 44, YYAT_SHIFT, 62 },
		{ 49, YYAT_ERROR, 0 },
		{ 39, YYAT_SHIFT, 55 },
		{ 36, YYAT_SHIFT, 53 },
		{ 35, YYAT_SHIFT, 52 },
		{ 32, YYAT_SHIFT, 44 },
		{ 22, YYAT_SHIFT, 38 },
		{ 49, YYAT_SHIFT, 71 },
		{ 15, YYAT_SHIFT, 22 },
		{ 13, YYAT_SHIFT, 20 },
		{ 12, YYAT_SHIFT, 19 },
		{ 11, YYAT_SHIFT, 18 },
		{ 10, YYAT_SHIFT, 17 },
		{ 9, YYAT_SHIFT, 16 },
		{ 3, YYAT_SHIFT, 4 },
		{ 2, YYAT_ACCEPT, 0 },
		{ 1, YYAT_SHIFT, 3 },
		{ 0, YYAT_SHIFT, 1 }
	};
	yytokenaction = tokenaction;

	static const yystateaction_t YYNEARFAR YYBASED_CODE stateaction[] = {
		{ -163, 1, YYAT_ERROR, 0 },
		{ -165, 1, YYAT_ERROR, 0 },
		{ 92, 1, YYAT_ERROR, 0 },
		{ -178, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ 0, 0, YYAT_REDUCE, 39 },
		{ 0, 0, YYAT_REDUCE, 37 },
		{ 0, 0, YYAT_REDUCE, 40 },
		{ 0, 0, YYAT_REDUCE, 38 },
		{ -177, 1, YYAT_ERROR, 0 },
		{ -178, 1, YYAT_ERROR, 0 },
		{ -179, 1, YYAT_ERROR, 0 },
		{ -207, 1, YYAT_ERROR, 0 },
		{ -184, 1, YYAT_DEFAULT, 102 },
		{ 0, 0, YYAT_REDUCE, 3 },
		{ -206, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_REDUCE, 1 },
		{ 0, 0, YYAT_REDUCE, 2 },
		{ -211, 1, YYAT_REDUCE, 4 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_REDUCE, 44 },
		{ 0, 0, YYAT_REDUCE, 45 },
		{ 0, 0, YYAT_REDUCE, 41 },
		{ -272, 1, YYAT_REDUCE, 26 },
		{ 0, 0, YYAT_REDUCE, 42 },
		{ 0, 0, YYAT_REDUCE, 43 },
		{ -186, 1, YYAT_DEFAULT, 83 },
		{ 0, 0, YYAT_REDUCE, 29 },
		{ 0, 0, YYAT_REDUCE, 25 },
		{ -187, 1, YYAT_DEFAULT, 83 },
		{ -191, 1, YYAT_ERROR, 0 },
		{ -217, 1, YYAT_REDUCE, 6 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ -189, 1, YYAT_DEFAULT, 85 },
		{ 0, 0, YYAT_REDUCE, 21 },
		{ 0, 0, YYAT_REDUCE, 24 },
		{ 0, 0, YYAT_REDUCE, 27 },
		{ 0, 0, YYAT_REDUCE, 28 },
		{ -192, 1, YYAT_ERROR, 0 },
		{ -215, 1, YYAT_DEFAULT, 49 },
		{ -216, 1, YYAT_DEFAULT, 49 },
		{ -217, 1, YYAT_DEFAULT, 49 },
		{ -218, 1, YYAT_DEFAULT, 49 },
		{ -207, 1, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 51 },
		{ -195, 1, YYAT_ERROR, 0 },
		{ -198, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ -243, 1, YYAT_REDUCE, 5 },
		{ 0, 0, YYAT_REDUCE, 30 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 73 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ 0, 0, YYAT_REDUCE, 11 },
		{ 0, 0, YYAT_REDUCE, 12 },
		{ 0, 0, YYAT_REDUCE, 13 },
		{ 0, 0, YYAT_REDUCE, 14 },
		{ 0, 0, YYAT_REDUCE, 15 },
		{ 0, 0, YYAT_REDUCE, 16 },
		{ 0, 0, YYAT_REDUCE, 17 },
		{ 0, 0, YYAT_REDUCE, 18 },
		{ 0, 0, YYAT_REDUCE, 19 },
		{ 0, 0, YYAT_REDUCE, 20 },
		{ -239, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_REDUCE, 22 },
		{ 0, 0, YYAT_REDUCE, 23 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ -226, 1, YYAT_DEFAULT, 83 },
		{ -200, 1, YYAT_DEFAULT, 83 },
		{ -201, 1, YYAT_DEFAULT, 83 },
		{ -203, 1, YYAT_DEFAULT, 83 },
		{ -204, 1, YYAT_DEFAULT, 83 },
		{ -205, 1, YYAT_DEFAULT, 83 },
		{ -244, 1, YYAT_DEFAULT, 85 },
		{ -208, 1, YYAT_DEFAULT, 102 },
		{ -272, 1, YYAT_ERROR, 0 },
		{ -209, 1, YYAT_DEFAULT, 102 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ 0, 0, YYAT_REDUCE, 31 },
		{ 0, 0, YYAT_REDUCE, 32 },
		{ 0, 0, YYAT_REDUCE, 33 },
		{ 0, 0, YYAT_REDUCE, 34 },
		{ 0, 0, YYAT_REDUCE, 35 },
		{ 0, 0, YYAT_REDUCE, 36 },
		{ -217, 1, YYAT_REDUCE, 7 },
		{ 0, 0, YYAT_REDUCE, 10 },
		{ -227, 1, YYAT_ERROR, 0 },
		{ -243, 1, YYAT_ERROR, 0 },
		{ -244, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_DEFAULT, 100 },
		{ -249, 1, YYAT_DEFAULT, 102 },
		{ -257, 1, YYAT_DEFAULT, 102 },
		{ -243, 1, YYAT_ERROR, 0 },
		{ 0, 0, YYAT_REDUCE, 8 },
		{ 0, 0, YYAT_REDUCE, 9 }
	};
	yystateaction = stateaction;

	yynontermgoto_size = 35;

	static const yynontermgoto_t YYNEARFAR YYBASED_CODE nontermgoto[] = {
		{ 73, 85 },
		{ 73, 34 },
		{ 102, 21 },
		{ 73, 33 },
		{ 99, 101 },
		{ 102, 15 },
		{ 100, 102 },
		{ 100, 14 },
		{ 87, 96 },
		{ 76, 86 },
		{ 62, 84 },
		{ 61, 83 },
		{ 60, 82 },
		{ 59, 81 },
		{ 58, 80 },
		{ 57, 79 },
		{ 56, 78 },
		{ 53, 77 },
		{ 51, 75 },
		{ 50, 74 },
		{ 49, 72 },
		{ 48, 70 },
		{ 47, 68 },
		{ 46, 66 },
		{ 45, 64 },
		{ 38, 54 },
		{ 25, 41 },
		{ 24, 40 },
		{ 23, 39 },
		{ 19, 37 },
		{ 18, 36 },
		{ 17, 35 },
		{ 16, 32 },
		{ 4, 13 },
		{ 0, 2 }
	};
	yynontermgoto = nontermgoto;

	static const yystategoto_t YYNEARFAR YYBASED_CODE stategoto[] = {
		{ 33, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 31, 100 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, 102 },
		{ 0, -1 },
		{ 0, -1 },
		{ 28, 73 },
		{ 27, 73 },
		{ 27, 102 },
		{ 25, 73 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 24, 73 },
		{ 23, 73 },
		{ 22, 73 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 21, 73 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 17, -1 },
		{ 16, -1 },
		{ 15, -1 },
		{ 14, -1 },
		{ 13, -1 },
		{ 14, -1 },
		{ 13, -1 },
		{ 0, -1 },
		{ 13, 73 },
		{ 0, -1 },
		{ 0, -1 },
		{ 12, 73 },
		{ 11, 73 },
		{ 10, 73 },
		{ 9, 73 },
		{ 8, 73 },
		{ 7, 73 },
		{ 8, 100 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ -4, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 7, 100 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, 102 },
		{ 0, -1 },
		{ 0, 102 },
		{ 5, 102 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 0, -1 },
		{ 2, 100 },
		{ 4, 102 },
		{ 0, 102 },
		{ -1, -1 },
		{ 0, -1 },
		{ 0, -1 }
	};
	yystategoto = stategoto;

	yydestructorptr = NULL;

	yytokendestptr = NULL;
	yytokendest_size = 0;

	yytokendestbaseptr = NULL;
	yytokendestbase_size = 0;
}
#line 990 ".\\myparser.y"


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
	outfile.open("output.txt",ios::app); //1.ios::app     ----写入的数据将被追加在文件的末尾 
    
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


