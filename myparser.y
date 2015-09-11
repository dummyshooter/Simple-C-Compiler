%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.
���ߣ�NKU Jackshen  
Date: 2008��12��14��
****************************************************************************/
#include <stack>
#include "mylexer.h"
#include<iostream>
#include<fstream>
#include <string>

#define MAXCHILDREN 4 //ÿһ���������ӵ�еĺ��ӽ���������
#define IDNUMMAX  100  //�ɴ洢�����������Ŀ
#define LETNUMMAX 999  //�洢�������ֵ������С
#define max(a,b) ((a)>=(b)?(a):(b)) //ȡ�����еĴ�ֵ
#define  vari_db "TEMP_DB_"    //�ֽ�����ʱ����ǰ׺
#define  vari_dd "TEMP_DD_"    //˫������ʱ����ǰ׺
#define    lab   "LABEL_"       //���ǰ׺


//������ű�Ԫ�ص����ݽṹ	
struct entry
{
	char *lexptr;		//��ָ��ָ��������ֵĴ洢λ��
	
	int  type;			//�ñ�������÷��ŵ�����(char��,bool��,int�ͻ�float��)(1:char,2:bool,3:int,4:float)
	
	float   token;		//�ı�������÷��ŵ�ֵ(��Ϊfloat�ͣ�����type��������)
};

entry symtable[IDNUMMAX];   //������ű�,�ⲿ���ñ���(ȫ�ֱ���)
	
char  lexemes[LETNUMMAX];   //����������ֵ�ʵ�ʴ洢����

int lastentry;       //���ű���������õ�λ��

stack <float> idstack;        //�ö�ջ�����洢ID��Ӧ���ű��е��±�

stack <int> db_tempstack;     //�洢�ֽ�����ʱ����

stack <int> dd_tempstack;     //�洢˫������ʱ����

ofstream outfile("output.txt"); //д�ļ�


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
	
	int lineno;		    //����ĳЩ����Ӧ�û�������к�		
	
	NodeKind nodekind;  //�������,ȡֵ��ΧΪNodeKind�е�����
	
	int nodekind_kind;	//����һ��NodeKind������������ı��(��nodekindȡkind_type_specifierʱ,
                    	//�������nodekind_kindΪ1ʱ����ʾ��Ӧ�Ľ��Ϊchar��,nodekind_kindΪ2ʱ,��ʾ��Ӧ�Ľڵ�Ϊbool��.....)
	
	int stmt_type;		//��nodekindΪkind_stmtʱ,���ʽȡֵ���ñ�����ֵ��Ч.����stmt���ʽ������
	                    //(stmt_typeΪ1ʱ����ʾ��Ӧ��stmt���ʽΪchar��;Ϊ2ʱ����ʾ��Ϊbool��;Ϊ3ʱ����Ϊint��;Ϊ4ʱ����ʾ��Ϊfloat��)
	
	float node_value;	//�����ΪҶ���,����Ϊkind_const_valueʱ,�������泣����ֵ.
	                    //��nodekind_kindΪ1ʱ,��node_value��floatǿ��ת��Ϊint��,Ȼ��ȡ��Ӧ��char���ַ�;
	                    //��nodekind_kindΪ2ʱ,��node_value��floatǿ��ת��Ϊint��,��ת��Ϊbool��;
	                    //��nodekind_kindΪ3ʱ,��node_value��floatǿ��ת��Ϊint��
	                    //�����Ϊkind_stmtʱ,����������ʽ��ֵ,��ֵ�ɽ��stmt_typeת��Ϊ���ʽ����Ӧ����ʵֵ
	                    //�����λkind_IDʱ,��������ID��Ӧ���ű��е��±�	 		
}	TreeNode;
	
	
int whole_Currnode_number = 1;	//����Ϊ�������Ľ���Ÿ�ֵ
	
int ps_error_count = 0 ;    //��������������


TreeNode * root = NULL;     //�������յ��﷨���ĸ����	
	
TreeNode * new_treeNode;    //��������һ���µ��﷨�����
	

	
void warning(char*m);		//�ú���������ӡ������Ϣ

