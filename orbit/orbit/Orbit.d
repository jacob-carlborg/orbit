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
	Env env;
	Spec spec;
	Repository repository;
	
	bool isVerbose;
	void delegate (string[] ...) verboseHandler;
	void delegate (string[] ...) printHandler;
	void delegate (int bytesLeft, int contentLength, int chunkSize) progress;
	Path path;
	Constants constants;
	
	private static Orbit defaultOrbit_;
	
	static Orbit defaultOrbit ()
	{
		return defaultOrbit_ = defaultOrbit_ ? defaultOrbit_ : defaultConfiguration(new Orbit);
	}
	
	private static Orbit defaultConfiguration (Orbit orbit)
	{
		version (Posix)
		{			
			version (darwin)
				orbit.constants = new ConstantsDarwin;
				
			else
				orbit.constants = new ConstantsPosix;

			orbit.path = new PathPosix(orbit.constants, orbit);
		}
			
		else version (Windows)
		{
			orbit.constants = new ConstantsWindows;
			orbit.path = new PathWindows(orbit.constants, orbit);
		}
		
		orbit.verboseHandler = (string[] args ...) {
			orbit.println(args);
		};
		
		orbit.printHandler = (string[] args ...) {
			orbit.print(args);
		};
		
		orbit.progress = &orbit.progressHandler;
		orbit.isVerbose = true;
		
		return orbit;
	}
	
	void verbose (string[] args ...)
	{
		if (isVerbose && verboseHandler)
			verboseHandler(args);
	}
	
	void print (string[] args ...)
	{
		printHandler(args);
	}
	
	void println (string[] args ...)
	{
		printHandler(args ~ "\n"[]);
	}
	
	string libName (string name)
	{
		return setExtension(constants.libPrefix ~ name, constants.libExtension);
	}
	
	string dylibName (string name)
	{
		return setExtension(constants.dylibPrefix ~ name, constants.dylibExtension);
	}
	
	string exeName (string name)
	{
		return setExtension(name, constants.exeExtension);
	}

	private void progressHandler (int bytesLeft, int contentLength, int chunkSize)
	{
		version (Posix)
		{
			const clearLine = "\033[1K"; // clear backwards
			const saveCursor = "\0337";
			const restoreCursor = "\0338";
		}
		
		else
		{
			const clearLine = "\r";
			const saveCursor = "";
			const restoreCursor = "";
		}
		
		int width = contentLength * chunkSize;
		int num = width;
		int i = 0;
		
		print(clearLine, restoreCursor, saveCursor);
		print("[");
		
		for ( ; i < (width - num); i++)
			print("=");
		
		print(">");
		
		for ( ; i < width; i++)
			print(" ");
		
		print("]");
		print(format(" {}/{} KB", (contentLength - bytesLeft) / 1024, contentLength / 1024));
	}

static:
	
	abstract class Path
	{	
		private
		{
			string home_;
			string bin_;
			string orbs_;
			string specifications_;
			string tmp_;
			
			Constants constants;
			Orbit orbit;
		}
		
		template Constructor ()
		{
			this (Constants constants, Orbit orbit)
			{
				super(constants, orbit);
			}
		}
		
		this (Constants constants, Orbit orbit)
		{
			this.constants = constants;
			this.orbit = orbit;
		}
		
		abstract string defaultHome ();

		string home ()
		{
			return home_ = home_.length > 0 ? home_ : toAbsolute(Environment.get(orbit.env.home, defaultHome));
		}

		string home (string home)
		{
			return home_ = home;
		}
		
		string bin ()
		{
			return bin_ = bin_.length > 0 ? bin_ : join(home, constants.bin);
		}
		
		string bin (string bin)
		{
			return bin_ = bin;
		}
		
		string orbs ()
		{
			return orbs_ = orbs_.length > 0 ? orbs_ : join(home, constants.orbs);
		}
		
		string orbs (string orbs)
		{
			return orbs_ = orbs;
		}
		
		string specifications ()
		{
			return specifications_ = specifications_.length > 0 ? specifications_ : join(home, constants.specifications);
		}
		
		string specifications (string specifications)
		{
			return specifications_ = specifications;
		}
		
		string tmp ()
		{
			return tmp_ = tmp_.length > 0 ? tmp_ : join(home, constants.tmp);
		}
		
		string tmp (string tmp)
		{
			return tmp_ = tmp;
		}
	}
	
	class PathPosix : Path
	{
		mixin Path.Constructor;
		
		string defaultHome ()
		{
			return "/usr/local/orbit";
		}
	}

	class PathWindows : Path
	{
		mixin Path.Constructor;
		
		string defaultHome ()
		{
			assert(false, "not implemented");
		}
	}

	struct Env
	{
		string home = "ORB_HOME";
	}

	struct Repository
	{
		string orbs = "orbs";
		
		private string source_;
		
		string source ()
		{
			return source_ = source_.isPresent() ? source_ :  "/usr/local/orbit/repository";
		}
		
		string source (string source)
		{
			return source_ = source;
		}
	}

	abstract class Constants
	{
		abstract string dylibExtension ();
		abstract string dylibPrefix ();
		abstract string exeExtension ();
		abstract string libExtension ();
		abstract string libPrefix ();
		
		string orbData = "data";
		string orbMetaData = "metadata";
		string bin = "bin";
		string tmp = "tmp";
		string specifications = "specifications";
		string orbs = "orbs";
		string lib = "lib";
		string imports = "import";
		string src = "src";
		string index = "index";
		string indexFormat = "xml";
	}

	class ConstantsPosix : Constants
	{
		string dylibExtension ()
		{
			return "so";
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
			return "a";
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
			return "dylib";
		}
	}

	class ConstantsWindows : Constants
	{
		string dylibExtension ()
		{
			return "dll";
		}
		
		string dylibPrefix ()
		{
			return "";
		}
		
		string exeExtension ()
		{
			return "exe";
		}
		
		string libExtension ()
		{
			return "lib";
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
}