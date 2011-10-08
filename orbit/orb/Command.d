/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Command;

import tango.util.Convert;

import orbit.orbit.Orbit;

import orbit.core._;
import orbit.orb.Exceptions;
import orbit.orb.Options;
import StdArgs = orbit.orb.util.Arguments;

abstract class Command
{
	string name;
	string summary;

	protected Arguments arguments;
	protected Orbit orbit;
	
	this (string name, string summary = "")
	{
		this.name = name;
		this.summary = summary;
		arguments = Arguments();
		orbit = Orbit.defaultOrbit;

		setupArguments;
	}
	
	void invoke (string[] args ...)
	{
		arguments.originalArgs = args;
		arguments.parse;
		execute;
	}
	
	abstract void execute ();
	
	void printHelp ()
	{
		
	}
	
	protected void setupArguments () {}
}

struct Arguments
{
	private
	{
		StdArgs.Arguments arguments;
		string[] originalArgs;
		string[] args;
	}
	
	static Arguments opCall ()
	{
		Arguments args;
		args.arguments = new StdArgs.Arguments;
		
		return args;
	}
	
	string opIndex (size_t index)
	{
		if (index > args.length - 1 || empty)
			throw new MissingArgumentException("Missing argument(s)", __FILE__, __LINE__);

		return args[index];
	}
	
	void parse ()
	{
		if (!arguments.parse(originalArgs))
			throw new InvalidArgumentException("", __FILE__, __LINE__);

		args = arguments(null).assigned;
	}
	
	Argument opIndex (string name)
	{
		return Argument(arguments[name]);
	}
	
	string first ()
	{
		return opIndex(0);
	}
	
	string last ()
	{
		return opIndex(args.length - 1);
	}
	
	bool empty ()
	{
		return args.length == 0;
	}
	
	bool any ()
	{
		return !empty;
	}
}

struct Argument
{
	private StdArgs.Arguments.Argument argument;
	
	string value ()
	{
		auto value = argument.assigned;
		return value.any() ? value[0] : "";
	}
	
	bool hasValue ()
	{
		return argument.assigned().any();
	}

	T as (T) ()
	{
		return to!(t)(value);
	}
	
	Argument aliased (char name)
	{
		argument.aliased(name);
		return *this;
	}
	
	Argument help (string text)
	{
		argument.help(text);
		return *this;
	}
	
	Argument defaults (string values)
	{
		argument.defaults(values);
		return *this;
	}

    Argument defaults (string delegate () value)
    {
        argument.defaults(value);
        return *this;
    }

    Argument params ()
    {
        argument.params;
        return *this;
    }
    
    Argument params (int count)
    {
        argument.params(count);
        return *this;
    }
    
    Argument params (int min, int max)
    {
        argument.params(min, max);
        return *this;
    }
}