void ps_error(char*m);		//�ú���������ӡ������Ϣ

TreeNode * new_TreeNode();	//�ú�������һ�������,�����ؽ��ָ��,ͬʱ��ɽ�����ݳ�ʼ��



int label = 0;//����������б�ŵı��
int db_max = 0; //���������ֽ��ͱ�����ֵ���ı��
int dd_max = 0; //

//�����������ʽ��ֵ
void stmt_operation(TreeNode*$$,TreeNode*$1,TreeNode*$3,char a);

//�����ϵ���ʽ��ֵ
void rela_stmt_operation(TreeNode*$$,TreeNode*$2,TreeNode*$4,int a);

//�����ʽ��ֵ�ɸ�����ת��Ϊ����ʵ����
void change_to_original_asm(float a,int b);	//ת��ɻ�ೣ��



void single_node_stmt_print(TreeNode * m,int serial_number);//�ú���������ӡ��������Ӧ�Ļ����룬serial_number������������������ʱ����

void single_node_rela_print(TreeNode * m,int serial_number);

void single_node_other_print(TreeNode*m);//�ú��������ӡ�����ڵ�(prog,lines,expr)��Ӧ�Ļ�����


void assembly_language_print(); //���Դ�����Ӧ�Ļ�����

	

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
%token COUNTINTNUM //'�������ֳ���'
%token COUNTFLOATNUM //'�������ֳ���'
%token COUNTCHAR //'char�ͳ���'
%token ID    //'��ʾ��'
%token TRUE  //true
%token FALSE //false
%token EVALU //��ֵ

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

prog		:	VOID  MAIN LLSBRA lines RLSBRA	//�����﷨���ĸ����	
				{								//�ø��������Ϊkind_prog,nodekind_kindΪ1,��һ�����ӽ��:kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $4;
					$$->nodekind = kind_prog;
					$$->nodekind_kind = 1;
					root = $$ ;
				
					outfile<<endl;
					
					outfile<<"Դ�����Ӧ�Ļ���������:"<<endl;
					
					outfile<<endl;	
					
					assembly_language_print();	
				} 
			;

