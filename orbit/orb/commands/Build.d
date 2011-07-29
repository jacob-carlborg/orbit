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
		auto spec = Specification.load(orbspecPath);
		scope archiver = new Archiver(spec, arguments["output"].value);
		archiver.archive;
	}
	
	protected override void setupArguments ()
	{
		arguments["output"].aliased('o').defaults(defaultOutput).help("The name of the output file.");
	}
	
private:
	
	string orbspecPath ()
	{
		return orbspecPath_ = orbspecPath_.any() ? orbspecPath_ : Path.toAbsolute(arguments.first);
	}
	
	string defaultOutput ()
	{
		return Path.parse(orbspecPath).path ~ "." ~ Orb.extension;
	}
}