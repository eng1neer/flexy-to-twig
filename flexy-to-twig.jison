/* lexical grammar */
%lex

%options case-insensitive

digit                       [0-9]
num                         ('-')?{digit}+(\.{digit}+)?([E|e][\+\-]?{digit}+)?
letter                      [a-zA-Z]
letter_                     [a-zA-Z_]
id                          {letter_}({letter_}|{digit})*
param_name                  {letter_}({letter_}|{digit}|\-)*
tag_name                    {letter_}({letter_}|\-|{digit})*
attr_name                   {letter_}({letter_}|\-|{digit})*
lbrace                      '{'
rbrace                      '}'
lcomment                    '{*'
rcomment                    '*}'
lparen                      '('
rparen                      ')'
lt                          '<'
gt                          '>'
modifier                    ('striptags'|'h'|'r'|'u'|'s'|'b'|'nl2br')
dot                         '.'
comma                       ','
colon                       ':'
double_colon                '::'
percent                     '%'
hash                        '#'
array                       '_ARRAY_'
caret                       '^'
negation                    '!'
and                         '&'
or                          '|'
equals                      '='
less_than                   '<'
greater_than                '>'
single_quote                '\''
double_quote                '"'
quote                       ('\''|'"')
slash                       '/'
delim                       [ \t\n\r\f\b]
nondelim                    [^ \t\n\r\f\b]
whitespace                  {delim}+
any                         (.|{delim})*?
other                       (.|{delim})+?
doctype                     '<!DOCTYPE'[^>]+'>'
html_comment_start          '<!--'
html_comment_end            '-->'
cdata_start                 '<![CDATA['
cdata_end                   ']]>'
if                          'if'
elseif                      'elseif'
flexy_end                   '{end:}'
flexy_else                  '{else:}'
foreach                     'foreach'
if_attr                     'IF'
selected_attr               'selected'
checked_attr                'checked'
disabled_attr               'disabled'
foreach_attr                'FOREACH'
widget_tag                  'widget'
list_tag                    'list'

%{
    this.trimYytext = function () {
        this.yytext = this.yytext.substr(1, yytext.length - 2);
    };

    this.yield = function (token) {
        //console.log('[' + token + '] ' + JSON.stringify(yytext) + ' <' + this.topState() + '>');

        return token;
    };
%}

%x html html_comment cdata flexy_exp flexy_attr_exp flexy_bare_attr_exp flexy_string flexy_comment open_tag close_tag attrs params param_sq param_dq param_unq attrs_delim squoted_attr dquoted_attr php
%%

<html>{doctype}                                                                                    return this.yield('TEXT');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr,param_sq,param_dq,param_unq>{lcomment}           this.begin('flexy_comment');
<attrs>{lcomment}                                                                                  this.replaceState('attrs_delim'); this.begin('flexy_comment');
<html><<EOF>>                                                                                      return this.yield('EOF');

<html,cdata,attrs_delim,squoted_attr,dquoted_attr>{lbrace}{elseif}{colon}                          this.begin('flexy_exp'); return this.yield('ELSEIF');
<attrs>{lbrace}{elseif}{colon}                                                                     this.begin('attrs_delim'); this.begin('flexy_exp'); return this.yield('ELSEIF');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr>{flexy_else}                                     return this.yield('ELSE');
<attrs>{flexy_else}                                                                                this.begin('attrs_delim'); return this.yield('ELSE');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr>{flexy_end}                                      return this.yield('END');
<attrs>{flexy_end}                                                                                 this.begin('attrs_delim'); return this.yield('END');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr,param_sq,param_dq,param_unq>{lbrace}/{id}        this.begin('flexy_exp'); return this.yield('LBRACE');
<attrs>{lbrace}/{id}                                                                               this.begin('attrs_delim'); this.begin('flexy_exp'); return this.yield('LBRACE');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr,param_sq,param_dq,param_unq>{lbrace}/{digit}     this.begin('flexy_exp'); return this.yield('LBRACE');
<attrs>{lbrace}/{digit}                                                                            this.begin('attrs_delim'); this.begin('flexy_exp'); return this.yield('LBRACE');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr,param_sq,param_dq,param_unq>{lbrace}/{hash}      this.begin('flexy_exp'); return this.yield('LBRACE');
<html,cdata,attrs_delim,squoted_attr,dquoted_attr,param_sq,param_dq,param_unq>{lbrace}/{percent}   this.begin('flexy_exp'); return this.yield('LBRACE');
<attrs>{lbrace}/{hash}                                                                             this.begin('attrs_delim'); this.begin('flexy_exp'); return this.yield('LBRACE');

<html>{lt}/{tag_name}                                                       this.begin('open_tag'); return this.yield('LT');
<html>{lt}/{slash}                                                          this.begin('close_tag'); return this.yield('LT');
<html>{gt}                                                                  return this.yield('GT');
<html>{html_comment_start}                                                  this.begin('html_comment'); return this.yield('HTML_COMMENT_START');
<html>{html_comment_end}                                                    return this.yield('HTML_COMMENT_END');
<html>{cdata_start}                                                         this.begin('cdata'); return this.yield('CDATA_START');
<html>{cdata_end}                                                           return this.yield('CDATA_END');