lines		:	lines expr						//����ν��								
				{								//�ó���ν������Ϊkind_lines,nodekind_kindΪ1,���������ӽ��:kind_lines,kind_expr
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $2;
					$$->nodekind = kind_lines;
					$$->nodekind_kind = 1;
					$1->sibling = $2;			//lines�����ֵܽ��Ϊexpr
					
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

expr		:	type  ID  //SEMIC	//  ��������					
				{								//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ1,���������ӽ��:kind_type,kind_ID
					$2->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $2;
					$$->nodekind = kind_expr;
					$2->nodekind = kind_ID;
					$$->nodekind_kind = 1;
					$1->sibling = $2;			//type�����ֵܽ��ΪID
					
					if(symtable[int($2->node_value)].type>0)//���ID�Ƿ��Ѿ�����,$2->node_entry->type����0������ID������ȷ��,����ID�Ѿ�����
					{
						ps_error(("�ض���"));//�������﷨����������������
					}
					
					symtable[int($2->node_value)].type = $1->nodekind_kind; //��type��Ӧ�����͸�ֵ��ID��Ӧ�ı�������:1��ʾchar��,2��ʾbool��,3��ʾint��,4��ʾfloat��
				//	node_print($2);
				//	node_print($$);
				}			
			|	type  ID EVALU stmt	 //SEMIC	//  ����ֵ�ı�������	
				{						//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ2,���������ӽ��:kind_type,kind_ID,kind_stmt
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
					if(symtable[int($2->node_value)].type>0)//���ID�Ƿ��Ѿ�����,$2->node_entry->type����0������ID������ȷ��,����ID�Ѿ�����
					{
						ps_error("�ض���");//�������﷨����������������
					}
					symtable[int($2->node_value)].type = $1->nodekind_kind; //��type��Ӧ�����͸�ֵ��ID��Ӧ�ı�������:1��ʾchar��,2��ʾbool��,3��ʾint��,4��ʾfloat��
					
				
				
					//���type�������Ƿ��stmt��������ƥ��,�����Ͳ���ƥ��ʱ,�����Խ���ǿ������ת��
			        //��ǿ��ת��������Ϣ��ʧ(float��ת��Ϊint��)ʱ����ӡ������Ϣ
					//��ǿ��ת�����´���(int��ֵ���ڵ���128ʱת����char�ͱ���)ʱ����ӡ������Ϣ�����﷨����������������(int��ֵ����127ʱת����char�ͱ���'0'��NULL)
					//��ǿ��ת�����������ű��������
					if((symtable[int($2->node_value)].type)!=($4->stmt_type))
					{
						if($4->stmt_type == 4) //��stmtΪfloat��ʱ��һ�������Ϣ��ʧ�����ܲ�������
						{
							if((symtable[int($2->node_value)].type) ==1)	//��IDΪchar��ʱ
							{
								if($4->node_value >= 128)	//int��ֵ���ڵ���128ʱת����char�ͱ���,��������	
								{
									ps_error("����ת�����´���");
									symtable[int($2->node_value)].token = 0;
								}
								else
								{
									warning("����ת��������Ϣ��ʧ");
									symtable[int($2->node_value)].token = $4->node_value;
								}
							}
							else
							{
								warning("����ת��������Ϣ��ʧ");
								symtable[int($2->node_value)].token = $4->node_value;
							}
						}
						else
						{
							if($4->stmt_type == 3)	//��stmtΪint��ʱ,���ܲ�������
							{
								if($4->node_value >= 128)	//int��ֵ���ڵ���128ʱת����char�ͱ���,��������	
								{
									ps_error("����ת�����´���");
									symtable[int($2->node_value)].token = 0;
								}
								else
								{
									symtable[int($2->node_value)].token = $4->node_value;  //������ֵ
								}	
							}
							else	  //������ֵ
							{
								symtable[int($2->node_value)].token = $4->node_value;  
							}
						}
					}
					else
					{
						symtable[int($2->node_value)].token = $4->node_value;  //������ֵ
					}
				//	node_print($2);
				//	node_print($$);
				}									 
			|	ID	  EVALU    stmt	 //SEMIC	//  ��ֵ���ʽ
				{						//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ3,���������ӽ��:kind_ID,kind_stmt
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->child[1] = $3;
					$$->nodekind = kind_expr;
					$1->nodekind = kind_ID;
				
					$$->nodekind_kind = 3;
					$1->sibling = $3;
					
					if(symtable[int($1->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$2->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($1->node_value)].type = $3->stmt_type;	//��ʱ,stmt����ȫ��ֵ��ID
						symtable[int($1->node_value)].token = $3->node_value;
					//	node_print($1);
					//	node_print($$);
						return;
					}
					
					//���ID�������Ƿ��stmt��������ƥ��,�����Ͳ���ƥ��ʱ,�����Խ���ǿ������ת��
					//��ǿ��ת��������Ϣ��ʧ(float��ת��Ϊint��)ʱ����ӡ������Ϣ
					//��ǿ��ת�����´���(int��ֵ���ڵ���128ʱת����char�ͱ���)ʱ����ӡ������Ϣ�����﷨����������������(int��ֵ����127ʱת����char�ͱ���'0'��NULL)
					//��ǿ��ת�����������ű��������
					if((symtable[int($1->node_value)].type)!=($3->stmt_type))
					{
						if($3->stmt_type == 4) //��stmtΪfloat��ʱ��һ�������Ϣ��ʧ�����ܲ�������
						{
							if((symtable[int($1->node_value)].type) ==1)	//��IDΪchar��ʱ
							{
								if($3->node_value >= 128)	//int��ֵ���ڵ���128ʱת����char�ͱ���,��������	
								{
									ps_error("����ת�����´���");
									symtable[int($1->node_value)].token = 0;
								}
							}
							else
							{
								warning("����ת��������Ϣ��ʧ");
								symtable[int($1->node_value)].token = $3->node_value;
							}
						}
						else
						{
							if($3->stmt_type == 3)	//��stmtΪint��ʱ,���ܲ�������
							{
								if($3->node_value >= 128)	//int��ֵ���ڵ���128ʱת����char�ͱ���,��������	
								{
									ps_error("����ת�����´���");
									symtable[int($1->node_value)].token = 0;
								}
								else
								{
									symtable[int($1->node_value)].token = $3->node_value;  //������ֵ
								}	
							}
							else	  //������ֵ
							{
								symtable[int($1->node_value)].token = $3->node_value;  
							}
						}
					}
					else
					{
						symtable[int($1->node_value)].token = $3->node_value;  //������ֵ
					}
				//	node_print($1);
				//	node_print($$);
				}						
			|	IF LSBRA stmt RSBRA  LLSBRA lines RLSBRA  	//  �������ʽ if(stmt) { lines },���е�stmtΪint��,char�ͻ�bool��
				{					//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ4,���������ӽ��:kind_stmt,kind_lines
					$$ = new_TreeNode();
					$$->child[0] = $3;
					$$->child[1] = $6;
					$$->nodekind = kind_expr;
				
					$$->nodekind_kind = 4;
					$3->sibling = $6;
					if($3->stmt_type == 4)
					{
						ps_error("IF ����б��ʽ��ֵ����Ϊfloat��"); //��stmtΪfloat��ʱ����ӡ������Ϣ
					}
				//	node_print($$);
				}						 
			|	IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA	  //  �������ʽ if(stmt) then { lines } else { lines },���е�stmtΪint��,char�ͻ�bool��
				{					//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ5,���������ӽ��:kind_stmt,kind_lines,kind_lines
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
						ps_error("IF ����б��ʽ��ֵ����Ϊfloat��"); //��stmtΪfloat��ʱ����ӡ������Ϣ
					}
				//	node_print($$);
				}						
			|	FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA	  //  forѭ�� for(expr;stmt;expr) { lines },���е�stmtΪint��,char�ͻ�bool��
				{					   //  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ6,���ĸ����ӽ��:kind_expr,kind_stmt,kind_expr,kind_lines
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
						ps_error("IF-ELES ����б��ʽ��ֵ����Ϊfloat��"); //��stmtΪfloat��ʱ����ӡ������Ϣ
					}
				//	node_print($$);
				}						
			|	WHILE LSBRA stmt RSBRA LLSBRA lines RLSBRA	  //  while ѭ�� while(stmt) { lines },���е�stmtΪint��,char�ͻ�bool�� 
				{					//  ��Ӧ��expr�﷨���������Ϊkind_expr,nodekind_kindΪ7,���������ӽ��:kind_stmt,kind_lines	
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
						ps_error("WHILE ����б��ʽ��ֵ����Ϊfloat��"); //��stmtΪfloat��ʱ����ӡ������Ϣ
					}
				//	node_print($$);
				}						
			;
