#############################################################################
#                     U N R E G I S T E R E D   C O P Y
# 
# You are on day 84 of your 30 day trial period.
# 
# This file was produced by an UNREGISTERED COPY of Parser Generator. It is
# for evaluation purposes only. If you continue to use Parser Generator 30
# days after installation then you are required to purchase a license. For
# more information see the online help or go to the Bumble-Bee Software
# homepage at:
# 
# http://www.bumblebeesoftware.com
# 
# This notice must remain present in the file. It cannot be removed.
#############################################################################

#############################################################################
# myparser.v
# YACC verbose file generated from myparser.y.
# 
# Date: 12/15/08
# Time: 08:20:05
# 
# AYACC Version: 2.06
#############################################################################


##############################################################################
# Rules
##############################################################################

    0  $accept : prog $end

    1  prog : VOID MAIN LLSBRA lines RLSBRA

    2  lines : lines expr
    3        | expr

    4  expr : type ID
    5       | type ID EVALU stmt
    6       | ID EVALU stmt
    7       | IF LSBRA stmt RSBRA LLSBRA lines RLSBRA
    8       | IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA
    9       | FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA
   10       | WHILE LSBRA stmt RSBRA LLSBRA lines RLSBRA

   11  stmt : stmt ADD ID
   12       | stmt ADD const
   13       | stmt SUB ID
   14       | stmt SUB const
   15       | stmt MUL ID
   16       | stmt MUL const
   17       | stmt DIV ID
   18       | stmt DIV const
   19       | stmt PERC ID
   20       | stmt PERC const
   21       | SUB stmt
   22       | stmt AND rela_stmt
   23       | stmt OR rela_stmt
   24       | NOT stmt
   25       | rela_stmt
   26       | ID
   27       | ID DADD
   28       | ID DSUB
   29       | const
   30       | LSBRA stmt RSBRA

   31  rela_stmt : LSBRA stmt GREAT stmt RSBRA
   32            | LSBRA stmt LESS stmt RSBRA
   33            | LSBRA stmt EQU stmt RSBRA
   34            | LSBRA stmt GEQU stmt RSBRA
   35            | LSBRA stmt LEQU stmt RSBRA
   36            | LSBRA stmt NEQU stmt RSBRA

   37  type : CHAR
   38       | BOOL
   39       | INT
   40       | FLOAT

   41  const : COUNTCHAR
   42        | TRUE
   43        | FALSE
   44        | COUNTINTNUM
   45        | COUNTFLOATNUM


##############################################################################
# States
##############################################################################

state 0
	$accept : . prog $end

	VOID  shift 1

	prog  goto 2


state 1
	prog : VOID . MAIN LLSBRA lines RLSBRA

	MAIN  shift 3


state 2
	$accept : prog . $end  (0)

	$end  accept


state 3
	prog : VOID MAIN . LLSBRA lines RLSBRA

	LLSBRA  shift 4


state 4
	prog : VOID MAIN LLSBRA . lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	lines  goto 13
	expr  goto 14
	type  goto 15


state 5
	type : INT .  (39)

	.  reduce 39


state 6
	type : CHAR .  (37)

	.  reduce 37


state 7
	type : FLOAT .  (40)

	.  reduce 40


state 8
	type : BOOL .  (38)

	.  reduce 38


state 9
	expr : IF . LSBRA stmt RSBRA LLSBRA lines RLSBRA
	expr : IF . LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA

	LSBRA  shift 16


state 10
	expr : WHILE . LSBRA stmt RSBRA LLSBRA lines RLSBRA

	LSBRA  shift 17


state 11
	expr : FOR . LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA

	LSBRA  shift 18


state 12
	expr : ID . EVALU stmt

	EVALU  shift 19


state 13
	prog : VOID MAIN LLSBRA lines . RLSBRA
	lines : lines . expr

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	RLSBRA  shift 20
	ID  shift 12

	expr  goto 21
	type  goto 15


state 14
	lines : expr .  (3)

	.  reduce 3


state 15
	expr : type . ID
	expr : type . ID EVALU stmt

	ID  shift 22


state 16
	expr : IF LSBRA . stmt RSBRA LLSBRA lines RLSBRA
	expr : IF LSBRA . stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 32
	const  goto 33
	rela_stmt  goto 34


state 17
	expr : WHILE LSBRA . stmt RSBRA LLSBRA lines RLSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 35
	const  goto 33
	rela_stmt  goto 34


state 18
	expr : FOR LSBRA . expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	expr  goto 36
	type  goto 15


