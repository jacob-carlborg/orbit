/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jul 10, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.io.File;

import Std = std.stdio;

struct File
{
	enum Mode
	{
		readExisting,
		writeCreate,
		appendCreate,
		readWriteExisting,
		readWriteCreate,
		readAppendCreate
	}
	
	enum Binary
	{
		yes,
		no
	}
	
	private
	{
		Std.File file;
		Mode mode_;
		Binary binary;
	}
	
	this (string path, Mode mode = Mode.readExisting, Binary binary = Binary.yes)
	{
		mode_ = mode;
		this.binary = binary;
		file = Std.File(path, convertMode);
	}
	
	static void set (T) (string path, T[] content)
	{
		File(path, Mode.writeCreate).write(content);
	}
	
	static T[] get (T) (string path, T[] buffer = null)
	{
		File(path).read(buffer);
	}
	
	@property const Mode mode ()
	{
		return mode_;
	}
	
	@property const Binary isBinary ()
	{
		binary;
	}
	
	@property const size_t length ()
	{
		return cast(size_t) file.size;
	}
	
	@property const ulong size ()
	{
		return file.size;
	}
	
	T[] read (T) (T[] buffer = null)
	{
		if (length > buffer.length)
			buffer.length = length;
		
		return file.rawRead(buffer);
	}
	
	void write (T) (in T[] data)
	{
		file.rawWrite(data);
	}
	
private:
	
	const string convertMode ()
	{
		string mode;
		
		with (Mode)
		{
			case readExisting: mode = "r"; break;
			case writeCreate: mode = "w"; break;
			case appendCreate: mode = "a"; break;
			case readWriteExisting: mode = "r+"; break;
			case readWriteCreate: mode = "w+"; break;
			case readAppendCreate: mode = "a+"; break;
		}
		
		return mode ~ binaryToString;
	}
	
	const string binaryToString ()
	{
		return isBinary ? "b" : "";
	}
}