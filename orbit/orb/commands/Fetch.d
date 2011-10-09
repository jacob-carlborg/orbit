/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 31, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Fetch;

import ruby.c.ruby;

import orbit.core._;
import orbit.dsl.Specification;
import Path = orbit.io.Path;
import orbit.orbit.Archiver;
import orbit.orbit.Fetcher;
import orbit.orbit.Orb;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

import orbit.orb.Command;

class Fetch : Command
{
	private string defaultOrbVersion;
	
	this ()
	{
		super("fetch", "Download an orb and place it in the current directory.");
		defaultOrbVersion = OrbVersion.invalid.toString;
	}
	
	void execute ()
	{
		auto repository = Repository.instance(arguments["source"].value);		
		auto fetcher = Fetcher.instance(repository);
	
		auto orb = new Orb;
		orb.name = arguments.first;
		orb.version_ = OrbVersion.parse(arguments["version"].value);
		
		fetcher.fetch(orb, arguments["output"].value);
		
		// auto repository = Repository.instance("file:///Users/doob/Desktop/repository");
		// auto orb = Orb.load("/Users/doob/development/eclipse_workspace/orbit/src/test.orb");
		// repository.api.upload(orb);
	}
	
	protected override void setupArguments ()
	{
		arguments["output"].aliased('o').params(1).defaults(&defaultOutput).help("The name of the output file.");
		arguments["source"].aliased('s').params(1).defaults(orbit.repository.source).help("URL or local path used as the remote source for orbs.");
		arguments["version"].aliased('v').params(1).defaults(defaultOrbVersion).help("Specify version of orb to fetch.");
	}

private:

	string defaultOutput ()
	{
		auto path = Path.join(Path.workingDirectory, arguments.first);
		return Path.setExtension(path, Orb.extension);
	}
}