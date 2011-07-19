/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Builder;

import tango.sys.Process;
import tango.io.Stdout;

import orbit.core._;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;
import Path = orbit.io.Path;

abstract class Builder : OrbitObject
{
	enum Tool
	{
		dake,
		cmake,
		dsss,
		make,
		rdmd,
		shell,
	}
	
	string workingDirectory;
	
	mixin Constructors;
	
	static Builder newBuilder (Orbit orbit, Orb orb)
	{		
		switch (orb.buildTool)
		{
			case Tool.dake: return new Dake(orbit, orb);
			case Tool.cmake: return new Cmake(orbit, orb);
			case Tool.dsss: return new Dsss(orbit, orb);
			case Tool.make: return new Make(orbit, orb);
			case Tool.rdmd: return new Rdmd(orbit, orb);
			case Tool.shell: return new Shell(orbit, orb);
		}
	}
	
	static Builder newBuilder (Orb orb)
	{
		return newBuilder(Orbit.defaultOrbit, orb);
	}
	
	abstract void build ();
	
	protected void execute (string command, string[] args ...)
	{
		execute(command ~ args);
	}
	
	protected void execute (string[] args ...)
	{
		verbose("Working directory: ", workingDirectory);
		verbose("Executing command: ");
		verbose(args);

		auto cleanedArgs = cleanArgs(args);
		auto process = new Process(true, cleanedArgs); // copy the environment 
		process.workDir = workingDirectory;

		process.execute;		
		auto result = process.wait;

		if (orbit.isVerbose || result.reason != Process.Result.Exit)
		{
			verbose("Output of the build process:", "\n");
			Stdout.copy(process.stdout).flush;
			// verbose();
			// verbose("Process ", process.programName, '(', process.pid, ')', " exited with:");
			// verbose("reason: ", result.toString);
			// verbose("status: ", result.status, "\n");
			verbose(result.toString);
		}
	}
	
	private string[] cleanArgs (string[] args)
	{
		if (args.any() && args[0].empty())
			return args[0 .. $ - 1];

		return args;
	}
}

class Dake : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}

	void build ()
	{
		execute("dake", orb.buildArgs);
	}
}

class Cmake : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}
		
	void build ()
	{
		assert(false); //execute("cmake", orb.buildArgs);
	}
}

class Dsss : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}
	
	void build ()
	{
		execute("dsss", "build"[] ~ orb.buildArgs);
	}
}

class Make : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}
	
	void build ()
	{
		execute("make", orb.buildArgs);
	}
}

class Rdmd : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}
	
	void build ()
	{
		assert(false); //execute("rdmd --build-only", orb.buildArgs);
	}
}

class Shell : Builder
{
	this (Orbit orbit, Orb orb)
	{
		super(orbit, orb);
	}
	
	this (Orb orb)
	{
		super(orb);
	}
	
	void build ()
	{
		execute(orb.buildArgs);
	}
}