<cdata>/{cdata_end}                                                         this.popState();

<html,cdata>{other}                                                         return this.yield('TEXT');

<html_comment>/{html_comment_end}                                           this.popState();
<html_comment>{other}                                                       return this.yield('TEXT');

<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{if}{colon}                   return this.yield('IF');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{foreach}{colon}              return this.yield('FOREACH');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{array}                       return this.yield('ARRAY');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{id}                          return this.yield('ID');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{num}                         return this.yield('NUMBER');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{dot}                         return this.yield('DOT');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{lparen}                      return this.yield('LPAREN');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{rparen}                      return this.yield('RPAREN');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{comma}                       return this.yield('COMMA');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{negation}                    return this.yield('NEGATION');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{and}                         return this.yield('AND');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{or}                          return this.yield('OR');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{equals}                      return this.yield('EQUALS');
<flexy_exp,flexy_attr_exp>{less_than}                                       return this.yield('LESS_THAN');
<flexy_exp,flexy_attr_exp>{greater_than}                                    return this.yield('GREATER_THAN');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{hash}{hash}                  yytext = ''; return this.yield('STRING');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{hash}                        this.begin('flexy_string');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{percent}                     this.begin('php'); return 'PHP_START';
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{colon}{modifier}             yytext = yytext.substr(1); return this.yield('MODIFIER');
<flexy_exp,flexy_attr_exp,flexy_bare_attr_exp>{caret}                       return this.yield('CARET');
<flexy_exp>{rbrace}                                                         this.popState(); return this.yield('RBRACE');

<flexy_attr_exp>({rbrace}|{quote})+/({delim}|{gt}|({slash}{gt})|{lbrace})   this.popState(); return this.yield('FLEXY_ATTR_EXP_END');
<flexy_bare_attr_exp>/({delim}|{gt}|({slash}{gt})|{lbrace})                 this.popState(); return this.yield('FLEXY_ATTR_EXP_END');
<flexy_exp,flexy_attr_exp>{delim}+                                          // skip whitespace

<flexy_string>{hash}                                     this.popState();
<flexy_string>{any}/{hash}                               return this.yield('STRING');

<php>{percent}                                           this.popState(); return 'PHP_END';
<php>{double_colon}                                      return this.yield('DOUBLE_COLON');
<php>{other}                                             return this.yield('TEXT');

<flexy_comment>{rcomment}                                this.popState();
<flexy_comment>{any}/{rcomment}                          return this.yield('FLEXY_COMMENT');

<open_tag>{widget_tag}                                   this.begin('params'); return this.yield('WIDGET_TAG');
<open_tag>{list_tag}                                     this.begin('params'); return this.yield('LIST_TAG');
<open_tag>{tag_name}                                     this.begin('attrs'); return this.yield('TAG');
<open_tag>/{gt}                                          this.popState();
<open_tag>{slash}{delim}*/{gt}                           this.popState(); return this.yield('SLASH');

<params>{delim}+                                         // skip whitespace
<params>{foreach_attr}{equals}({quote}|{lbrace})+        this.begin('flexy_attr_exp'); return this.yield('FOREACH_ATTR');
<params>{if_attr}{equals}({quote}|{lbrace})+             this.begin('flexy_attr_exp'); return this.yield('IF_ATTR');
<params>{param_name}{equals}{single_quote}               yytext = yytext.substr(0, yytext.length-2); this.begin('param_sq'); return this.yield('PARAM');
<params>{param_name}{equals}{double_quote}               yytext = yytext.substr(0, yytext.length-2); this.begin('param_dq'); return this.yield('PARAM');
<params>{param_name}{equals}                             yytext = yytext.substr(0, yytext.length-1); this.begin('param_unq'); return this.yield('PARAM');
<params>{param_name}                                     return this.yield('PARAM_WO_VALUE');
<params>/({slash}?{delim}*{gt})                          this.popState();

<param_sq>{single_quote}                                 this.popState();
<param_sq>{other}                                        return this.yield('TEXT');

<param_dq>{double_quote}                                 this.popState();
<param_dq>{other}                                        return this.yield('TEXT');

<param_unq>{delim}                                       this.popState();
<param_unq>/({slash}?{delim}*{gt})                       this.popState();
<param_unq>{nondelim}                                    return this.yield('TEXT');

<close_tag>{slash}                                       return this.yield('SLASH');
<close_tag>{tag_name}                                    return this.yield('TAG');
<close_tag>{delim}*/{gt}                                 this.popState();