state 19
	expr : ID EVALU . stmt

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 37
	const  goto 33
	rela_stmt  goto 34


state 20
	prog : VOID MAIN LLSBRA lines RLSBRA .  (1)

	.  reduce 1


state 21
	lines : lines expr .  (2)

	.  reduce 2


state 22
	expr : type ID .  (4)
	expr : type ID . EVALU stmt

	EVALU  shift 38
	.  reduce 4


state 23
	stmt : LSBRA . stmt RSBRA
	rela_stmt : LSBRA . stmt GREAT stmt RSBRA
	rela_stmt : LSBRA . stmt LESS stmt RSBRA
	rela_stmt : LSBRA . stmt EQU stmt RSBRA
	rela_stmt : LSBRA . stmt GEQU stmt RSBRA
	rela_stmt : LSBRA . stmt LEQU stmt RSBRA
	rela_stmt : LSBRA . stmt NEQU stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 39
	const  goto 33
	rela_stmt  goto 34


state 24
	stmt : SUB . stmt

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 40
	const  goto 33
	rela_stmt  goto 34


state 25
	stmt : NOT . stmt

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 41
	const  goto 33
	rela_stmt  goto 34


state 26
	const : COUNTINTNUM .  (44)

	.  reduce 44


state 27
	const : COUNTFLOATNUM .  (45)

	.  reduce 45


state 28
	const : COUNTCHAR .  (41)

	.  reduce 41


state 29
	stmt : ID .  (26)
	stmt : ID . DADD
	stmt : ID . DSUB

	DADD  shift 42
	DSUB  shift 43
	.  reduce 26


state 30
	const : TRUE .  (42)

	.  reduce 42


state 31
	const : FALSE .  (43)

	.  reduce 43


state 32
	expr : IF LSBRA stmt . RSBRA LLSBRA lines RLSBRA
	expr : IF LSBRA stmt . RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	RSBRA  shift 44
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 33
	stmt : const .  (29)

	.  reduce 29


state 34
	stmt : rela_stmt .  (25)

	.  reduce 25


state 35
	expr : WHILE LSBRA stmt . RSBRA LLSBRA lines RLSBRA
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	RSBRA  shift 52
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 36
	expr : FOR LSBRA expr . SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA

	SEMIC  shift 53


state 37
	expr : ID EVALU stmt .  (6)
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51
	.  reduce 6


state 38
	expr : type ID EVALU . stmt

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 54
	const  goto 33
	rela_stmt  goto 34


state 39
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	stmt : LSBRA stmt . RSBRA
	rela_stmt : LSBRA stmt . GREAT stmt RSBRA
	rela_stmt : LSBRA stmt . LESS stmt RSBRA
	rela_stmt : LSBRA stmt . EQU stmt RSBRA
	rela_stmt : LSBRA stmt . GEQU stmt RSBRA
	rela_stmt : LSBRA stmt . LEQU stmt RSBRA
	rela_stmt : LSBRA stmt . NEQU stmt RSBRA

	RSBRA  shift 55
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	GREAT  shift 56
	LESS  shift 57
	EQU  shift 58
	GEQU  shift 59
	LEQU  shift 60
	NEQU  shift 61
	AND  shift 50
	OR  shift 51


state 40
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : SUB stmt .  (21)
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	.  reduce 21


state 41
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	stmt : NOT stmt .  (24)

	.  reduce 24


state 42
	stmt : ID DADD .  (27)

	.  reduce 27


state 43
	stmt : ID DSUB .  (28)

	.  reduce 28


state 44
	expr : IF LSBRA stmt RSBRA . LLSBRA lines RLSBRA
	expr : IF LSBRA stmt RSBRA . LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA

	LLSBRA  shift 62


state 45
	stmt : stmt ADD . ID
	stmt : stmt ADD . const

	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 63
	TRUE  shift 30
	FALSE  shift 31

	const  goto 64


state 46
	stmt : stmt SUB . ID
	stmt : stmt SUB . const

	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 65
	TRUE  shift 30
	FALSE  shift 31

	const  goto 66


state 47
	stmt : stmt MUL . ID
	stmt : stmt MUL . const

	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 67
	TRUE  shift 30
	FALSE  shift 31

	const  goto 68


state 48
	stmt : stmt DIV . ID
	stmt : stmt DIV . const

	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 69
	TRUE  shift 30
	FALSE  shift 31

	const  goto 70


state 49
	stmt : stmt PERC . ID
	stmt : stmt PERC . const

	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 71
	TRUE  shift 30
	FALSE  shift 31

	const  goto 72


