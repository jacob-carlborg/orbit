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
		clean;
		build;
		moveFiles;
	}
	
	string installPath ()
	{
		return installPath_ = installPath_.any() ? installPath_ : orbit.path.orbs;
	}
	
private:

	void build ()
	{
		verbose("Building:");
		
		auto builder = Builder.newBuilder(orbit, orb);
		builder.workingDirectory = Path.join(tmpPath, orbit.constants.orbData);
		builder.build;
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
		
		auto path = Path.join(fullInstallPath, orbit.constants.bin);
		auto tmpDataPath = Path.join(tmpPath, orbit.constants.orbData);
		
		Path.createPath(path);
		
		foreach (file ; orb.executables)
		{
			auto source = Path.join(tmpDataPath, file);
			auto destination = Path.join(path, file);

			verbose("Source:", source);
			verbose("Destination: ", destination);

			Path.moveForce(source, destination);
		}
	}
	
	void clean ()
	{
		verbose("Cleaning:");
		verbose("Removing: ", tmpPath);
		//Path.remove(tmpPath);
	}
}