<attrs_delim>{if_attr}{equals}({quote}|{lbrace})+        this.begin('flexy_attr_exp'); return this.yield('IF_ATTR');
<attrs_delim>{if_attr}{equals}                           this.begin('flexy_bare_attr_exp'); return this.yield('IF_ATTR');
<attrs_delim>{selected_attr}{equals}{quote}?{lbrace}+    this.begin('flexy_attr_exp'); return this.yield('SELECTED_ATTR');
<attrs_delim>{checked_attr}{equals}{quote}?{lbrace}+     this.begin('flexy_attr_exp'); return this.yield('CHECKED_ATTR');
<attrs_delim>{disabled_attr}{equals}{quote}?{lbrace}+    this.begin('flexy_attr_exp'); return this.yield('DISABLED_ATTR');
<attrs_delim>{foreach_attr}{equals}({quote}|{lbrace})+   this.begin('flexy_attr_exp'); return this.yield('FOREACH_ATTR');
<attrs_delim>{foreach_attr}{equals}                      this.begin('flexy_bare_attr_exp'); return this.yield('FOREACH_ATTR');
<attrs,attrs_delim>{equals}{double_quote}                this.begin('dquoted_attr'); return this.yield('TEXT');
<attrs,attrs_delim>{equals}{single_quote}                this.begin('squoted_attr'); return this.yield('TEXT');
<attrs,attrs_delim>/({slash}{delim}*{gt})                this.popState();
<attrs,attrs_delim>/{gt}                                 this.popState();
<attrs>{delim}                                           this.begin('attrs_delim'); return this.yield('TEXT');
<attrs>{other}                                           return this.yield('TEXT');
<attrs_delim>{delim}                                     return this.yield('TEXT');
<attrs_delim>{other}                                     this.popState(); return this.yield('TEXT');

<squoted_attr>/{single_quote}                            this.popState();
<squoted_attr>{other}                                    return this.yield('TEXT');

<dquoted_attr>/{double_quote}                            this.popState();
<dquoted_attr>{other}                                    return this.yield('TEXT');


<INITIAL>                                                this.begin('html');


/lex

%right HTML_TEXT TEXT

%ebnf

%start prog

%% /* language grammar */

prog
 : EOF
     { $$ = []; }
 | stmts EOF
     { process.stdout.write(renderTwig($stmts)); return $stmts; }
 ;

stmts
 : stmts stmt
     { $$ = [].concat($stmts, $stmt); }
 | stmt
     { $$ = [$stmt]; }
 ;

stmt
 : html
 | html_comment
 | cdata
 | flexy
 ;

html_comment
 : HTML_COMMENT_START text HTML_COMMENT_END
     { $$ = { type: 'HTML_COMMENT', value: $text }; }
;

html
 : tag
 | text %prec HTML_TEXT
     { $$ = { type: 'TEXT', value: $text }; }
 ;

cdata
 : CDATA_START cdata_content CDATA_END
     { $$ = { type: 'CDATA', items: $cdata_content }; }
 ;

cdata_content
 :
     { $$ = []; }
 | text cdata_content
     { $$ = [].concat({ type: 'TEXT', value: $text }, $cdata_content); }
 | flexy cdata_content
     { $$ = [].concat($flexy, $cdata_content); }
 ;

text
 : TEXT
     { $$ = $TEXT; }
 | TEXT text
     { $$ = $TEXT + $text; }
 ;

tag
 : open_tag
 | close_tag
 ;

open_tag
 : LT TAG attrs GT
     { $$ = { type: 'OPEN_TAG', name: $TAG, attrs: $attrs }; }
 | LT TAG attrs SLASH GT
     { $$ = { type: 'OPEN_CLOSE_TAG', name: $TAG, attrs: $attrs }; }
 | LT WIDGET_TAG params GT
     { $$ = { type: 'WIDGET_TAG', params: $params }; }
 | LT WIDGET_TAG params SLASH GT
     { $$ = { type: 'WIDGET_TAG', params: $params }; }
 | LT LIST_TAG params GT
     { $$ = { type: 'LIST_TAG', params: $params }; }
 | LT LIST_TAG params SLASH GT
     { $$ = { type: 'LIST_TAG', params: $params }; }
 ;

close_tag
 : LT SLASH TAG GT
     { $$ = { type: 'CLOSE_TAG', name: $TAG }; }
 ;

params
 : param
     { $$ = [$param]; }
 | param params
     { $$ = [].concat($param, $params); }
 ;

param
 : PARAM param_value
     { $$ = { type: 'PARAM', name: $PARAM, value: $param_value }; }
 | PARAM_WO_VALUE
     { $$ = { type: 'PARAM', name: $PARAM_WO_VALUE }; }
 | IF_ATTR flexy_composite_cond_exp FLEXY_ATTR_EXP_END
     { $$ = { type: 'IF_ATTR', cond: $flexy_composite_cond_exp }; }
 | FOREACH_ATTR flexy_exp COMMA ID COMMA ID FLEXY_ATTR_EXP_END
     { $$ = { type: 'FOREACH_ATTR', exp: $flexy_exp, key: $ID1, value: $ID2 }; }
 | FOREACH_ATTR flexy_exp COMMA ID FLEXY_ATTR_EXP_END
     { $$ = { type: 'FOREACH_ATTR', exp: $flexy_exp, value: $ID }; }
 ;

param_value
 :
     { $$ = []; }
 | text param_value
     { $$ = [].concat({ type: 'STRING', value: $text }, $param_value); }
 | flexy_param_val_exp param_value
     { $$ = [].concat($flexy_param_val_exp, $param_value); }
 | flexy_comment param_value
     { $$ = [].concat($param_value); }
 | LBRACE flexy_composite_cond_exp RBRACE param_value
     { $$ = [].concat($flexy_composite_cond_exp, $param_value); }
 ;

