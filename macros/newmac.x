/* newmac -- Name a new macro and load it into editor. */
macrodir=value('X2HOME',,'ENVIRONMENT')||'\macros\'
fn=macrodir||arg(1)||'.x'
'X' fn
'CURSOR DATA'
'KEYIN mac' arg(1)                    /* enter keyword expansion string      */
'KEYIN' " "                            /* enter space to expand               */
exit
