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
import orbit.orbit.Repository;
import orbit.util.Tuple;
import orbit.util.Use;

class Installer : OrbitObject
{	
    @property Repository repository() { return repository_; }

	private
	{
        Repository repository_;
		string installPath_;
		string fullInstallPath_;
		string tmpPath_;
		string tmpDataPath_;

		DependencyHandler dependencyHandler;
	}
	
	this (Orb orb, Repository repository, string installPath = "", Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		installPath_ = installPath;
		this.repository_ = repository;
		dependencyHandler = new DependencyHandler(orb, repository, orbit);
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
		
		auto builder = Builder.newBuilder(orb, dependencyHandler, orbit);
		builder.workingDirectory = Path.join(tmpPath, orbit.constants.orbData);
		builder.build;
	}
	
	void installDependencies ()
	{
		foreach (orb ; dependencyHandler.buildDependencies)
		{
			auto localOrb = Orb.load(orb, repository);
			scope installer = new Installer(localOrb, repository, installPath, orbit);

			installer.install;
		}
	}
	
	string tmpPath ()
	{
		if (tmpPath_.any())
			return tmpPath_;
			
		tmpPath_ = orb.fullName().any() ? orb.fullName : orb.path;
		return tmpPath_ = Path.join(orbit.path.tmp, tmpPath_);
	}
	
	string fullInstallPath ()
	{
		return fullInstallPath_ = fullInstallPath_.any() ? fullInstallPath_ : Path.join(installPath, cast(string)orb.fullName().toLower());
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

		auto executables = orb.executables.map((string e) {
			auto path = Path.parse(cast(char[])e);
			auto file = orbit.exeName(cast(string)path.file);

			return Path.join(cast(string)path.folder, file);
		});

		auto path = Path.join(fullInstallPath, orbit.constants.bin);
		moveSpecificFiles(executables, path, prefix);
	}
	
	void moveLibraries ()
	{
		auto destinationPath = Path.join(fullInstallPath, orbit.constants.lib);
		
		if (orb.libraries.any())
			Path.createPath(destinationPath);
		
		Tuple!(string, string) libName (string lib, bool dynamic)
		{
			auto path = Path.parse(cast(char[])lib);
			auto file = dynamic ? orbit.dylibName(cast(string)path.file) : orbit.libName(cast(string)path.file);
			
			return tuple(Path.join(cast(string)path.folder, file), file);
		}
		
		foreach (lib ; orb.libraries)
		{
			auto libTuple = libName(lib, false);
			auto dylibTuple = libName(lib, true);
			
			auto libPath = Path.join(tmpDataPath, libTuple.values[0]);
			auto dylibPath = Path.join(tmpDataPath, dylibTuple.values[0]);

			auto libDestination = Path.join(destinationPath, libTuple.values[1]);
			auto dylibDestination = Path.join(destinationPath, dylibTuple.values[1]);
			
			if (Path.exists(libPath))
				moveSingleFile(libPath, libDestination);
				
			else if (Path.exists(dylibPath))
				moveSingleFile(dylibPath, dylibDestination);
				
			else
				throw new MissingLibraryException(libPath, dylibPath);
		}
	}
	
	void moveSources ()
	{
		auto path = Path.join(fullInstallPath, orbit.constants.src);
		moveSpecificFiles(orb.files, path);
	}
	
	void moveSpecificFiles (in string[] files, string destinationPath, string filePrefix = "")
	{
		if (files.any())
			Path.createPath(destinationPath);

		foreach (file ; files)
		{
			auto source = Path.join(tmpDataPath, filePrefix, file);
			auto destination = Path.join(destinationPath, file);
			moveSingleFile(source, destination);
		}
	}
	
	void moveSingleFile (string source, string destination)
	{
		verbose("Source:", source);
		verbose("Destination: ", destination);

		Path.moveForce(source, destination);
	}
	
	void clean ()
	{
		verbose("Cleaning:");
		verbose("Removing: ", tmpPath);
		//Path.remove(tmpPath);
	}
}