attrs
 :
     { $$ = []; }
 | text attrs
     { $$ = [].concat({ type: 'TEXT', value: $text }, $attrs); }
 | flexy attrs
     { $$ = [].concat($flexy, $attrs); }
 | IF_ATTR flexy_composite_cond_exp FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'IF_ATTR', cond: $flexy_composite_cond_exp }, $attrs); }
 | SELECTED_ATTR flexy_composite_cond_exp FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'SELECTED_ATTR', cond: $flexy_composite_cond_exp }, $attrs); }
 | CHECKED_ATTR flexy_composite_cond_exp FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'CHECKED_ATTR', cond: $flexy_composite_cond_exp }, $attrs); }
 | DISABLED_ATTR flexy_composite_cond_exp FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'DISABLED_ATTR', cond: $flexy_composite_cond_exp }, $attrs); }
 | FOREACH_ATTR flexy_exp COMMA ID COMMA ID FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'FOREACH_ATTR', exp: $flexy_exp, key: $ID1, value: $ID2 }, $attrs); }
 | FOREACH_ATTR flexy_exp COMMA ID FLEXY_ATTR_EXP_END attrs
     { $$ = [].concat({ type: 'FOREACH_ATTR', exp: $flexy_exp, value: $ID }, $attrs); }
 ;

flexy
 : flexy_output_exp
 | flexy_if_exp
 | flexy_foreach_exp
 | flexy_comment
 ;

flexy_comment
 : FLEXY_COMMENT
     { $$ = { type: 'FLEXY_COMMENT', value: $FLEXY_COMMENT }; }
 ;

flexy_if_exp
 : LBRACE IF flexy_composite_cond_exp RBRACE stmts flexy_elseif_stmt* flexy_else END
     { $$ = { type: 'IF_COND', cond: $flexy_composite_cond_exp, body_if: $stmts, body_else: $flexy_else, elseif: $6 }; }
 ;

flexy_else
 :
 | ELSE stmts
     { $$ = $stmts; }
 ;

flexy_elseif_stmt
 : ELSEIF flexy_composite_cond_exp RBRACE stmts
     { $$ = { type: 'ELSEIF', cond: $flexy_composite_cond_exp, body: $stmts }; }
 ;

flexy_foreach_exp
 : LBRACE FOREACH flexy_exp COMMA ID COMMA ID RBRACE stmts END
     { $$ = { type: 'FOREACH', exp: $flexy_exp, key: $ID1, value: $ID2, body: $stmts }; }
 | LBRACE FOREACH flexy_exp COMMA ID RBRACE stmts END
     { $$ = { type: 'FOREACH', exp: $flexy_exp, value: $ID, body: $stmts }; }
 ;

flexy_composite_cond_exp
 : flexy_composite_or_cond_exp;

flexy_composite_or_cond_exp
 : flexy_composite_pos_and_cond_exp
 | NEGATION flexy_composite_pos_and_cond_exp
     { $$ = { type: 'NEGATE', value: $flexy_composite_pos_and_cond_exp }; }
 | NEGATION flexy_composite_pos_and_cond_exp OR flexy_composite_or_cond_exp
     { $$ = { type: 'NEGATE', value: { type: 'OR_COND', items: [$flexy_composite_pos_and_cond_exp, $flexy_composite_or_cond_exp] } }; }
 | flexy_composite_pos_and_cond_exp OR flexy_composite_or_cond_exp
     { $$ = { type: 'OR_COND', items: [$flexy_composite_pos_and_cond_exp, $flexy_composite_or_cond_exp] }; }
 ;

flexy_composite_pos_and_cond_exp
 : flexy_cond_exp
 | flexy_cond_exp AND flexy_composite_and_cond_exp
     { $$ = { type: 'AND_COND', items: [$flexy_cond_exp, $flexy_composite_and_cond_exp] }; }
 ;

flexy_composite_and_cond_exp
 : flexy_cond_exp
 | NEGATION flexy_cond_exp
     { $$ = { type: 'NEGATE', value: $flexy_cond_exp }; }
 | flexy_cond_exp AND flexy_composite_and_cond_exp
     { $$ = { type: 'AND_COND', items: [$flexy_cond_exp, $flexy_composite_and_cond_exp] }; }
 | NEGATION flexy_cond_exp AND flexy_composite_and_cond_exp
     { $$ = { type: 'NEGATE', value: { type: 'AND_COND', items: [$flexy_cond_exp, $flexy_composite_and_cond_exp] } }; }
 ;

flexy_cond_exp
 : flexy_exp
     { $$ = { type: 'COND', value: $flexy_exp }; }
 | flexy_exp EQUALS flexy_exp
     { $$ = { type: 'EQUALS_COND', items: [$flexy_exp1, $flexy_exp2] }; }
 | flexy_exp LESS_THAN flexy_exp
     { $$ = { type: 'LESS_THAN_COND', items: [$flexy_exp1, $flexy_exp2] }; }
 | flexy_exp GREATER_THAN flexy_exp
     { $$ = { type: 'GREATER_THAN_COND', items: [$flexy_exp1, $flexy_exp2] }; }
 ;