//  ���ʽ(int,float,char,bool)
stmt		:   stmt ADD ID				//  stmt + ID
				{						//  ��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ1,���������ӽ��:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					
					$$->nodekind = kind_stmt;
					
					$$->nodekind_kind = 1;
					if(symtable[int($3->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($3->node_value)].type = $1->stmt_type;	//��ʱ,stmt�����ͽ���ֵ��ID
						symtable[int($3->node_value)].token = 0;			//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
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
			|	stmt ADD const			//  stmt + ����
				{						//	��Ӧ��stmt�﷨���ڵ�����Ϊkind-stmt,nodekind_kindΪ2,���������ӽ��:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 2;
					stmt_operation($$,$1,$3,'+');
				//	node_print($$);
				}						
			|	stmt SUB ID				//  stmt - ID
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ3,���������ӽ��:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 3;
					if(symtable[int($3->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($3->node_value)].type = $1->stmt_type;	//��ʱ,stmt�����ͽ���ֵ��ID
						symtable[int($3->node_value)].token = 0;			//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
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
			|	stmt SUB const			//  stmt - ����
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ4,���������ӽ��:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 4;
					stmt_operation($$,$1,$3,'-');
				//	node_print($$);
				}						
			|   stmt MUL ID				//  stmt * ID
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ5,���������ӽ��:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 5;
					if(symtable[int($3->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($3->node_value)].type = $1->stmt_type;			//��ʱ,stmt�����ͽ���ֵ��ID
						symtable[int($3->node_value)].token = 0;					//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
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
			|	stmt MUL const			//  stmt * ����
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ6,���������ӽ��:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 6;
					stmt_operation($$,$1,$3,'*');
				//	node_print($$);
				}						
			|   stmt DIV ID				//  stmt / ID
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ7,���������ӽ��:kind_stmt,kind_ID
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 7;
					if(symtable[int($3->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($3->node_value)].type = $1->stmt_type;			//��ʱ,stmt�����ͽ���ֵ��ID
						symtable[int($3->node_value)].token = 0;					//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
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
			|	stmt DIV const			//  stmt / ����
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ8,���������ӽ��:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 8;
					stmt_operation($$,$1,$3,'/');
				//	node_print($$);
				}
			|	stmt PERC ID			//  stmt % ID,Ҫ��stmt��ID������Ϊfloat��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ9,���������ӽ��:kind_stmt,kind_const
					$3->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 9;
					if(symtable[int($3->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($3->node_value)].type = $1->stmt_type;			//��ʱ,stmt�����ͽ���ֵ��ID
						symtable[int($3->node_value)].token = 0;					//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
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
			|	stmt PERC const			//  stmt % ����,Ҫ��stmt��ID������Ϊfloat��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ10,���������ӽ��:kind_stmt,kind_const
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 10;
					stmt_operation($$,$1,$3,'%');
				//	node_print($$);
				}						
			|	SUB stmt %prec UMINUS	//  - stmt
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ11,��һ�����ӽ��:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 11;
					$$->stmt_type = $2->stmt_type;
					$$->node_value = - $2->node_value;
				//	node_print($$);
				}						
			|	stmt AND rela_stmt  	//  stmt && rela_stmt,stmtΪchar,bool,int��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ12,���������ӽ��:kind_stmt,kind_rela_stmt
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 12;
					stmt_operation($$,$1,$3,'&');
				//	node_print($$);
				}						
			|	stmt OR  rela_stmt   	//  stmt || rela_stmt,stmtΪchar,bool,int��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ13,���������ӽ��:kind_stmt,kind_rela_stmt
					$$ = new_TreeNode();
				//	$$->child[0]=$1;
				//	$$->child[1]=$3;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 13;
					stmt_operation($$,$1,$3,'|');
				//	node_print($$);
				}						
			|	NOT	 stmt               //  ! stmt,stmtΪchar,bool,int��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ14,��һ�����ӽ��:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 14;
					$$->stmt_type = 2;
					if($2->stmt_type == 4)	//��stmtΪfloat��ʱ,����
					{
						ps_error("�߼����ʽ�Ĳ���Ϊfloat��");
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
			|   rela_stmt				//  rela_stmt ��ϵ���ʽ
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ15,��һ�����ӽ��:kind_rela_stmt
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 15;
					$$->stmt_type = 2;
					$$->node_value = $1->node_value;
				//	node_print($$);
				}						
			|	ID						//  ����
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ16,��һ�����ӽ��:kind_ID
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 16;
					if(symtable[int($1->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($1->node_value)].type = 1;	//��ʱ,��ID������ǿ�Ƹ�ֵΪchar��
						symtable[int($1->node_value)].token = 0;		//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
					}
					$$->stmt_type = symtable[int($1->node_value)].type;
					$$->node_value = symtable[int($1->node_value)].token;
				//	node_print($1);
				//	node_print($$);
				}
			|	ID DADD					//  ��������:ID++,Ҫ��ñ���������int��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ17,��һ�����ӽ��:kind_ID	
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					TreeNode *test = $$;
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 17;
					if(symtable[int($1->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($1->node_value)].type = 1;			//��ʱ,��ID������ǿ�Ƹ�ֵΪchar��
						symtable[int($1->node_value)].token = 0;					//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
					}
					else
					{
						if(symtable[int($1->node_value)].type != 4)
						{
							ps_error("����ӦΪint��");
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
			|	ID DSUB					//  ��������:ID--,Ҫ��ñ���������int��
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ18,��һ�����ӽ��:kind_ID
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$$ = new_TreeNode();
					$$->child[0] = $1;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 18;
					if(symtable[int($1->node_value)].type<=0)//���ID�Ƿ��Ѿ�����,$3->node_entry->typeС�ڵ���0������ID����δȷ��,����IDδ����
					{
						ps_error("δ����");//�������﷨����������������
						symtable[int($1->node_value)].type = 1;			//��ʱ,��ID������ǿ�Ƹ�ֵΪchar��
						symtable[int($1->node_value)].token = 0;					//��Ϊ�����ID��ֵ��Ϊ0,�Ա��﷨��������������
					}
					else
					{
						if(symtable[int($1->node_value)].type != 4)
						{
							ps_error("����ӦΪint��");
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
			|	const					//	����
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ19,��һ�����ӽ��:kind_const
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
							ps_error("����������");
					}
					$$->node_value = $1->node_value;	
				//	node_print($$);
				}						
			|	LSBRA stmt RSBRA		//  ( stmt )
				{						//	��Ӧ��stmt�﷨���������Ϊkind_stmt,nodekind_kindΪ20,��һ�����ӽ��:kind_stmt
					$$ = new_TreeNode();
					$$->child[0] = $2;
					$$->nodekind = kind_stmt;
					$$->nodekind_kind = 20;
					$$->stmt_type = $2->stmt_type;
					$$->node_value = $2->node_value;
				//	node_print($$);
				}						
			;
//��ϵ���ʽ(�Ƚ�ͬ����ֵ��Ĵ�С,����bool�ͱ���:true > false,true >= false)
rela_stmt   :	LSBRA stmt   GREAT stmt RSBRA	//  �Ƚϴ�С	>
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ1,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,1);
				//	node_print($$);
				}								
			|	LSBRA stmt   LESS  stmt RSBRA	//  �Ƚϴ�С	<
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ2,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,2);
				//	node_print($$);
				}								
			|	LSBRA stmt   EQU   stmt	RSBRA	//  �Ƚϴ�С	==	
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ3,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,3);
				//	node_print($$);
				}								
			|	LSBRA stmt   GEQU  stmt	RSBRA	//  �Ƚϴ�С	>=
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ4,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,4);
				//	node_print($$);
				}								
			|	LSBRA stmt   LEQU  stmt	RSBRA	//  �Ƚϴ�С	<=
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ5,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,5);
				//	node_print($$);
				}									
			|	LSBRA stmt   NEQU  stmt	RSBRA	//  �Ƚϴ�С	!=
				{								//	��Ӧ��rela_stmt�﷨���������Ϊkind_rela_stmt,nodekind_kindΪ6,���������ӽ��:kind_stmt,kind_stmt
					$$ = new_TreeNode();
					rela_stmt_operation($$,$2,$4,6);
				//	node_print($$);
				}								
			;
