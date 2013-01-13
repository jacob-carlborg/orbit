/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Builder;

import tango.sys.Process;
import tango.io.Stdout;
//import tango.text.Util;

import mambo.core._;
import orbit.orbit.DependencyHandler;
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
		none
	}
	
	template Constructors ()
	{
		this (Orb orb, DependencyHandler dependencyHandler)
		{
			super(orb, dependencyHandler);
			this.dependencyHandler = dependencyHandler;
		}

		this (Orbit orbit, Orb orb, DependencyHandler dependencyHandler)
		{
			super(orbit, orb, dependencyHandler);
			this.dependencyHandler = dependencyHandler;
		}
	}
	
	string workingDirectory;
	private DependencyHandler dependencyHandler;
	
	this (Orb orb, DependencyHandler dependencyHandler)
	{
		super(orb);
		this.dependencyHandler = dependencyHandler;
	}

	this (Orbit orbit, Orb orb, DependencyHandler dependencyHandler)
	{
		super(orbit, orb);
		this.dependencyHandler = dependencyHandler;
	}
	
	static Tool toBuilder (string str)
	{
		switch (str)
		{
			case "dake": return Tool.dake;
			case "cmake": return Tool.cmake;
			case "dsss": return Tool.dsss;
			case "make": return Tool.make;
			case "rdmd": return Tool.rdmd;
			case "shell": return Tool.shell;
			default: return Tool.none;
		}
	}
	
	static Builder newBuilder (Orb orb, DependencyHandler dependencyHandler, Orbit orbit = null)
	{
		if (!orbit)
			orbit = Orbit.defaultOrbit;

		static Builder sourceBuilder;
		
		final switch (orb.buildTool)
		{
			case Tool.dake: return new Dake(orbit, orb, dependencyHandler);
			case Tool.cmake: return new Cmake(orbit, orb, dependencyHandler);
			case Tool.dsss: return new Dsss(orbit, orb, dependencyHandler);
			case Tool.make: return new Make(orbit, orb, dependencyHandler);
			case Tool.rdmd: return new Rdmd(orbit, orb, dependencyHandler);
			case Tool.shell: return new Shell(orbit, orb, dependencyHandler);
			
			case Tool.none:
				return sourceBuilder = sourceBuilder ? sourceBuilder : new Source(orbit, orb, dependencyHandler);
		}
	}
	
	final void build ()
	{
		setupBuildEnvironment;
		execute(buildArgs() ~ orb.buildArgs() ~ dependencyArgs());
	}
	
	protected abstract string[] buildArgs ();
	protected abstract string[] dependencyArgs ();
	
	protected void execute (string command, string[] args ...)
	{
		execute(command ~ args);
	}
	
	protected void setupBuildEnvironment ()
	{
		auto binPath = Path.join(workingDirectory, orb.bindir);

		if (!Path.exists(binPath))
			Path.createPath(binPath);
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
			// verbose("");
			// verbose("Process ", process.programName, '(', process.pid, ')', " exited with:");
			// verbose("reason: ", result.toString);
			// verbose("status: ", result.status, "\n");
			verbose(cast(string)(result.toString));
		}
	}
	
	private string[] cleanArgs (string[] args)
	{
		if (args.any && args[0].isEmpty)
			return args[0 .. $ - 1];

		return args;
	}
}

class Dake : Builder
{
	mixin Constructors;

	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}

class Cmake : Builder
{
	mixin Constructors;
		
	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}

class Dsss : Builder
{
	mixin Constructors;
	
	override string[] dependencyArgs ()
	{
		return dependencyHandler.buildDependencies().map!((orb) {
			auto libraryFlag = " -ll";
			auto libraries = orb.libraries.join(libraryFlag);
			
			if (libraries.isPresent())
				libraries = libraryFlag ~ libraries;
			
			return cast(string)("-I" ~ orb.srcPath ~ " -S" ~ orb.libPath ~ libraries);
		}).toArray;
	}
	
	override string[] buildArgs ()
	{
		return ["dsss", "build"];
	}
}

class Make : Builder
{
	mixin Constructors;
	
	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}

class Rdmd : Builder
{
	mixin Constructors;
	
	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}

class Shell : Builder
{
	mixin Constructors;
	
	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}

class Source : Builder
{
	mixin Constructors;
	
	override string[] dependencyArgs ()
	{
		assert(0, "unimplemented");
	}
	
	override string[] buildArgs ()
	{
		assert(0, "unimplemented");
	}
}