state 50
	stmt : stmt AND . rela_stmt

	LSBRA  shift 73

	rela_stmt  goto 74


state 51
	stmt : stmt OR . rela_stmt

	LSBRA  shift 73

	rela_stmt  goto 75


state 52
	expr : WHILE LSBRA stmt RSBRA . LLSBRA lines RLSBRA

	LLSBRA  shift 76


state 53
	expr : FOR LSBRA expr SEMIC . stmt SEMIC expr RSBRA LLSBRA lines RLSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 77
	const  goto 33
	rela_stmt  goto 34


state 54
	expr : type ID EVALU stmt .  (5)
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51
	.  reduce 5


state 55
	stmt : LSBRA stmt RSBRA .  (30)

	.  reduce 30


state 56
	rela_stmt : LSBRA stmt GREAT . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 78
	const  goto 33
	rela_stmt  goto 34


state 57
	rela_stmt : LSBRA stmt LESS . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 79
	const  goto 33
	rela_stmt  goto 34


state 58
	rela_stmt : LSBRA stmt EQU . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 80
	const  goto 33
	rela_stmt  goto 34


state 59
	rela_stmt : LSBRA stmt GEQU . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 81
	const  goto 33
	rela_stmt  goto 34


state 60
	rela_stmt : LSBRA stmt LEQU . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 82
	const  goto 33
	rela_stmt  goto 34


state 61
	rela_stmt : LSBRA stmt NEQU . stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 83
	const  goto 33
	rela_stmt  goto 34


state 62
	expr : IF LSBRA stmt RSBRA LLSBRA . lines RLSBRA
	expr : IF LSBRA stmt RSBRA LLSBRA . lines RLSBRA ELSE LLSBRA lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	lines  goto 84
	expr  goto 14
	type  goto 15


state 63
	stmt : stmt ADD ID .  (11)

	.  reduce 11


state 64
	stmt : stmt ADD const .  (12)

	.  reduce 12


state 65
	stmt : stmt SUB ID .  (13)

	.  reduce 13


state 66
	stmt : stmt SUB const .  (14)

	.  reduce 14


state 67
	stmt : stmt MUL ID .  (15)

	.  reduce 15


state 68
	stmt : stmt MUL const .  (16)

	.  reduce 16


state 69
	stmt : stmt DIV ID .  (17)

	.  reduce 17


state 70
	stmt : stmt DIV const .  (18)

	.  reduce 18


state 71
	stmt : stmt PERC ID .  (19)

	.  reduce 19


state 72
	stmt : stmt PERC const .  (20)

	.  reduce 20


state 73
	rela_stmt : LSBRA . stmt GREAT stmt RSBRA
	rela_stmt : LSBRA . stmt LESS stmt RSBRA
	rela_stmt : LSBRA . stmt EQU stmt RSBRA
	rela_stmt : LSBRA . stmt GEQU stmt RSBRA
	rela_stmt : LSBRA . stmt LEQU stmt RSBRA
	rela_stmt : LSBRA . stmt NEQU stmt RSBRA

	LSBRA  shift 23
	SUB  shift 24
	NOT  shift 25
	COUNTINTNUM  shift 26
	COUNTFLOATNUM  shift 27
	COUNTCHAR  shift 28
	ID  shift 29
	TRUE  shift 30
	FALSE  shift 31

	stmt  goto 85
	const  goto 33
	rela_stmt  goto 34


state 74
	stmt : stmt AND rela_stmt .  (22)

	.  reduce 22


state 75
	stmt : stmt OR rela_stmt .  (23)

	.  reduce 23


state 76
	expr : WHILE LSBRA stmt RSBRA LLSBRA . lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	lines  goto 86
	expr  goto 14
	type  goto 15


state 77
	expr : FOR LSBRA expr SEMIC stmt . SEMIC expr RSBRA LLSBRA lines RLSBRA
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt

	SEMIC  shift 87
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 78
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt GREAT stmt . RSBRA

	RSBRA  shift 88
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 79
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt LESS stmt . RSBRA

	RSBRA  shift 89
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 80
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt EQU stmt . RSBRA

	RSBRA  shift 90
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 81
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt GEQU stmt . RSBRA

	RSBRA  shift 91
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 82
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt LEQU stmt . RSBRA

	RSBRA  shift 92
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 83
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt NEQU stmt . RSBRA

	RSBRA  shift 93
	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	AND  shift 50
	OR  shift 51


