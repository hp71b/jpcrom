# AWK script to process JPCRom directives

BEGIN	{
	    
	    # bs = backslash for LaTeX macros: we use a different
	    # character (\001) since \ is used by the original pf
	    # formatter.  We will convert back this \001 character
	    # to \ in another script at the end of the processing.
	    bs = "\001"		# char code 1 => \
	    bb = "\002"		# char code 2 => {
	    be = "\003"		# char code 3 => }

	    if (debug) {
		bs = "\\"
		bb = "{"
		be = "}"
	    }
	}

END		{ newstate("") }

/^\.language/	{ newstate("lang") ; next }
/^\.keyword/	{ newstate("kw") ; next }
/^\.purpose/	{ newstate("purp") ; next }
/^\.options/	{ newstate("opt") ; next }
/^\.syntaxe/	{ newstate("synt") ; next }
/^\.example$/	{ newstate("ex") ; next }
/^\.examples/	{ newstate("ex") ; next }
/^\.ex$/	{ newstate("ex-ex") ; next }
/^\.co$/	{ newstate("ex-co") ; next }
/^\.input/	{ newstate("input") ; next }
/^\.it$/	{ newstate("inp-it") ; next }
/^\.de$/	{ newstate("inp-de") ; next }
/^\.re$/	{ newstate("inp-re") ; next }
/^\.df$/	{ newstate("inp-df") ; next }
/^\.operation/	{ newstate("op") ; next }
/^\.related/	{ newstate("rel") ; next }
/^\.references/	{ newstate("refs") ; next }
/^\.reference$/	{ newstate("ref") ; next }
/^\.author/	{ newstate("author") ; next }
/^\.end keyword/ { newstate("endkw") ; next }
/^\.end$/	{ newstate("") ; next }
/^\.graph/	{ newstate("ignore") ; next }

/^\.[a-z]/	{ printf "Invalid directive '%s'\n", $0 > "/dev/stderr" ; next }

	        {
		    # line processing outside any directive
		    switch (e) {
			case "lang" :
			    newstate("")
			    if ($0 == "F")
				l = "fr"
			    else if ($0 == "A")
				l = "en"
			    else printf "%d: invalid language\n", NR > "/dev/stderr"
			    latex_0("jlang" l)
			    break
			case "kw" :
			    newstate("")
			    if ($0 != "")
				latex_1("jkeyword", $0)
			    break
			case "purp" :
			    if ($0 != "")
				print
			    break
			case "opt" :
			    newstate("")
			    delete ts
			    delete t
			    split ($0, ts, "")
			    for (i in ts)
				t[ts[i]]="x"
			    jopt(t["S"],t["F"],t["K"],t["C"],t["I"],t["D"])
			    break
			case "synt" :
			    if ($0 != "")
				printf "%ctt{}%s\n", bs, $0
			    break
			case "ex" :
			    printf "%d: invalid line in .example\n", NR > "/dev/stderr"
			    break
			case "ex-ex" :
			    texex[idxex] = addcurline(texex[idxex])
			    break
			case "ex-co" :
			    if ($0 == "")
				newstate("exlast")
			    else
				texco[idxex] = addcurline(texco[idxex])
			    break

			case "input" :
			    printf "%d: invalid line in .input\n", NR > "/dev/stderr"
			    break
			case "inp-it" :
			    tinpit[idxinp] = addcurline(tinpit[idxinp])
			    break
			case "inp-de" :
			    if ($0 == "")
				newstate("inplast")
			    else
				tinpde[idxinp] = addcurline(tinpde[idxinp])
			    break
			case "inp-re" :
			    if ($0 == "")
				newstate("inplast")
			    else
				tinpre[idxinp] = addcurline(tinpre[idxinp])
			    break
			case "inp-df" :
			    if ($0 == "")
				newstate("inplast")
			    else
				tinpdf[idxinp] = addcurline(tinpdf[idxinp])
			    break
			case "op" :
			    print
			    break
			case "rel" :
			    if ($0 != "")
				trel [idxrel++] = $0
			    break
			case "ref" :
			case "refs" :
			    print
			    break
			case "author" :
			    taut [idxaut++] = $0
			    break
			default :
		    }
		}

