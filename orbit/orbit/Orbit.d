/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 26, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orbit;

import tango.sys.Environment;

import orbit.core._;
import orbit.io.Path;
import orbit.orbit.Builder;
import orbit.util._;

class Orbit
{	
	const env = Env();
	const spec = Spec();
	
	bool isVerbose;
	void delegate (string[] ...) verboseHandler;
	
	private
	{
		static Orbit defaultOrbit_;
		Path path_;
		Constants constants_;
	}
	
	static Orbit defaultOrbit ()
	{
		return defaultOrbit_ = defaultOrbit_ ? defaultOrbit_ : defaultConfiguration(new Orbit);
	}
	
	private static Orbit defaultConfiguration (Orbit orbit)
	{
		version (Posix)
		{
			orbit.path = new PathPosix;
			
			version (darwin)
				orbit.constants = new ConstantsDarwin;
				
			else
				orbit.constants = new ConstantsPosix;
		}
			
		else version (Windows)
		{
			orbit.path = new PathWindows;
			orbit.constants = new ConstantsWindows;
		}
		
		orbit.verboseHandler = (string[] args ...) {
			println(args);
		};
		
		orbit.isVerbose = true;
		
		return orbit;
	}
	
	Path path ()
	{
		return path_;
	}
	
	private Path path (Path path)
	{
		return path_ = path;
	}
	
	Constants constants ()
	{
		return constants_;
	}
	
	private Constants constants (Constants constants)
	{
		return constants_ = constants;
	}
	
	void verbose (string[] args ...)
	{
		if (isVerbose && verboseHandler)
			verboseHandler(args);
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
		string tmp_;
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
	
	string tmp ()
	{
		return tmp_ = tmp_.length > 0 ? tmp_ : join(home, "tmp");
	}
	
	string tmp (string tmp)
	{
		return tmp_ = tmp;
	}
}

class PathPosix : Path
{
	string defaultHome ()
	{
		return "/usr/local/orbit";
	}
}

class PathWindows : Path
{
	string defaultHome ()
	{
		assert(false, "not implemented");
	}
}

struct Env
{
	string home = "ORB_HOME";
}

abstract class Constants
{
	abstract string dylibExtension ();
	abstract string dylibPrefix ();
	abstract string exeExtension ();
	abstract string libExtension ();
	abstract string libPrefix ();
	
	string orbData ()
	{
		return "data";
	}
	
	string orbMetaData ()
	{
		return "metadata";
	}
}

class ConstantsPosix : Constants
{
	string dylibExtension ()
	{
		return ".so";
	}
	
	string dylibPrefix ()
	{
		return "lib";
	}
	
	string exeExtension ()
	{
		return "";
	}
	
 	string libExtension ()
	{
		return ".a";
	}
	
	string libPrefix ()
	{
		return "lib";
	}
}

class ConstantsDarwin : ConstantsPosix
{
	string dylibExtension ()
	{
		return ".dylib";
	}
}

class ConstantsWindows : Constants
{
	string dylibPrefix ()
	{
		return "";
	}
	
	string exeExtension ()
	{
		return ".exe";
	}
	
	string libExtension ()
	{
		return ".lib";
	}
	
	string libPrefix ()
	{
		return "";
	}
}

struct Spec
{
	Builder.Tool defaultBuildTool = Builder.Tool.dsss;
}