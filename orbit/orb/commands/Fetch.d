/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 31, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Fetch;

import ruby.c.ruby;

import mambo.core._;
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
	Repository repository;
	private Orb orb;
	
	this ()
	{
		super("fetch", "Download an orb and place it in the current directory.");
		defaultOrbVersion = OrbVersion.invalid.toString;
	}
	
	override void execute ()
	{
		repository = Repository.instance(arguments.source);
		auto fetcher = Fetcher.instance(repository);
	
		orb = new Orb;
		orb.name = arguments.first;
		orb.version_ = version_();
		
		fetcher.fetch(orb, output);
	}
	
	protected override void setupArguments ()
	{
		arguments.output
			.aliased('o')
			.params(1)
			.help("The name of the output file.");
			
		arguments.source
			.aliased('s')
			.params(1)
			.help("URL or local path used as the remote source for orbs.");
			
		arguments["version"]
			.aliased('v')
			.params(1)
			.defaults(defaultOrbVersion)
			.help("Specify version of orb to fetch.");
	}

private:

	string output ()
	{
		if (arguments.output.hasValue)
			return arguments.output;
		
		auto path = Path.join(cast(string)Path.workingDirectory, orb.fullName);
		return Path.setExtension(path, Orb.extension);
	}
	
	OrbVersion version_ ()
	{
		auto ver = OrbVersion.parse(arguments["version"]);
		
		if (ver.isValid)
			return ver;

		return repository.api.latestVersion(orb.name);
	}
}
