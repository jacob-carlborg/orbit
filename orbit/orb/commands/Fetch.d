/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 31, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Fetch;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit.Fetcher;
import orbit.orbit.Orb;

import orbit.orb.Command;

class Fetch : Command
{
	this ()
	{
		super("fetch", "Download an orb and place it in the current directory");
	}
	
	void execute ()
	{
		auto spec = Specification.load(orbspecPath);
		scope archiver = new Archiver(spec, output);
		archiver.archive;
		
		auto fetcher = new Fetch;
		fetcher.source = arguments["source"];
		fetcher.fetch(arguments.first);
	}
	
	protected override void setupArguments ()
	{
		arguments["output"].aliased('o').params(1).defaults(&defaultOutput).help("The name of the output file.");
		arguments["source"].aliased('s').params(1).defaults(orbit.constants.repositorySource).help("URL or local path used as the remote source for orbs")
	}

private:

	string defaultOutput ()
	{
		auto path = Path.join(Path.workingDirectory, arguments.first);
		return Path.setExtension(path, Orb.extension);
	}

    string output ()
    {
        auto path = Path.toAbsolute(arguments["output"].value);
        return Path.setExtension(path, Orb.extension);
    }
}