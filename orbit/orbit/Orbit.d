/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 26, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orbit;

import tango.sys.Environment;

import orbit.core._;
import orbit.util._;

class Orbit
{
	const Env env = Env();
	
	private
	{
		static Orbit defaultOrbit_;
		
		Path path;
	}
	
	static Orbit defaultOrbit ()
	{
		return defaultOrbit_ = defaultOrbit_ ? defaultOrbit_ : defaultConfiguration(new Orbit);
	}
	
	private static Orbit defaultConfiguration (Orbit orbit)
	{
		orbit.path = Path.instance;
		
		return orbit;
	}
}

abstract class Path
{	
	private
	{
		string home_;
		string bin_;
		string orbs_;
		string specifications_;
	}
	
	abstract string defaultHome ();

	string home ()
	{
		return home_ = home_.length > 0 ? home_ : Environment.get(Orbit.env.home, defaultHome);
	}

	string home (string home)
	{
		return home_ = home;
	}
	
	string bin ()
	{
		return bin_ = bin_.length > 0 ? bin_ : join(home, "bin");
	}
	
	string bin (string bin)
	{
		return bin_ = bin;
	}
	
	string orbs ()
	{
		return orbs_ = orbs_.length > 0 ? orbs_ : join(home, "orbs");
	}
	
	string orbs (string orbs)
	{
		return orbs_ = orbs;
	}
	
	string specifications ()
	{
		return specifications_ = specifications_.length > 0 ? specifications_ : join(home, "specifications");
	}
	
	string specifications (string specifications)
	{
		return specifications_ = specifications;
	}
}

class PathDarwin : Path
{
	string defaultHome ()
	{
		return "/usr/local/orbit";
	}
}

struct Env
{
	const home = "ORB_HOME";
}