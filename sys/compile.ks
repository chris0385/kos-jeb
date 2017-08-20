//"
@lazyglobal off.

runoncepath("sys/fileutils.ks").

parameter task is "-".
parameter p1 is "-".
parameter p2 is "-".
parameter p3 is "-".

global DOUBLE_QUOTE is 0.
for line in open("sys/compile.ks"):readall() {
	set DOUBLE_QUOTE to line:substring(2,1).
	break.
}


function parseImport {
	parameter line.
	print "parseImport/"+line.
	local start is line:find(DOUBLE_QUOTE).
	local end is line:findat(DOUBLE_QUOTE, start+1).
	local fname is line:substring(start+1, end-start-1).
	return fname.
}

function preprocessor {
// https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
	// (case insensitive) @begin-comment
	if line:MATCHESPATTERN("^[ \t]*//[ \t]*@(?i)@begin-comment[ \t]*$") {
	
	}
	// (case insensitive) @end-comment
	if line:MATCHESPATTERN("^[ \t]*//[ \t]*@(?i)@end-comment[ \t]*$") {
	
	}
	// (case insensitive) @unittest
}

function import {
	parameter path.
	//"0:/bin/"
	parameter targetDevice is "1:/".
	parameter done is list().
	
	local target is targetDevice+path+".ksm".
	if path:endswith(".ks") {
		set target to targetDevice+path:substring(0, path:length-3)+".ksm".
	}
	print "Importing "+path +" to "+target.
	if exists(target) {
		DELETEPATH(target).
	}
	createParentDir(target).
	// TODO: fails when no space left. USE volume(1):freespace.
	compile path to target.
	
	done:add(path).
	local fileD is open(path).
	
	//print fileD:typename.
	if fileD:typename = "Boolean" {
		print "ERROR:"+ fileD.
	}
	for line in fileD:readall {
		local pos is max(max(line:find("runoncepath"), line:find("runpath")), max(line:find("run "), line:find("run once"))).
		if pos>=0 {
			local comment is line:find("//").
			if comment>=0 and comment < pos {
				//print "skip "+line.
			} else {
				local imported is parseImport(line).
				print pos+line+"##"+imported.
				if not done:contains(imported) {
					import(imported, targetDevice, done).
				}
			}
		}
	}
}

/// Parses a .cfg file (KSP format) and stores it into a lexicon()
function parsePartConfig {
	parameter filename.
	local stk is stack().
	local map is { 
		local l is lexicon(). 
		set l["attr"] to lexicon(). 
		return l.
	}.
	stk:push(lexicon()).
	local top is stk:peek().
	local root is top.
	local hdl is open(filename).
	local lineId is 0.
	for line in hdl:readall {
		set lineId to lineId+1.
		local stripped is line:trim().
		local commentPos is stripped:find("//").
		if commentPos >=0 {
			set stripped to stripped:substring(0,commentPos):trim().
		}
		if stripped="{" or stripped="" {
			// skip
		} else if stripped="}" {
			stk:pop().
			if stk:length = 0 {
				break.
			}
			set top to stk:peek().
		} else if stripped:MATCHESPATTERN("^(?i)[a-z_0-9]*$") {
			local sub is map().
			if top:haskey(stripped) {
				if top[stripped]:typename <> "List" {
					print "ERROR(@"+lineId+"): expected list for key "+stripped+", was "+top[stripped]:typename.
					print " value:"+top[stripped].
				}
				top[stripped]:add(sub).
			} else {
				set top[stripped] to list(sub).
			}
			stk:push(sub).
			set top to sub.
		} else if stripped:MATCHESPATTERN("^(?i)[a-z_0-9]*[\t ]*=[\t ]*") {
			local splitted is stripped:split("=").
			local value is splitted[1]:trim().
			if value:MATCHESPATTERN("^([+-]?[0-9]{1,9}|[0-9]+\.[0-9]+)$") {
				// Note: we don't parse int number that don't fit in 32 bits.
				set value to value:TONUMBER().
			} else if value = "true" {
				set value to true.
			} else if value = "false" {
				set value to false.
			}
			local name is splitted[0]:trim().
			if top["attr"]:haskey(name) {
				local oVal is top["attr"][name].
				if oVal:typename <> "List" {
					set oVal to list(oVal).
					set top["attr"][name] to oVal.
				}
				oVal:add(value).
			} else {
				set top["attr"][name] to value.
			}
			//print top["attr"].
		} else {
			print "ERROR: unhandled " + stripped+ "("+line+")".
		}
	}
	if root:length > 1 {
		print "Not expected: more than one element at top level".
		err.
	}
	for x in root:values() {
		if x:length > 1 {
			print "Not expected: more than one element at top level list".
			err.
		}
		return x[0].
	}
}

function lexiconToSource {
	parameter lexName.
	parameter lex.
	parameter fileName.
	log "set "+lexName+" to lexicon()." to fileName.
	function escapeString {
		parameter value.
		return DOUBLE_QUOTE+value:replace(DOUBLE_QUOTE,DOUBLE_QUOTE+"+DOUBLE_QUOTE+"+DOUBLE_QUOTE)+DOUBLE_QUOTE.
	}
	for k in lex:keys {
		local value is lex[k].
		local typ is value:typename.
		if typ = "String" {
			set value to escapeString(value).
		}
		if typ = "List" or typ = "Stack" {
		err.
			local nam is lexName+"["+DOUBLE_QUOTE+k+DOUBLE_QUOTE+"]".
			log "set "+nam+" to "+typ+"()." to fileName.
			for v in value {
				log nam+":add()" to fileName.
			}
		} else if typ = "Lexicon" {
			local nam is lexName+"["+DOUBLE_QUOTE+k+DOUBLE_QUOTE+"]".
			//log "set "+nam+" to lexicon()." to fileName.
			lexiconToSource(nam,value,fileName).
		} else {
			log "set "+lexName+"["+DOUBLE_QUOTE+k+DOUBLE_QUOTE+"] to "+value+"." to fileName.
		}
	}
}


if task = "import" {
	if p2 = "-" {
		import(p1).
	} else {
		import(p1, p2).
	}
}

//import("tmp.ks").
// runpath("sys/compile.ks", "import", "pilot/suicide_burn3.ks").