flexy_output_exp
 : LBRACE flexy_exp RBRACE
     { $$ = { type: 'OUTPUT', item: $flexy_exp }; }
 | LBRACE flexy_exp MODIFIER RBRACE
     { $$ = { type: 'OUTPUT', item: $flexy_exp, modifier: $MODIFIER }; }
 ;

flexy_param_val_exp
 : LBRACE flexy_exp MODIFIER? RBRACE
     { $$ = { type: 'EVAL', item: $flexy_exp }; }
 ;

flexy_exp
 : flexy_singular_exp
     { $$ = { type: 'NAME_CHAIN', items: [$flexy_singular_exp] }; }
 | flexy_complex_exp
     { $$ = { type: 'NAME_CHAIN', items: $flexy_complex_exp }; }
 | php_static_member_access
 ;

php_static_member_access
 : PHP_START text DOUBLE_COLON text PHP_END
       { $$ = { type: 'PHP_STATIC_MEMBER_ACCESS', context: $text1, member: $text2 }; }
 ;

flexy_complex_exp
 : flexy_singular_exp DOT flexy_complex_exp_tail
     { $$ = [].concat($flexy_singular_exp, $flexy_complex_exp_tail); }
 ;

flexy_complex_exp_tail
 : flexy_singular_exp
     { $$ = [$flexy_singular_exp]; }
 | flexy_singular_exp DOT flexy_complex_exp_tail
     { $$ = [].concat($flexy_singular_exp, $flexy_complex_exp_tail); }
 ;

flexy_singular_exp
 : flexy_property
 | flexy_function_call
 | flexy_literal
 ;

flexy_property
 : ID
     { $$ = { type: 'PROPERTY', name: $ID }; }
 ;

flexy_function_call
 : ID LPAREN flexy_args RPAREN
     { $$ = { type: 'CALL', name: $ID, arguments: $flexy_args }; }
 ;

flexy_args
 :
     { $$ = []; }
 | flexy_exp
     { $$ = [$flexy_exp]; }
 | flexy_args COMMA flexy_exp
     { $$ = [].concat($flexy_args, $flexy_exp); }
 ;

flexy_literal
 : STRING
     { $$ = { type: 'STRING', value: $STRING }; }
 | NUMBER
     { $$ = { type: 'NUMBER', value: $NUMBER }; }
 | flexy_array
 ;

flexy_array
 : ARRAY LPAREN flexy_array_items RPAREN
     { $$ = { type: 'ARRAY', items: $flexy_array_items }; }
 ;

flexy_array_items
 :
     { $$ = []; }
 | flexy_array_item
     { $$ = [$flexy_array_item]; }
 | flexy_array_item COMMA flexy_array_items
     { $$ = [].concat($flexy_array_item, $flexy_array_items); }
 ;

flexy_array_item
 : flexy_kv_pair
 | flexy_exp
;

flexy_kv_pair
 : flexy_literal CARET flexy_exp
     { $$ = { type: 'KV', key: $flexy_literal, value: $flexy_exp }; }
 | php_static_member_access CARET flexy_exp
     { $$ = { type: 'KV', key: $php_static_member_access, value: $flexy_exp }; }
 ;

%%

GLOBAL.prettyPrint = function (obj) {
    console.log(JSON.stringify(obj, null, 4));
};

