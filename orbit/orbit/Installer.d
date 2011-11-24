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
import orbit.orbit.DependencyHandler;
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
		string fullInstallPath_;
		string tmpPath_;
		string tmpDataPath_;
	}
	
	this (Orb orb, string installPath = "", Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		installPath_ = installPath;
	}
	
	void install ()
	{
		clean;
		installDependencies;
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
	
	void installDependencies ()
	{
		scope dependencyHandler = new DependencyHandler(orb, orbit);
		
		foreach (orb ; dependencyHandler.dependencies)
		{
			scope installer = new Installer(orb, installPath, orbit);
			installer.install;
		}
	}
	
	string tmpPath ()
	{
		return tmpPath_ = tmpPath_.any() ? tmpPath_ : Path.join(orbit.path.tmp, Path.parse(orb.path).name);
	}
	
	string fullInstallPath ()
	{
		return fullInstallPath_ = fullInstallPath_.any() ? fullInstallPath_ : Path.join(installPath, orb.fullName().toLower());
	}
	
	string tmpDataPath ()
	{
		return tmpDataPath_ = tmpDataPath_.any() ? tmpDataPath_ : Path.join(tmpPath, orbit.constants.orbData);
	}
	
	void moveFiles ()
	{
		verbose("Moving files:");

		if (Path.exists(fullInstallPath))
			throw new OrbitException(`The path "` ~ fullInstallPath ~ `" already exists.`, __FILE__, __LINE__);

		moveExecutables;
		moveLibraries;
		moveSources;
	}
	
	void moveExecutables ()
	{
		string prefix;
		
		if (orb.bindir.isPresent())
			prefix = orb.bindir;

		auto path = Path.join(fullInstallPath, orbit.constants.bin);
		moveSpecificFiles(orb.executables, path, prefix);
	}
	
	void moveLibraries ()
	{
		auto path = Path.join(fullInstallPath, orbit.constants.lib);
		moveSpecificFiles(orb.libraries, path);
	}
	
	void moveSources ()
	{
		auto path = Path.join(fullInstallPath, orbit.constants.src);
		moveSpecificFiles(orb.files, path);
	}
	
	void moveSpecificFiles (string[] files, string destinationPath, string filePrefix = "")
	{
		Path.createPath(destinationPath);

		foreach (file ; files)
		{
			auto source = Path.join(tmpDataPath, filePrefix, file);
			auto destination = Path.join(destinationPath, file);

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