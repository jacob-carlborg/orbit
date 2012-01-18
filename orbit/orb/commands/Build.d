/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 26, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Build;

import orbit.core._;
import orbit.dsl.Specification;
import Path = orbit.io.Path;
import orbit.orbit.Archiver;
import orbit.orbit.Orb;

import orbit.orb.Command;

class Build : Command
{
	private string orbspecPath_;
	this ()
	{
		super("build", "Build an orb from an orbspec");
	}
	
	void execute ()
	{
		auto currentWorkingDirectory = Path.workingDirectory;
		Path.workingDirectory = workingDirectory;
		
		auto spec = Specification.load(orbspecPath);
		scope archiver = new Archiver(spec, output);
		archiver.archive;
		
		Path.workingDirectory = currentWorkingDirectory;
	}
	
	protected override void setupArguments ()
	{
		arguments.output.aliased('o').params(1).defaults(&defaultOutput).help("The name of the output file.");
	}
	
private:
	
	string orbspecPath ()
	{
		if (orbspecPath_)
			return orbspecPath_;
		
		auto path = Path.toAbsolute(arguments.first);
		return orbspecPath_ = Path.setExtension(cast(string)path, Specification.extension);
	}
	
	string defaultOutput ()
	{
		return cast(string)Path.parse(cast(char[])orbspecPath).name;
	}

    string output ()
    {
        auto path = Path.toAbsolute(arguments.output);
        return cast(string)Path.setExtension(cast(string)path, Orb.extension);
    }

	string workingDirectory ()
	{
		return cast(string)Path.parse(cast(char[])orbspecPath).folder;
	}
}