function newstate(new) {
    # printf "OLD = %s, NEW = %s\n", e, new	# DEBUG
    ############# end old state
    switch (e) {
	case "purpose" :
	    latex_end("jpurpose")
	    break
	case "synt" :
	    latex_end("jsyntax")
	    break
	case "exlast" :
	    if (idxex > 1)
		latex_begin_arg("jexample", "s")
	    else
		latex_begin_arg("jexample", "")
	    for (i = 0 ; i < idxex ; i++) {
		latex_begin("jexex")
		print texex[i]
		latex_end("jexex")
		latex_begin("jexco")
		print texco[i]
		latex_end("jexco")
	    }
	    latex_end("jexample")
	    break
	case "ex-co" :
	    idxex++
	    break
	case "inplast" :
	    if (idxinp > 1)
		latex_begin_arg("jinput", "s")
	    else
		latex_begin_arg("jinput", "")
	    for (i = 1 ; i <= idxinp ; i++) {
		if (i == 1) {
		    rule = "first"
		} else if (i == idxinp) {
		    rule = "last"
		} else {
		    rule = ""
		}

		latex_5("jinputitem", \
			tinpit[i], tinpde[i], tinpre[i], tinpdf[i], rule)
	    }
	    latex_end("jinput")
	    break
	case "rel" :
	    latex_0("jrelated")
	    for (i = 0 ; i < idxrel ; i++)
	    {
		if (i == idxrel - 1)
		    comma = ""
		else comma = ","
		printf "%s%s\n", trel [i], comma
	    }
	    break
	case "author" :
	    latex_0("jauthor")
	    for (i = 0 ; i < idxaut ; i++)
	    {
		if (i == idxaut - 1)
		    comma = ""
		else comma = ","
		printf "%s%s\n", taut [i], comma
	    }
	    break
    }
    ############# start new state
    e = new
    switch (e) {
	case "purpose" :
	    latex_begin("jpurpose")
	    break
	case "synt" :
	    latex_begin("jsyntax")
	case "ex" :
	    delete texex
	    delete texco
	    idxex = 0
	    break
	case "input" :
	    idxinp = 0
	    delete tinpit
	    delete tinpde
	    delete tinpre
	    delete tinpdf
	    break
	case "inp-it" :
	    idxinp++		# index 1 is the first input
	    break
	case "op" :
	    latex_0("joperation")
	    break
	case "rel" :
	    delete trel
	    idxrel = 0
	    break
	case "refs" :
	    latex_0("jreferences")
	    break ;
	case "ref" :
	    latex_0("jreference")
	    break ;
	case "author" :
	    delete taut
	    idxaut = 0
	    break ;
	case "endkw" :
	    latex_0("jendkeyword")
    }
}

# return var with new line $0 added
function addcurline (var) {
    return addline(var, $0)
}

function addline (var, line,              n) {
    n = ""
    if (var != "")
	n = "\n"
    return var n line
}

function latex_begin (env) {
    latex_1("begin", env)
}

function latex_begin_arg (env, arg) {
    latex_2("begin", env, arg)
}

function latex_end(env) {
    latex_1("end", env)
}

function latex_0(kw) {
    printf "%s%s\n", bs, kw
}

function latex_1(kw, arg) {
    printf "%s%s%s%s%s", bs, kw, bb, arg, be
}

function latex_2(kw, a1, a2) {
    printf "%s%s%s%s%s%s%s%s", bs, kw, bb, a1, be, bb, a2, be
}

function latex_3(kw, a1, a2, a3) {
    printf "%s%s %s%s%s %s%s%s %s%s%s\n", bs, kw \
		    , bb, a1, be \
		    , bb, a2, be \
		    , bb, a3, be
}

function latex_4(kw, a1, a2, a3, a4) {
    printf "%s%s %s%s%s %s%s%s %s%s%s %s%s%s\n", bs, kw \
		    , bb, a1, be \
		    , bb, a2, be \
		    , bb, a3, be \
		    , bb, a4, be
}

function latex_5(kw, a1, a2, a3, a4, a5) {
    printf "%s%s %s%s%s %s%s%s %s%s%s %s%s%s %s%s%s\n", bs, kw \
		    , bb, a1, be \
		    , bb, a2, be \
		    , bb, a3, be \
		    , bb, a4, be \
		    , bb, a5, be
}

function latex_6(kw, a1, a2, a3, a4, a5, a6) {
    printf "%s%s %s%s%s %s%s%s %s%s%s %s%s%s %s%s%s %s%s%s\n", bs, kw \
		    , bb, a1, be \
		    , bb, a2, be \
		    , bb, a3, be \
		    , bb, a4, be \
		    , bb, a5, be \
		    , bb, a6, be
}

function jopt(s, f, k, c, i, d) {
    # \jopt {statement} {function} {keyboard} {calc} {ifthenelse} {device}
    latex_6("jopt", s, f, k, c, i, d)
}
