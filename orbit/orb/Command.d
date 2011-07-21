/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Command;

import orbit.core._;

import orbit.orb.Exceptions;
import orbit.orb.Options;

abstract class Command
{
	string name;
	string summary;
	
	protected Args args;
	protected Options options;
	
	this () {}
	
	this (string name, string summary = "")
	{
		this.name = name;
		this.summary = summary;
		options = Options.instance;
	}
	
	abstract void execute ();
	
	void invoke (string[] args ...)
	{
		this.args.args = args;
		execute;
	}
	
	void invoke (Args args)
	{
		this.args = args;
		execute;
	}
}

private struct Args
{
	string[] args;
	
	string opIndex (size_t index)
	{
		if (index > args.length - 1 && empty)
			throw new MissingArgumentException("Missing argument(s)", __FILE__, __LINE__);

		return args[index];
	}
	
	string first ()
	{
		return opIndex(0);
	}
	
	string last ()
	{
		return opIndex(args.length - 1);
	}
	
	string empty ()
	{
		return args.length == 0;
	}
	
	string any ()
	{
		return !empty;
	}
}