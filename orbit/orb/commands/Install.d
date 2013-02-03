/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Install;

import mambo.core._;

import dstack.controller.Command;

import Path = orbit.io.Path;
import orbit.orbit.Fetcher;
import orbit.orbit.Installer;
import orbit.orbit.Orb;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

class Install : Command
{
	private string defaultOrbVersion;

	this (string name, string summary = "")
	{
		//super(name, summary);
	}

	this ()
	{
		//super("install", "Install an orb into the local repository");
		defaultOrbVersion = OrbVersion.invalid.toString;
	}

	protected override bool run ()
	{
		auto orb = new Orb(arguments.first, arguments["version"]);
		scope repository = Repository.instance(arguments.source);

		orb = Orb.load(orb, repository);
		scope installer = new Installer(orb, repository);

		installer.install;

		return true;
	}

	protected override void setupArguments ()
	{
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
}