//type(����)����
type		:	CHAR					//  char
				{						//	��Ӧ��type�﷨���������Ϊkind_type,nodekind_kindΪ1,�޺��ӽ��
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 1;
				//	node_print($$);
				}						
			|	BOOL					//  bool
				{						//	��Ӧ��type�﷨���������Ϊkind_type,nodekind_kindΪ2,�޺��ӽ��
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 2;
				//	node_print($$);
				}						
			|	INT						//  int
				{						//	��Ӧ��type�﷨���������Ϊkind_type,nodekind_kindΪ3,�޺��ӽ��
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 3;
				//	node_print($$);
				}						
			|	FLOAT					//  float
				{						//	��Ӧ��type�﷨���������Ϊkind_type,nodekind_kindΪ4,�޺��ӽ��
					$$ = new_TreeNode();
					$$->nodekind = kind_type;
					$$->nodekind_kind = 4;
				//	node_print($$);
				}						
			;
//const(����)����
const		:	COUNTCHAR					//  ���ַ�����
				{						//	��Ӧ��const�﷨���������Ϊkind_const,nodekind_kindΪ1,��һ�����ӽ��:kind_const_value		
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 1;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 1;
					$$->node_value = $1->node_value;	//	��ֵ��lex����
				//	node_print($1);
				//	node_print($$);
				}						
			|	TRUE					//  bool�ͳ��� true
				{						//	��Ӧ��const�﷨���������Ϊkind_const,nodekind_kindΪ2,��һ�����ӽ��:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 2;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 2;
					$$->node_value = $1->node_value;	//	��ֵ��lex����
				//	node_print($1);
				//	node_print($$);
				}						
			|	FALSE					//	bool�ͳ��� false
				{						//	��Ӧ��const�﷨���������Ϊkind_const,nodekind_kindΪ3,��һ�����ӽ��:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 3;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 3;
					$$->node_value = $1->node_value;	//	��ֵ��lex����
				//	node_print($1);
				//	node_print($$);
				}							
			|	COUNTINTNUM					//  ���ֳ���
				{						//	��Ӧ��const�﷨���������Ϊkind_const,nodekind_kindΪ4,��һ�����ӽ��:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 4;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 4;
					$$->node_value = $1->node_value;	//	��ֵ��lex����
				//	node_print($1);
				//	node_print($$);
				}						
			|	COUNTFLOATNUM					//  ���㳣��
				{						//	��Ӧ��const�﷨���������Ϊkind_const,nodekind_kindΪ5,��һ�����ӽ��:kind_const_value
					$1->Currnode_number = whole_Currnode_number;
					whole_Currnode_number++;
					$1->nodekind_kind = 5;
					$$ = new_TreeNode();
					$$->nodekind = kind_const;
					$$->nodekind_kind = 5;
					$$->node_value = $1->node_value;	//	��ֵ��lex����
				//	node_print($1);
				//	node_print($$);
				}						
			;				

