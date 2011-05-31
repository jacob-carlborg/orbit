/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 25, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Builder;

import tango.util.compress.Zip;

import orbit.core._;
import orbit.dsl.Specification;
import orbit.orbit.Exceptions;

class Builder
{
	const string path;
	const Specification spec;
	
	private ZipBlockWriter writer;
	
	this (Specification specification, string path)
	{
		spec = specification;
		this.path = path;
	}
	
	void build ()
	{
		writer = new ZipBlockWriter(path);
		writer.method = Method.Deflate;
		
		foreach (file ; spec.files)
			addFileToArchive(file);
		
		writer.finish;
	}
	
private:
	
	void addFileToArchive (string path)
	{
		writer.putFile(ZipEntryInfo("test.orbspec"), path);
	}
}

class BuildException : OrbitException
{
	this (string msg, string file = "", long line = 0)
	{
		super(msg, file, line);
	}
}