GLOBAL.renderTwig = function (nodes) {
    var _ = require('underscore');

    //prettyPrint(nodes);

    var tagStack = [];
    var currentIndent = 0, extraIndent = 0, ts = 2, isBlankRow = true;

    var builtIns = {
        't': 't',
        'buildURL': 'url'
    };

    function renderNode(node, scope, overrideType) {
        var type = overrideType || node.type;

        switch (type) {
            case 'FLEXY_COMMENT':
                var val = node.value.replace(/^(\s*)(\*+)/mg, function(match, contents, offset, s) {
                    return match.replace(/\*/g, '#');
                });

                return t('{#' + val + '#}');

            case 'HTML_COMMENT':
                return t('<!--' + node.value + '-->');

            case 'CDATA':
                return t('<![CDATA[') + joinWithText(renderNodes(node.items, scope), '') + t(']]>');

            case 'IF_COND':
                return t('{% if ') + renderNode(node.cond, scope) + t(' %}')
                    + joinWithText(renderNodes(node.body_if, scope), '')
                    + (node.elseif ? joinWithText(renderNodes(node.elseif, scope), '') : '')
                    + (node.body_else ? t('{% else %}') + joinWithText(renderNodes(node.body_else, scope), '') : '')
                    + t('{% endif %}');
            case 'ELSEIF':
                return t('{% elseif ') + renderNode(node.cond, scope) + t(' %}')
                    + joinWithText(renderNodes(node.body, scope), '');

            case 'FOREACH':
                var newScope = node.key ? scope.concat(node.key, node.value) : scope.concat(node.value);

                return t('{% for ' + (node.key ? node.key + ', ' : '') + node.value + ' in ') + renderNode(node.exp, scope) + t(' %}')
                    + joinWithText(renderNodes(node.body, newScope), '')
                    + t('{% endfor %}');

            case 'COND':
                return renderNode(node.value, scope);
            case 'NEGATE':
                if (node.value.type == 'EQUALS_COND') {
                    return renderNode(node.value, scope, 'NOT_EQUALS_COND');
                }
                if (node.value.type == 'LESS_THAN_COND') {
                    return renderNode(node.value, scope, 'GREATER_THAN_OR_EQUALS_COND');
                }
                if (node.value.type == 'GREATER_THAN_COND') {
                    return renderNode(node.value, scope, 'LESS_THAN_OR_EQUALS_COND');
                }

                return t('not ') + (node.value.type == 'COND'
                    ? renderNode(node.value, scope)
                    : t('(') + renderNode(node.value, scope) + t(')'));

            case 'AND_COND':
                return joinWithText(renderNodes(node.items, scope), ' and ');
            case 'OR_COND':
                return joinWithText(renderNodes(node.items, scope), ' or ');
            case 'EQUALS_COND':
                return renderNode(node.items[0], scope) + t(' == ') + renderNode(node.items[1], scope);
            case 'NOT_EQUALS_COND':
                return renderNode(node.items[0], scope) + t(' != ') + renderNode(node.items[1], scope);
            case 'LESS_THAN_COND':
                return renderNode(node.items[0], scope) + t(' < ') + renderNode(node.items[1], scope);
            case 'GREATER_THAN_COND':
                return renderNode(node.items[0], scope) + t(' > ') + renderNode(node.items[1], scope);
            case 'LESS_THAN_OR_EQUALS_COND':
                return renderNode(node.items[0], scope) + t(' <= ') + renderNode(node.items[1], scope);
            case 'GREATER_THAN_OR_EQUALS_COND':
                return renderNode(node.items[0], scope) + t(' >= ') + renderNode(node.items[1], scope);

            case 'OUTPUT':
                var modifiers = {
                    h: 'raw',
                    r: '',
                    u: 'url_encode',
                    b: 'nl2br',
                    nl2br: 'nl2br',
                    striptags: 'striptags'
                };

                if (typeof(node.modifier) != 'undefined') {
                    var filter = modifiers[node.modifier];
                }

                if (node.modifier == 's') {
                    return t('{% do ') + renderNode(node.item, scope) + t(' %}');
                }

                return t('{{ ') + renderNode(node.item, scope) + t(filter ? '|' + filter : '') + t(' }}');
            case 'EVAL':
                return renderNode(node.item, scope);
            case 'PROPERTY':
                return t(node.name);
            case 'CALL':
                return t(node.name + '(') + joinWithText(renderNodes(node.arguments, scope), ', ') + t(')');
            case 'NAME_CHAIN':
                var first     = node.items[0],
                    addThis   = first.type == 'PROPERTY' || first.type == 'CALL',
                    isBuiltIn = _.has(builtIns, first.name),
                    isSpecial = first.type == 'PROPERTY' && (first.name.match(/[a-zA-Z_]+ArraySize/) || first.name.match(/[a-zA-Z_]+ArrayPointer/));

                addThis = addThis && !isVarInScope(first.name, scope, tagStack) && !isBuiltIn && !isSpecial;

                if (isBuiltIn) {
                    first = _.clone(first);

                    first.name = builtIns[first.name];
                }

                if (isSpecial) {
                    first = _.clone(first);

                    first.name = first.name
                        .replace(/[a-zA-Z_]+ArrayPointer/, 'loop.index')
                        .replace(/[a-zA-Z_]+ArraySize/, 'loop.length');
                }

                return (addThis ? t('this.') : '') + joinWithText([renderNode(first, scope)].concat(renderNodes(node.items.slice(1), scope)), '.');
            case 'STRING':
                return t('\'') + node.value.replace(/\\/g, '\\\\').replace(/'/g, '\\\'').replace(/\.tpl\b/i, '.twig') + t('\'');
            case 'NUMBER':
                return t(node.value);
            case 'ARRAY':
                var isHash  = _.any(node.items, function (item) { return item.type == 'KV'; }),
                    isMixed = isHash && _.any(node.items, function (item) { return item.type != 'KV'; });

                if (isMixed) {
                    throw new Error('Mixed arrays/hashes are not supported');
                } else if (isHash) {
                    return t('{') + joinWithText(renderNodes(node.items, scope), ', ') + t('}');
                } else {
                    return t('[') + joinWithText(renderNodes(node.items, scope), ', ') + t(']');
                }

                return t('');
            case 'KV':
                var key = node.key.type == 'STRING' || node.key.type == 'NUMBER'
                    ? renderNode(node.key, scope)
                    : t('(') + renderNode(node.key, scope) + t(')');

                return key + t(': ') + renderNode(node.value, scope);

            case 'TEXT':
                return t(node.value);
            case 'OPEN_TAG':
            case 'OPEN_CLOSE_TAG':
                var selfClosing = type == 'OPEN_CLOSE_TAG';

                var selfClosingTags = ['area',
                                       'base',
                                       'br',
                                       'col',
                                       'command',
                                       'embed',
                                       'hr',
                                       'img',
                                       'input',
                                       'keygen',
                                       'link',
                                       'meta',
                                       'param',
                                       'source',
                                       'track',
                                       'wbr'];

                return openTag(node.name, node.attrs)
                    + t('<' + node.name) + joinWithText(renderNodes(_.map(node.attrs, insertAssetFunction), scope), '') + t((type == 'OPEN_CLOSE_TAG' ? '/' : '') + '>')
                    + ((selfClosing || selfClosingTags.indexOf(node.name.toLowerCase()) != -1) ? closeTag(node.name) : '');
            case 'CLOSE_TAG':
                return closeTag(node.name, true);

            case 'IF_ATTR':
                return t('__COLLAPSE_WHITESPACE__');
            case 'FOREACH_ATTR':
                return t('__COLLAPSE_WHITESPACE__');


            case 'SELECTED_ATTR':
                return t('{% if ') + renderNode(node.cond, scope) + t(' %} selected="selected" {% endif %}');
            case 'CHECKED_ATTR':
                return t('{% if ') + renderNode(node.cond, scope) + t(' %} checked="checked" {% endif %}');
            case 'DISABLED_ATTR':
                return t('{% if ') + renderNode(node.cond, scope) + t(' %} disabled="disabled" {% endif %}');

            case 'WIDGET_TAG':
                var params = _.filter(node.params, function (p) { return p.type == 'PARAM'; }),
                    clazz  = findParam(params, 'class'),
                    classExp = typeof clazz != 'undefined' ? suppress(function () { return renderParamVal(clazz, scope); }) : null,
                    name   = findParam(params, 'name'),
                    end    = findParam(params, 'end'),
                    template = findParam(params, 'template'),
                    target   = findParam(params, 'target'),
                    isFormWidget = clazz && name && classExp.match(/Form/);

                params = _.without(params, clazz, end, target);

                if (typeof(template) != 'undefined' && typeof(clazz) == 'undefined') {
                    var tplParams = _.without(params, template);

                    return openTag('widget', node.params)

                        + (tplParams.length > 0
                            ? t('{{ widget(') + renderNamedParams(params, scope) + t(') }}')
                            : t('{% include ') + renderParamVal(template, scope) + t(' %}'))

                        + closeTag('widget');

                } else if (typeof(end) != 'undefined') {

                    return t('{% endform %}') + closeTag('widget_form');

                } else if (typeof(name) != 'undefined' && isFormWidget) {

                    return openTag('widget_form', node.params)
                        + t('{% form ') + renderParamVal(clazz, scope) + renderFormParamsExp(_.without(params, name)) + t(' %}');

                } else {
                    return openTag('widget', node.params)
                        + t('{{ widget(') + (typeof(clazz) != 'undefined' ? renderParamVal(clazz, scope) : '')
                        + (typeof(clazz) != 'undefined' && params.length > 0 ? ', ' : '')
                        + renderNamedParams(params, scope) + t(') }}')
                        + closeTag('widget');
                }

                function renderFormParamsExp(params) {
                    return params.length > 0 ? t(' with ') + renderParamHash(params, scope) : t('');
                }

                function renderNamedParams(nodes, scope) {
                    return joinWithText(_.map(nodes, function (node) {
                        return renderParamName(node.name) + t('=') + renderParamVal(node, scope);
                    }), ', ');
                }

            case 'LIST_TAG':
                var params   = _.filter(node.params, function (p) { return p.type == 'PARAM'; }),
                    name     = findParam(params, 'name');

                params = _.without(params, name);

                return openTag('widget_list', node.params)
                    + t('{{ widget_list(') + renderParamVal(name, scope)
                    + (params.length > 0 ? ', ' : '')
                    + renderNamedParams(params, scope) + t(') }}')
                    + closeTag('widget_list');

            case 'PHP_STATIC_MEMBER_ACCESS':
                // TODO: handle (?) function calls

                return node.context == 'static' || node.context == 'self'
                    ? t('constant(\'' + node.member + '\', this)')
                    : t('constant(\'' + node.context + '::' + node.member + '\')');

            default:
                throw new Error('NOT IMPLEMENTED ' + type);
        }

        function openTag(name, nodeAttrs) {
            var ind   = isBlankRow ? currentIndent : null,
                attrs = [],
                txt   = '',
                newVars = [];

            var ifAttr = _.find(nodeAttrs, function (attr) { return attr.type == 'IF_ATTR'; }),
                foreachAttr = _.find(nodeAttrs, function (attr) { return attr.type == 'FOREACH_ATTR'; });

            if (foreachAttr) {
                txt += t('{% for ' + (foreachAttr.key ? foreachAttr.key + ', ' : '') + foreachAttr.value + ' in ')
                    + renderNode(foreachAttr.exp, scope) + t(' %}');

                if (ind != null) {
                    indent();

                    txt += t("\n" + renderIndent(ind));
                }

                attrs.push('for');

                newVars = foreachAttr.key ? [foreachAttr.key, foreachAttr.value] : [foreachAttr.value];
            }

            var newScope = scope.concat(newVars);

            if (ifAttr) {
                txt += t('{% if ') + renderNode(ifAttr.cond, newScope) + t(' %}');

                if (ind != null) {
                    indent();

                    txt += t("\n" + renderIndent(ind));
                }

                attrs.push('if');
            }

            tagStack.push({
                name:     name.toLowerCase(),
                indent:   ind,
                attrs:    attrs,
                vars:     newVars
            });

            return txt;
        }

        function closeTag(name, renderClosingTag) {
            var txt = '', tag;

            name = name.toLowerCase();

            while ((tag = tagStack.pop()) && tag.name != name) {
                close(tag);
            }

            if (renderClosingTag) {
                txt += t('</' + name + '>');
            }

            if (typeof(tag) == 'undefined') {
                //throw new Error('Closing tag does not have a matching opening');
            } else {
                close(tag);
            }

            function close(tag) {
                var hasIf = tag.attrs.indexOf('if') != -1,
                    hasForeach = tag.attrs.indexOf('for') != -1;

                if (hasIf) {
                    if (tag.indent != null) {
                        dedent();
                        txt += t("\n" + renderIndent(tag.indent));
                    }

                    txt += t('{% endif %}');
                }

                if (hasForeach) {
                    if (tag.indent != null) {
                        dedent();
                        txt += t("\n" + renderIndent(tag.indent));
                    }

                    txt += t('{% endfor %}');
                }
            }

            return txt;
        }

        function indent() {
            extraIndent += ts;
        }

        function dedent() {
            extraIndent -= ts;
        }

        function renderIndent(x) {
            return new Array(x + 1).join(' ');
        }

        function t(val) {
            var rows = val.split("\n");

            if (rows.length > 1) {
                var lastRow = rows[rows.length-1];

                currentIndent = lastRow.length;
                isBlankRow = !lastRow.match(/\S/);

                var prefix = rows.shift();

                return prefix + "\n" +
                    _.map(rows, function (row) { return (renderIndent(extraIndent) + row) }).join("\n");
            } else {
                currentIndent += val.length;
                isBlankRow = isBlankRow && !val.match(/\S/);

                return val;
            }
        }

        function suppress(lambda) {
            var _currentIndent = currentIndent,
                _isBlankRow = isBlankRow;

            var result = lambda();

            currentIndent = _currentIndent;
            isBlankRow = _isBlankRow;

            return result;
        }

        function joinWithText(parts, txt) {
            if (parts.length == 0)
                return '';

            return _.reduce(parts, function (acc, v) {
                return acc + t(txt) + v;
            });
        }

        function renderParamHash(nodes, scope) {
            return t('{') + joinWithText(_.map(nodes, function (node) {
                return renderParamName(node.name) + t(': ') + renderParamVal(node, scope);
            }), ', ') + t('}');
        }

        function renderParamName(name) {
            return t(name.match(/^[a-zA-Z0-9_]+$/) ? name : "'" + name + "'");
        }

        function renderParamVal(node, scope) {
            if (typeof node.value == 'undefined') {
                return t("'1'");
            }

            return node.value.length > 0 ? joinWithText(renderNodes(node.value, scope), ' ~ ') : t("''");
        }

        function findParam(params, paramName) {
            return _.find(params, function (p) { return p.name.toLowerCase() == paramName.toLowerCase(); })
        }

        function insertAssetFunction(node) {
            if (node.type == 'TEXT') {
                node = _.clone(node);

                node.value = node.value
                    .replace(/(\s)src="(images[^"]+)"/i, '$1src="{{ asset(\'$2\') }}"')
                    .replace(/(\s)src='(images[^']+)'/i, '$1src="{{ asset(\'$2\') }}"')
                    .replace(/(\s)background="(images[^"]+)"/i, '$1background="{{ asset(\'$2\') }}"')
                    .replace(/(\s)background='(images[^']+)'/i, '$1background="{{ asset(\'$2\') }}"');
            }

            return node;
        }
    }

    function renderNodes(nodes, scope) {
        return _.map(nodes, function (v) { return renderNode(v, scope); });
    }

    function collapseRemovedAttrsWhitespace(text) {
        return text
            .replace(/\s*__COLLAPSE_WHITESPACE__\s*(>|\/)/g, '$1')
            .replace(/\s*__COLLAPSE_WHITESPACE__\s*/g, ' ')
            ;
    }

    function dropVimComment(text) {
        return text.replace(/^\{# vim: set.+?#}\s*/, '');
    }

    function isVarInScope(name, scope, tagStack) {
        return _.contains(scope, name) || _.any(tagStack, function (tag) { return _.contains(tag.vars, name); });
    }

    var res = renderNodes(nodes, []).join('');

    if (tagStack.length > 0) {
        //throw new Error('There are some unclosed tags');
    }

    return dropVimComment(collapseRemovedAttrsWhitespace(res));
};

// Example usage: find test -name '*.tpl' -exec bash -c 'file="{}" ; node flexy-to-twig.js "{}" > ${file%.tpl}.twig' -- {}  \;
// creates .twig equivalents for all flexy .tpl files found recursively in "test" directory
