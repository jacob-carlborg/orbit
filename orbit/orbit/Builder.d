/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Builder;

import tango.sys.Process;

import orbit.core._;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;

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
		verbose("Executing command: ");
		verbose(args);
		//auto process = new Process(args);
		//process.execute;
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
		execute("dsss build", orb.buildArgs);
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