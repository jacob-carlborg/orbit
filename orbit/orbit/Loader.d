/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 27, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Loader;

import Zip = tango.util.compress.Zip : extractArchive;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;

class Loader
{
	const Orbit orbit;
	
	private
	{
		string orbPath_;
		string temporaryPath_;
	}
	
	this (Orbit orbit)
	{
		this.orbit = orbit ? orbit : Orbit.defaultOrbit;
	}
	
	this ()
	{
		this(Orbit.defaultOrbit);
	}
	
	string orbPath ()
	{
		return orbPath_;
	}
	
	string temporaryPath ()
	{
		return temporaryPath_;
	}
	
	void load (string orbPath, string temporaryPath = "", bool cleanTemporaryPath = true)
	{
		orbPath_ = orbPath;
		temporaryPath_ = temporaryPath.any() ? temporaryPath : defaultTmpPath;
		
		if (cleanTemporaryPath && Path.exists(temporaryPath_))
		{
			Path.remove(temporaryPath_, true);
			Path.createPath(temporaryPath_);
		}
		
		extractArchive(orbPath, temporaryPath_);
	}
	
private:
	
	void extractArchive (string source, string dest)
	{
		verbose("Unpacking orb:");
		verbose("Source: ", source);
		verbose("Destination: ", dest);
		Zip.extractArchive(source, dest);
	}
	
	string defaultTmpPath ()
	{
		return Path.join(orbit.path.tmp, Path.parse(orbPath).name);
	}
	
	void verbose (string[] args ...)
	{
		orbit.verbose(args);
	}
}

