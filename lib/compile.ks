//"
@lazyglobal off.

local DOUBLE_QUOTE is 0.
for line in open("lib/compile.ks"):readall() {
	set DOUBLE_QUOTE to line:substring(2,1).
	break.
}


function parseImport {
	parameter line.
	local start is line:find(DOUBLE_QUOTE).
	local end is line:findat(DOUBLE_QUOTE, start+1).
	local fname is line:substring(start+1, end-start-1).
	return fname.
}

function createParentDir {
	parameter path.
	local lastSlash is path:lastindexof("/").
	if lastSlash <=2 {
		return.
	}
	local dir is path:substring(0,lastSlash).
	//print dir.
	if not EXISTS(dir) {
		createParentDir(dir).
		CREATEDIR(dir).
	}
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
	
	print fileD:typename.
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
				//print pos+line+"##"+imported.
				if not done:contains(imported) {
					import(imported, targetDevice, done).
				}
			}
		}
	}
}

//import("tmp.ks").
// runpath("lib/compile.ks").