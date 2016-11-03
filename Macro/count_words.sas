/*=====================================================================
Program Name            : count_words.sas
Purpose                 : Returns the number of words delimited by a
                          delimiter or set of delimiters.
SAS Version             : SAS 9.1.3
Input Data              : None
Output Data             : None

Macros Called           : parmv

Originally Written by   : Scott Bass
Date                    : 16APR2011
Program Version #       : 1.0

=======================================================================

Copyright (c) 2016 Scott Bass

https://github.com/scottbass/SAS/tree/master/Macro

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=======================================================================

Modification History    : Original version

=====================================================================*/

/*---------------------------------------------------------------------
Usage:

* Macro Context ;

* default delimiter is a space ;
%put %count_words(foo bar blah);

* specified delimiter ;
%put %count_words(foo ~  bar   ~ blah ~ blech,dlm=~);

* mixed delimiters in a string is ok, just specify multiple delimiters (a space is also allowed) ;
%put %count_words(foo ~  bar   # blah ^ blech xxx,dlm=%str( ~#^));

* should return zero ;
%let foo=;
%put %count_words(&foo);
%put %count_words();

* assign to another macro variable ;
%let foo=%count_words(x y z);
%put *%count_words(x y z)*;
%put *%eval(%count_words(x y z)+2)*;
%put *&foo*;

* Datastep Context ;
data source;
   length string $100;
   infile datalines dsd;
   input string & $char100.;
   datalines;
FOO BAR  BLAH
FOO~BAR ~ BLAH  ~   BLECH
FOO~BAR # BLAH  ^   BLECH XXX
FOO~ ~BAR~ ~BLECH
FOO~~BAR~   ~BLECH
FOO

;
run;

* word count is returned in the hard coded variable _word_count_ (macro default) ;
data word_count;
   set source;
   %count_words(string,dlm=%str( ~^#),context=datastep);
run;

proc print;
run;

-----------------------------------------------------------------------

Notes:

---------------------------------------------------------------------*/

%macro count_words
/*---------------------------------------------------------------------
Returns the number of words delimited by a delimiter or set of
delimiters.
---------------------------------------------------------------------*/
(LIST          /* Input list (Opt).  If blank then zero is returned. */
,VAR=_word_count_
               /* Output variable name for datastep context (Opt).   */
               /* Only required when context=DATASTEP, otherwise it  */
               /* is ignored.                                        */
,DLM=%str( )   /* Delimiter (or delimiters) that define a "word"     */
               /* (REQ).  Default is a blank.                        */
,CONTEXT=MACRO /* Context in which this macro is called (REQ).       */
               /* Default is MACRO.                                  */
               /* Valid values are MACRO and DATASTEP.               */
);

%local macro parmerr;
%let macro = &sysmacroname;

%* check input parameters ;
%parmv(LIST,         _req=0,_words=1,_case=N)
%parmv(CONTEXT,      _req=1,_words=0,_case=U,_val=MACRO DATASTEP)

%if (&parmerr) %then %goto quit;

%* additional error checking ;
%* if context=DATASTEP then VAR is required ;
%if (&context eq DATASTEP) %then %do;
%parmv(VAR,          _req=1,_words=0,_case=N)
%end;

%if (&parmerr) %then %goto quit;

%if (&context eq MACRO) %then %do;
   %local _word_count;
   %let _word_count=1;
   %do %until (%qscan(%superq(list),&_word_count,&dlm) eq );
      %let _word_count=%eval(&_word_count+1);
   %end;
   %let _word_count=%eval((&_word_count-1)-(%superq(list) eq ));
%quote(&_word_count)
%end;
%else
%if (&context eq DATASTEP) %then %do;
   &var=1;
   do until(missing(scan(&list,&var,"&dlm")));
      &var+1;
   end;
   &var=((&var-1)-(missing(&list)));
%end;

%quit:
%* if (&parmerr) %then %abort;

%mend;

/******* END OF FILE *******/
