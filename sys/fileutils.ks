
@lazyglobal off.

function dirname {
	parameter path.
	local lastSlash is path:lastindexof("/").
	if lastSlash <=2 {
		return "".
	}
	return path:substring(0,lastSlash).
}

function basename {
	parameter path.
	local lastSlash is path:lastindexof("/").
	if lastSlash <=2 {
		return "".
	}
	return path:substring(lastSlash+1,path:length-lastSlash-1).
}

function createParentDir {
	parameter path.
	local dir is dirname(path).
	//print dir.
	if not EXISTS(dir) {
		createParentDir(dir).
		CREATEDIR(dir).
	}
}

function walkFiles {
	parameter dir.
	parameter callback.
	parameter hdl is dir.
	if hdl:typename = "String" {
		set hdl to open(dir).
	}
	if hdl:isfile {
		callback(dir).
	} else {
		for i in hdl:list():values {
			//print i:typename.
			walkFiles(dir+"/"+i:name, callback,i).
		}
	}
}