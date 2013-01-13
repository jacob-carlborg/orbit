/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 26, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orbit;

import tango.sys.Environment;

import mambo.core._;
import orbit.io.Path;
import orbit.orbit.Builder;
//import mambo.util._;

private alias orbit.io.Path.join joinPath;

class Orbit
{	
	Env env;
	Spec spec;
	Repository repository;
	
	bool isVerbose;
	void delegate (string[] ...) verboseHandler;
	void delegate (string[] ...) printHandler;
	ProgressHandler progress;
	Path path;
	Constants constants;
	
	private static Orbit defaultOrbit_;
	
	public static Orbit defaultOrbit ()
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
		
		orbit.printHandler = (string[] args ...) {
			foreach (arg ; args)
				.print(arg);
		};
		
		orbit.verboseHandler = &orbit.println;
		orbit.progress = new DefaultProgressHandler(orbit);
		orbit.isVerbose = true;
		
		return orbit;
	}
	
	void verbose (string[] args ...) const
	{
		if (isVerbose && verboseHandler)
			verboseHandler(args);
	}
	
	void print (string[] args ...) const
	{
		printHandler(args);
	}
	
	void println (string[] args ...) const
	{
		printHandler(args ~ "\n"[]);
	}
	
	string libName (string name) const
	{
		return setExtension(constants.libPrefix ~ name, constants.libExtension);
	}
	
	string dylibName (string name) const
	{
		return setExtension(constants.dylibPrefix ~ name, constants.dylibExtension);
	}
	
	string exeName (string name) const
	{
		return setExtension(name, constants.exeExtension);
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

			home_ = cast(string)toAbsolute(Environment.get(cast(const(char)[])orbit.env.home, cast(char[])defaultHome));
            bin_ = joinPath(home, constants.bin);
			orbs_ = joinPath(home, constants.orbs);
            specifications_ = joinPath(home, constants.specifications);
            tmp_ = joinPath(home, constants.tmp);
		}
		
		abstract string defaultHome ();

		string home () const
		{
			return home_;
		}

		string home (string home)
		{
			return home_ = home;
		}
		
		string bin () const
		{
			return bin_;
		}
		
		string bin (string bin)
		{
			return bin_ = bin;
		}
		
		string orbs () const
		{
			return orbs_;
		}
		
		string orbs (string orbs)
		{
			return orbs_ = orbs;
		}
		
		string specifications () const
		{
			return specifications_;
        }
		
		string specifications (string specifications)
		{
			return specifications_ = specifications;
		}
		
		string tmp () const
		{
			return tmp_;
		}
		
		string tmp (string tmp)
		{
			return tmp_ = tmp;
		}
	}
	
	class PathPosix : Path
	{
		mixin Path.Constructor;
		
		override string defaultHome ()
		{
			return "/usr/local/orbit";
		}
	}

	class PathWindows : Path
	{
		mixin Path.Constructor;
		
		override string defaultHome ()
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
		abstract string dylibExtension () const;
		abstract string dylibPrefix () const;
		abstract string exeExtension () const;
		abstract string libExtension () const;
		abstract string libPrefix () const;
		
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
		override string dylibExtension () const
		{
			return "so";
		}
		
		override string dylibPrefix () const
		{
			return "lib";
		}
		
		override string exeExtension () const
		{
			return "";
		}
		
	 	override string libExtension () const
		{
			return "a";
		}
		
		override string libPrefix () const
		{
			return "lib";
		}
	}

	class ConstantsDarwin : ConstantsPosix
	{
		override string dylibExtension () const
		{
			return "dylib";
		}
	}

	class ConstantsWindows : Constants
	{
		override string dylibExtension () const
		{
			return "dll";
		}
		
		override string dylibPrefix () const
		{
			return "";
		}
		
		override string exeExtension () const
		{
			return "exe";
		}
		
		override string libExtension () const
		{
			return "lib";
		}
		
		override string libPrefix () const
		{
			return "";
		}
	}

	struct Spec
	{
		Builder.Tool defaultBuildTool = Builder.Tool.dsss;
	}

	abstract class ProgressHandler
	{
		private Orbit orbit_;
		
		this (Orbit orbit)
		{
			orbit_ = orbit;
		}

		void start (int length, int chunkSize, int width);
		void opCall (int bytesLeft);
		void end ();
		
		@property Orbit orbit ()
		{
			return orbit_;
		}
	}
	
	class DefaultProgressHandler : ProgressHandler
	{
		this (Orbit orbit)
		{
			super(orbit);
		}
		
		private
		{
			int num;
			int width;
			int chunkSize;
			int contentLength;
			
			version (Posix)
				enum
				{
					clearLine = "\033[1K", // clear backwards
					saveCursor = "\0337",
					restoreCursor = "\0338"
				}
				
			else
				enum
				{
					clearLine = "\r",
					saveCursor = "",
					restoreCursor = ""
				}
		}
		
		override void start (int contentLength, int chunkSize, int width)
		{
			this.chunkSize = chunkSize;
			this.contentLength = contentLength;
			this.width = width;
			this.num = width;
			
			orbit.print(saveCursor);
		}
		
		override void opCall (int bytesLeft)
		{
			int i = 0;

			orbit.print(clearLine ~ restoreCursor ~ saveCursor);
			orbit.print("[");

			for ( ; i < (width - num); i++)
				orbit.print("=");

			orbit.print(">");

			for ( ; i < width; i++)
				orbit.print(" ");

			orbit.print("]");
			orbit.print(format(" {}/{} KB", (contentLength - bytesLeft) / 1024, contentLength / 1024).assumeUnique);

			num--;
		}
		
		override void end ()
		{
			orbit.println(restoreCursor);
			orbit.println();
		}
	}
}