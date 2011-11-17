/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Install;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orb.Command;
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
		super(name, summary);
	}
	
	this ()
	{
		super("install", "Install an orb into the local repository");
		defaultOrbVersion = OrbVersion.invalid.toString;
	}
	
	void execute ()
	{
		scope orb = new Orb(arguments.first, arguments["version"].value);
		orb = Orb.load(orb, arguments["source"].value);
		
		scope installer = new Installer(orb);
		installer.install;
	}
	
	protected override void setupArguments ()
	{
		arguments["source"]
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