%%

/////////////////////////////////////////////////////////////////////////////
// programs section

void warning(char*m)					//�ú���������ӡ������Ϣ
{
	//��ӡ������Ϣ
	cout<<m<<endl;	
}
void ps_error(char*m)					//�ú���������ӡ������Ϣ
{
	
	cout<<m<<endl;

	ps_error_count++;					//�������������1

}

TreeNode * new_TreeNode()				//�ú�������һ�������,�����ؽ��ָ��,ͬʱ��ɽ�����ݳ�ʼ��
{	
	new_treeNode = new(TreeNode) ;

	for(int i=0;i<MAXCHILDREN;i++)		//Ϊָ���亢�ӽ���ָ�븳��ֵ
	{
		new_treeNode->child[i] = NULL;
	}

	new_treeNode->sibling = NULL;		//Ϊָ�������ֵܽ���ָ�븳��ֵ	

	new_treeNode->lineno = 0;			//Ϊ����Ӧ�û�������кŸ���ֵ

	new_treeNode->Currnode_number = whole_Currnode_number;

	whole_Currnode_number++;

	new_treeNode->nodekind_kind = 0;//ΪNodeKind������������ı�Ÿ���ֵ,��ȷ�ı��Ӧ��Ϊ������

	new_treeNode->stmt_type = 0;		//Ϊ����stmt���ʽ�����͵ı�������ֵ,��ȷstmt���ʽ����ӦΪ1-4֮���������

	return new_treeNode;
}

