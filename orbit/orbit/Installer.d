/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 19, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Installer;

import tango.text.Unicode;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit.Builder;
import orbit.orbit.Exceptions;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;
import orbit.util.Use;

class Installer : OrbitObject
{	
	private
	{
		string installPath_;
		string tmpPath_;
	}
	
	this (Orb orb, string installPath = "", Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		installPath_ = installPath;
	}
	
	void install ()
	{
		build;
		moveFiles;
		clean;
	}
	
	string installPath ()
	{
		return installPath_ = installPath_.any() ? installPath_ : orbit.path.orbs;
	}
	
private:

	void build ()
	{
		verbose("Building:");
		verbose("Working directory: ", Path.workingDirectory);
		
		auto prevWorkingDirectory = Path.workingDirectory;
		println(Path.join(tmpPath, orbit.constants.orbData));
		Path.workingDirectory = Path.join(tmpPath, orbit.constants.orbData);
		Builder.newBuilder(orbit, orb).build;
		Path.workingDirectory = prevWorkingDirectory;
	}
	
	string tmpPath ()
	{
		return tmpPath_ = tmpPath_.any() ? tmpPath_ : Path.join(orbit.path.tmp, Path.parse(orb.path).name);
	}
	
	void moveFiles ()
	{
		verbose("Moving files:");
		
		auto fullInstallPath = Path.join(installPath, orb.fullName().toLower());
		
		if (Path.exists(fullInstallPath))
			throw new OrbitException(`The path "` ~ fullInstallPath ~ `" already exists.`, __FILE__, __LINE__);
		
		Path.createPath(fullInstallPath);
		
		foreach (file ; orb.files)
		{
			verbose("Source:", Path.join(tmpPath, file));
			verbose("Destination: ", Path.join(fullInstallPath, file));
			//Path.moveForce(file, Path.join(target, file));
		}
	}
	
	void clean ()
	{
		verbose("Cleaning:");
		verbose("Removing: ", tmpPath);
		//Path.remove(tmpPath);
	}
}