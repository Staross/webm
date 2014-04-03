const htmlEntities = 
{
"&nbsp;" =>	" "		,	#Space
"&#32;"	 =>	" "		,	#Space
"&#33;"	 =>	"!"		,	#Exclamation mark
"&#34;"	 =>	"\""	,	#Quotation mark
"&#35;"	 =>	"#"		,	#Number sign
"&#36;"	 =>	"\$"	,	#Dollar sign
"&#37;"	 =>	"%"		,	#Percent sign
"&amp;"	 =>	"&"		,	#Ampersand
"&#38;"	 =>	"&"		,	#Ampersand
"&#39;"	 =>	"'"		,	#Apostrophe
"&#40;"	 =>	"("		,	#Opening/Left Parenthesis
"&#41;"	 =>	")"		,	#Closing/Right Parenthesis
"&#42;"	 =>	"*"		,	#Asterisk
"&#43;"	 =>	"+"		,	#Plus sign
"&#44;"	 =>	","		,	#Comma
"&#45;"	 =>	"-"		,	#Hyphen
"&#46;"	 =>	"."		,	#Period
"&#47;"	 =>	"/"		,	#Slash
"&#48;"	 =>	"0"		,	#Digit 0
"&#49;"	 =>	"1"		,	#Digit 1
"&#50;"	 =>	"2"		,	#Digit 2
"&#51;"	 =>	"3"		,	#Digit 3
"&#52;"	 =>	"4"		,	#Digit 4
"&#53;"	 =>	"5"		,	#Digit 5
"&#54;"	 =>	"6"		,	#Digit 6
"&#55;"	 =>	"7"		,	#Digit 7
"&#56;"	 =>	"8"		,	#Digit 8
"&#57;"	 =>	"9"		,	#Digit 9
"&#58;"	 =>	":"		,	#Colon
"&#59;"	 =>	";"		,	#Semicolon
"&lt;"	 =>	"<"		,	#Less-than
"&#60;"	 =>	"<"		,	#Less-than
"&#61;"	 =>	"="		,	#Equals sign
"&gt;"	 =>	">"		,	#Greater than
"&#62;"	 =>	">"		,	#Greater than
"&#63;"	 =>	"?"		,	#Question mark
"&#64;"	 =>	"@"		,	#At sign
"&#65;"	 =>	"A"		,	#Uppercase A
"&#66;"	 =>	"B"		,	#Uppercase B
"&#67;"	 =>	"C"		,	#Uppercase C
"&#68;"	 =>	"D"		,	#Uppercase D
"&#69;"	 =>	"E"		,	#Uppercase E
"&#70;"	 =>	"F"		,	#Uppercase F
"&#71;"	 =>	"G"		,	#Uppercase G
"&#72;"	 =>	"H"		,	#Uppercase H
"&#73;"	 =>	"I"		,	#Uppercase I
"&#74;"	 =>	"J"		,	#Uppercase J
"&#75;"	 =>	"K"		,	#Uppercase K
"&#76;"	 =>	"L"		,	#Uppercase L
"&#77;"	 =>	"M"		,	#Uppercase M
"&#78;"	 =>	"N"		,	#Uppercase N
"&#79;"	 =>	"O"		,	#Uppercase O
"&#80;"	 =>	"P"		,	#Uppercase P
"&#81;"	 =>	"Q"		,	#Uppercase Q
"&#82;"	 =>	"R"		,	#Uppercase R
"&#83;"	 =>	"S"		,	#Uppercase S
"&#84;"	 =>	"T"		,	#Uppercase T
"&#85;"	 =>	"U"		,	#Uppercase U
"&#86;"	 =>	"V"		,	#Uppercase V
"&#87;"	 =>	"W"		,	#Uppercase W
"&#88;"	 =>	"X"		,	#Uppercase X
"&#89;"	 =>	"Y"		,	#Uppercase Y
"&#90;"	 =>	"Z"		,	#Uppercase Z
"&#91;"	 =>	"["		,	#Opening/Left square bracket
"&#92;"	 =>	"\\"	,	#Backslash
"&#93;"	 =>	"]"		,	#Closing/Right square bracket
"&#94;"	 =>	"^"		,	#Caret
"&#95;"	 =>	"_"		,	#Underscore
"&#96;"	 =>	"`"		,	#Grave accent
"&#97;"	 =>	"a"		,	#Lowercase a
"&#98;"	 =>	"b"		,	#Lowercase b
"&#99;"	 =>	"c"		,	#Lowercase c
"&#100;" =>	"d"		,	#Lowercase d
"&#101;" =>	"e"		,	#Lowercase e
"&#102;" =>	"f"		,	#Lowercase f
"&#103;" =>	"g"		,	#Lowercase g
"&#104;" =>	"h"		,	#Lowercase h
"&#105;" =>	"i"		,	#Lowercase i
"&#106;" =>	"j"		,	#Lowercase j
"&#107;" =>	"k"		,	#Lowercase k
"&#108;" =>	"l"		,	#Lowercase l
"&#109;" =>	"m"		,	#Lowercase m
"&#110;" =>	"n"		,	#Lowercase n
"&#111;" =>	"o"		,	#Lowercase o
"&#112;" =>	"p"		,	#Lowercase p
"&#113;" =>	"q"		,	#Lowercase q
"&#114;" =>	"r"		,	#Lowercase r
"&#115;" =>	"s"		,	#Lowercase s
"&#116;" =>	"t"		,	#Lowercase t
"&#117;" =>	"u"		,	#Lowercase u
"&#118;" =>	"v"		,	#Lowercase v
"&#119;" =>	"w"		,	#Lowercase w
"&#120;" =>	"x"		,	#Lowercase x
"&#121;" =>	"y"		,	#Lowercase y
"&#122;" =>	"z"		,	#Lowercase z
"&#123;" =>	"{"		,	#Opening/Left curly brace
"&#124;" =>	"|"		,	#Vertical bar
"&#125;" =>	"}"		,	#Closing/Right curly brace
"&#126;" =>	"~"			#Tilde
}

function removeHTMLEntities(s::String)

	for (k,v) in htmlEntities
		s = replace(s,Regex("$k","is"),v)
	end 
	return s
end