void stmt_operation(TreeNode*$$,TreeNode*$1,TreeNode*$3,char a)				//�ú�������������ʽ��ֵ
{
	$$->child[0] = $1;

	$$->child[1] = $3;

	$1->sibling = $3;

	$$->stmt_type = (($1->stmt_type) > ($3->nodekind_kind))?($1->stmt_type):($3->nodekind_kind);//������������Ϊ����������������нϴ��

	switch (a)
	{
		case '+':$$->node_value = $1->node_value + $3->node_value;
	
			break;
	
		case '-':$$->node_value = $1->node_value - $3->node_value;
	
			break;
	
		case '*':$$->node_value = $1->node_value * $3->node_value;
	
			break;
	
		case '/':
			if($3->node_value == 0)		//������Ϊ0ʱ,����,����$1��ֱֵ�Ӹ�ֵ��$$,�Ա��﷨��������������
			{
				ps_error("�����");
	
				$$->node_value = $1->node_value;
	
				break;
			}
	
			$$->node_value = $1->node_value / $3->node_value;
	
			break;
	
		case '%':
			if(($1->stmt_type == 4) || ($3->nodekind_kind == 4))
			{
				ps_error("��������ģ����ʱ����Ϊfloat��ֵ");
			}
		
			if($3->node_value == 0)		//������Ϊ0ʱ,����,����$1��ֱֵ�Ӹ�ֵ��$$,�Ա��﷨��������������
			{
				ps_error("�����");
		
				$$->node_value = $1->node_value;
		
				break;
			}
		
			$$->node_value = int($1->node_value) % int($3->node_value);
		
			$$->stmt_type = 3 ;
		
			break;
		
		case '&':									//�߼�������&&
			if($1->stmt_type == 4)	//��stmtΪfloat��ʱ,����
			{
				ps_error("�߼����ʽ�Ĳ���Ϊfloat��");
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
		
		case '|':									//�߼�������||
			if($1->stmt_type == 4)	//��stmtΪfloat��ʱ,����
			{
				ps_error("�߼����ʽ�Ĳ���Ϊfloat��");
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
			ps_error("����������");
	}
}

void rela_stmt_operation(TreeNode*$$,TreeNode*$2,TreeNode*$4,int a)			//�ú������������ϵ���ʽ��ֵ		
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
			ps_error("����������");
	}
}
void change_to_original_asm(float a,int b)	//�ú���������Դ�����г���ת��Ϊ��������еĳ���
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				  default:ps_error("����������");
				             	
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
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
				default:ps_error("����������");
			}
			break;
		case 20 :			//stmt ---> ( stmt )";
			single_node_stmt_print(m->child[0],serial_number);
			break;
		default:ps_error("����������");		
    }
    return;
}		
		