state 84
	lines : lines . expr
	expr : IF LSBRA stmt RSBRA LLSBRA lines . RLSBRA
	expr : IF LSBRA stmt RSBRA LLSBRA lines . RLSBRA ELSE LLSBRA lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	RLSBRA  shift 94
	ID  shift 12

	expr  goto 21
	type  goto 15


state 85
	stmt : stmt . ADD ID
	stmt : stmt . ADD const
	stmt : stmt . SUB ID
	stmt : stmt . SUB const
	stmt : stmt . MUL ID
	stmt : stmt . MUL const
	stmt : stmt . DIV ID
	stmt : stmt . DIV const
	stmt : stmt . PERC ID
	stmt : stmt . PERC const
	stmt : stmt . AND rela_stmt
	stmt : stmt . OR rela_stmt
	rela_stmt : LSBRA stmt . GREAT stmt RSBRA
	rela_stmt : LSBRA stmt . LESS stmt RSBRA
	rela_stmt : LSBRA stmt . EQU stmt RSBRA
	rela_stmt : LSBRA stmt . GEQU stmt RSBRA
	rela_stmt : LSBRA stmt . LEQU stmt RSBRA
	rela_stmt : LSBRA stmt . NEQU stmt RSBRA

	ADD  shift 45
	SUB  shift 46
	MUL  shift 47
	DIV  shift 48
	PERC  shift 49
	GREAT  shift 56
	LESS  shift 57
	EQU  shift 58
	GEQU  shift 59
	LEQU  shift 60
	NEQU  shift 61
	AND  shift 50
	OR  shift 51


state 86
	lines : lines . expr
	expr : WHILE LSBRA stmt RSBRA LLSBRA lines . RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	RLSBRA  shift 95
	ID  shift 12

	expr  goto 21
	type  goto 15


state 87
	expr : FOR LSBRA expr SEMIC stmt SEMIC . expr RSBRA LLSBRA lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	expr  goto 96
	type  goto 15


state 88
	rela_stmt : LSBRA stmt GREAT stmt RSBRA .  (31)

	.  reduce 31


state 89
	rela_stmt : LSBRA stmt LESS stmt RSBRA .  (32)

	.  reduce 32


state 90
	rela_stmt : LSBRA stmt EQU stmt RSBRA .  (33)

	.  reduce 33


state 91
	rela_stmt : LSBRA stmt GEQU stmt RSBRA .  (34)

	.  reduce 34


state 92
	rela_stmt : LSBRA stmt LEQU stmt RSBRA .  (35)

	.  reduce 35


state 93
	rela_stmt : LSBRA stmt NEQU stmt RSBRA .  (36)

	.  reduce 36


state 94
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA .  (7)
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA . ELSE LLSBRA lines RLSBRA

	ELSE  shift 97
	.  reduce 7


state 95
	expr : WHILE LSBRA stmt RSBRA LLSBRA lines RLSBRA .  (10)

	.  reduce 10


state 96
	expr : FOR LSBRA expr SEMIC stmt SEMIC expr . RSBRA LLSBRA lines RLSBRA

	RSBRA  shift 98


state 97
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE . LLSBRA lines RLSBRA

	LLSBRA  shift 99


state 98
	expr : FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA . LLSBRA lines RLSBRA

	LLSBRA  shift 100


state 99
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA . lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	lines  goto 101
	expr  goto 14
	type  goto 15


state 100
	expr : FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA . lines RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	ID  shift 12

	lines  goto 102
	expr  goto 14
	type  goto 15


state 101
	lines : lines . expr
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines . RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	RLSBRA  shift 103
	ID  shift 12

	expr  goto 21
	type  goto 15


state 102
	lines : lines . expr
	expr : FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines . RLSBRA

	INT  shift 5
	CHAR  shift 6
	FLOAT  shift 7
	BOOL  shift 8
	IF  shift 9
	WHILE  shift 10
	FOR  shift 11
	RLSBRA  shift 104
	ID  shift 12

	expr  goto 21
	type  goto 15


state 103
	expr : IF LSBRA stmt RSBRA LLSBRA lines RLSBRA ELSE LLSBRA lines RLSBRA .  (8)

	.  reduce 8


state 104
	expr : FOR LSBRA expr SEMIC stmt SEMIC expr RSBRA LLSBRA lines RLSBRA .  (9)

	.  reduce 9


##############################################################################
# Summary
##############################################################################

41 token(s), 8 nonterminal(s)
46 grammar rule(s), 105 state(s)


##############################################################################
# End of File
##############################################################################
