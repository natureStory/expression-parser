/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
['].*?[']                                           return 'STRING'
["].*?["]                                           return 'STRING'

(\$dec\.)((?:(?!\&\&|\|\|)[^])*)(==(\s)*(true|false))             return 'STRING'           /* 需要比 contains** */
"$dec.containsAll"                                                return 'DEC_CONTAINSALL'
"!"\s*"$dec.containsAll"                                          return 'DEC_NOT_CONTAINSALL'
"$dec.containsIntersection"                                       return 'DEC_CONTAINSINTERSECTION'
"$dec.notContainsIntersection"                                    return 'DEC_NOT_CONTAINSINTERSECTION'
"$dec.contains"                                                   return 'DEC_CONTAINS'
"!"\s*"$dec.contains"                                             return 'DEC_NOT_CONTAINS'
"$dec"                                                            return 'DEC'
"."                                                               return '.'
","                                                               return ','



"&&"                   return '&&'
"||"                   return '||'
"("                    return '('
")"                    return ')'
"=="                   return '=='
"!="                   return '!='
"!"                    return '!'
">="                   return '>='
">"                    return '>'
"<="                   return "<="
"<"                    return '<'

[-]?[0-9]+(\.[0-9]+)?                                             return 'NUMBER'
true|false                                                        return 'BOOLEAN'
null                                                              return 'NULL'

[a-zA-Z_\+\-\*\/\%\u4e00-\u9fa5][a-zA-Z0-9_\+\-\*\/\%\u4e00-\u9fa5]*                  return 'IDENTIFIER'
[\w]+[\u4e00-\u9fa5]+[0-9a-zA-Z_\u4e00-\u9fa5]*                   return 'IDENTIFIER'
[\u4e00-\u9fa5][0-9a-zA-Z_\u4e00-\u9fa5]*                         return 'IDENTIFIER'

<<EOF>>                return 'EOF'

/lex

/* operator associations and precedence */
%left '||'
%left '&&'
%left '!=' '!' '=='
%left '>=' '>' '<=' '<'

%start expressions

%% /* language grammar */

expressions
    : e EOF
        {return $1;}
    ;
// 逻辑组合 根节点
e
    : identifier
        { $$ = $1 }
    | exist
        { $$ = $1 }
    | not_exist
    | intersection
        { $$ = $1 }
    | no_intersection
        { $$ = $1 }
    | belong
        { $$ = $1 }
    | not_belong
        { $$ = $1 }
    | function
        { $$ = $1 }
    | e '&&' e
        { $$ = { type:'logic_op', op:'&&', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'&&'+$3.toString() } }
    | e '||' e
        { $$ = { type:'logic_op', op:'||', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'||'+$3.toString()} }
    | '!' e
        { $$ = { type:'logic_op', op:'!', r_expr:$2, toString:()=>'!'+$2.toString()} }
    | e '!=' e
        { $$ = { type:'binary_op', op:'!=', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'!='+$3.toString()} }
    | e '==' e
        { $$ = { type:'binary_op', op:'==', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'=='+$3.toString()} }
    | e '>=' e
        { $$ = { type:'binary_op', op:'>=', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'>='+$3.toString()} }
    | e '>' e
        { $$ = { type:'binary_op', op:'>', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'>'+$3.toString()} }
    | e '<=' e
        { $$ = { type:'binary_op', op:'<=', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'<='+$3.toString()} }
    | e '<' e
        { $$ = { type:'binary_op', op:'<', l_expr:$1, r_expr:$3, toString:()=>$1.toString()+'<'+$3.toString()} }
    | '(' e ')'
        { $$ = { type:'', op:"()", expr:$2, toString:()=>'('+$2.toString()+')'} }
    ;
// 标识符 叶子结点

identifier
    : number
        { $$ = $1 }
    | string
        { $$ = $1 }
    | boolean
        { $$ = $1 }
    | null
        { $$ = $1 }
    | IDENTIFIER { $$ = { type:'Identifier', value:$1, toString:()=> $1 } }
    | identifier '.' IDENTIFIER { $$ = $1; $1.value += '.' + $3; $$.toString = ()=> $1.value }
    ;
identifier_list
    : identifier { $$ = [ $1 ] }
    | identifier_list ',' identifier { $$ = $1; $1.push($3); }
    ;

number
    : NUMBER { $$ = { type:'Number', value:$1, toString:()=> $1 } }
    ;

string
    : STRING { $$ = { type:'String', value:$1, toString:()=> $1 } }
    ;

boolean
    : BOOLEAN { $$ = { type:'Boolean', value:$1, toString:()=> $1 } }
    ;

null
    : NULL { $$ = { type:'Null', value:$1, toString:()=> $1 } }
    ;

function
    : identifier '(' identifier_list ')' { $$ = {type:'Function', name:$1.value, params:$3, toString:()=> $1.value+'('+$3.map(i=>i.toString()).join(',')+')'} }
    | DEC '.' function { $$ = {type: $3.type, name: '$dec.'+$3.name, params: $3.params, toString:()=> '$dec.'+$3.toString() } }
    ;

belong
    : DEC_CONTAINSALL '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'belong', l_expr:$3, r_expr:$5, toString:()=> '$dec.containsAll('+$3.toString()+','+$5.toString()+')' } }
    ;

not_belong
    : DEC_NOT_CONTAINSALL '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'not_belong', l_expr:$3, r_expr:$5, toString:()=> '!$dec.containsAll('+$3.toString()+','+$5.toString()+')' } }
    ;

exist
    : DEC_CONTAINS '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'exist', l_expr:$3, r_expr:$5, toString:()=> '$dec.contains('+$3.toString()+','+$5.toString()+')' } }
    ;

not_exist
    : DEC_NOT_CONTAINS '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'not_exist', l_expr:$3, r_expr:$5, toString:()=> '!$dec.contains('+$3.toString()+','+$5.toString()+')' } }
    ;

intersection
    : DEC_CONTAINSINTERSECTION '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'intersection', l_expr:$3, r_expr:$5, toString:()=> '$dec.containsIntersection('+$3.toString()+','+$5.toString()+')' } }
    ;

no_intersection
    : DEC_NOT_CONTAINSINTERSECTION '(' identifier ',' identifier ')'
        { $$ = { type:'binary_op', op:'no_intersection', l_expr:$3, r_expr:$5, toString:()=> '$dec.notContainsIntersection('+$3.toString()+','+$5.toString()+')' } }
    ;