void single_node_other_print(TreeNode*m)//��ӡ�����ڵ�(prog,lines,expr)��Ӧ�Ļ�����
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
				default:ps_error("����������");
			}
			break;
		case kind_expr:				//expr
			switch(m->nodekind_kind)
			{
				case 1 :			//expr --> type ID,���������Ѿ������ݶ�������
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
						default:ps_error("����������");
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
						default:ps_error("����������");
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
						default:ps_error("����������");	 
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
						default:ps_error("����������");	
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
						default:ps_error("����������");	 
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
						default:ps_error("����������");	 
					}
					break;
				default:ps_error("����������");
			}
			break;
		default:ps_error("����������");
	}
	return;
}			

void assembly_language_print()
{
  
	//���ű��еı�����ӵ����ݶ�
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
			default:ps_error("����������");
				exit(0);
		}
	}
	outfile<<"DATA		ENDS"<<endl;
	//���濪ʼ��������,����װ�����ݶ�
	outfile<<"CODE		SEGMENT"<<endl;
	outfile<<"		ASSUME CS:CODE,DS:DATA"<<endl;
	outfile<<"BEGIN:		MOV AX,DATA"<<endl;
	outfile<<"		MOV DS,AX"<<endl;
	//���濪ʼ������ĶεĴ���
	for(i=500;i>=1;i--)//����ʱ������Ӧ��ŵĶ�ջ���г�ʼ��
	{
		db_tempstack.push(i);//�ֽ��ͱ���
		dd_tempstack.push(i);//˫���ͱ���
	}
	single_node_other_print(root);
	outfile<<"          MOVE AX,4CH"<<endl;
	outfile<<"          INT 21H"<<endl;
	outfile<<"CODE		ENDS"<<endl;
	outfile<<"		END BEGIN"<<endl;
	outfile.close();
	outfile.open("output.asm",ios::app); //1.ios::app     ----д������ݽ���׷�����ļ���ĩβ 
    
                                        //ios::app   ����̻߳��߽��̶�һ���ļ�д��ʱ��,�����ļ�ԭ����������abc
                                        //��һ���߳�(����)������д�˸�d,�ڶ����߳�(����)д�˸�e�Ļ��������abcde  
     
    

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

