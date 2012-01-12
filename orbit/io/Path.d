/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 16, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.io.Path;

import std.conv;

import tango.core.Exception;
public import tango.io.Path;
import tango.stdc.posix.sys.stat;
import tango.sys.Common;
import tango.sys.Environment;

import orbit.core._;

alias Environment.toAbsolute toAbsolute;
alias Environment.cwd workingDirectory;

bool isSymlink (string path)
{
	version (Windows)
		return false;
		
	else
	{
		stat_t buffer;
		int status;

		if (lstat(path.ptr, &buffer) == -1)
			return false;

		return S_ISLNK(buffer.st_mode);
	}
}

int remove (string path, bool recursive = false)
{
	alias tango.io.Path.remove removePath;
	
	if (!recursive)
		return removePath(path) ? 1 : 0;
	
	int result;
		
	foreach (info ; children(path))
	{
		string fullPath = cast(string)(info.path ~ info.name);
		
		if (isSymlink(fullPath))
			continue;
		
		if (info.folder)
			result += remove(fullPath, true);
			
		else
			result += removePath(fullPath) ? 1 : 0;
	}

	return removePath(path) ? result + 1 : result;
}

void moveForce (string source, string destination)
{	
	if (exists(destination))
		remove(destination, true);

	bool createParentOnly = false;

	if (isFile(source))
		createParentOnly = true;
	
	version (Windows)
		createParentOnly = true;
	
	if (createParentOnly)
		createPath(parse(cast(char[])destination).path);

	else
		createPath(destination);

	rename(source, destination);
}

void validatePath (string path)
{
	if (!exists(path))
		throw new tango.io.Path.IOException("File not found \"" ~ path ~ "\"");
}

string setExtension (string path, string extension)
{
	return parse(cast(char[])path).ext != extension ? path ~ "." ~ extension : path;
}

string join (string[] paths ...)
{
	if (paths.length == 0)
		return "";
	
	string result;
	result ~= FS.stripped(paths[0]);
	
	foreach (path ; paths[1 .. $ - 1])
		result ~= FS.paddedLeading(FS.stripped(path));
	
	result ~= FS.paddedLeading(paths[$ - 1]);
	
	return result;
}

version (Posix):

void permission (string path, string mode)
{
	ushort m = permission(path);

	bool owner;
	bool group;
	bool others;
	bool all = true;
	
	bool add;
	bool remove;
	bool assign;
	
	bool read;
	bool write;
	bool execute;
	
	foreach (c ; mode)
	{
		switch (c)
		{
			case 'u': 
				owner = true;
				all = false;
			continue;
			
			case 'g':
				group = true;
				all = false;
			continue;
			
			case 'o':
				others = true;
				all = false;
			continue;
			
			case 'a': all = true; continue;
			
			case 'r': read = true; continue;
			case 'w': write = true; continue;
			case 'x': execute = true; continue;
			
			case '+': add = true; continue;
			case '-': remove = true; continue;
			case '=': assign = true; continue;
			
			default: continue;
		}
	}
	
	if (owner) mixin(permissions!(Owner));
	if (group) mixin(permissions!(Group));
	if (others) mixin(permissions!(Others));
	
	if (all)
	{
		mixin(permissions!(Owner));
		mixin(permissions!(Group));
		mixin(permissions!(Others));
	}

	permission(path, m);
}

enum Owner
{
	Read = S_IRUSR,
	Write = S_IWUSR,
	Execute = S_IXUSR,
	All = S_IRWXU
}

enum Group
{
	Read = S_IRGRP,
	Write = S_IWGRP,
	Execute = S_IXGRP,
	All = S_IRWXG
}

enum Others
{
	Read = S_IROTH,
	Write = S_IWOTH,
	Execute = S_IXOTH,
	All = S_IRWXO
}

void permission (string path, ushort mode)
{
	if (chmod((path ~ '\0').ptr, mode) == -1)
		throw new tango.io.Path.IOException(cast(string)(path ~ ": " ~ SysError.lastMsg));
}

private template permissions (alias reference)
{
	const permissions = "if (add)
	{
		if (read) m |= " ~ reference.stringof ~ ".Read;
		if (write) m |= " ~ reference.stringof ~ ".Write;
		if (execute) m |= " ~ reference.stringof ~ ".Execute;
	}

	else if (remove)
	{
		if (read) m &= ~" ~ reference.stringof ~ ".Read;
		if (write) m &= ~" ~ reference.stringof ~ ".Write;
		if (execute) m &= ~" ~ reference.stringof ~ ".Execute;
	}

	else if (assign)
	{
		m = 0;

		if (read) m |= " ~ reference.stringof ~ ".Read;
		if (write) m |= " ~ reference.stringof ~ ".Write;
		if (execute) m |= " ~ reference.stringof ~ ".Execute;
	}";
}

private ushort permission (string path)
{
	int status;
	stat_t buffer;
	
	if (stat((path ~ '\0').ptr, &buffer) == -1)	
		throw new tango.io.Path.IOException(cast(string)(path ~ ": " ~ SysError.lastMsg));
	
	return buffer.st_mode & std.conv.octal!777;
}
