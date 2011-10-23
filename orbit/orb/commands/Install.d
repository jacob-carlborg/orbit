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
import orbit.orbit.Installer;
import orbit.orbit.Orb;

class Install : Command
{	
	this (string name, string summary = "")
	{
		super(name, summary);
	}
	
	this ()
	{
		super("install", "Install an orb into the local repository");
	}
	
	void execute ()
	{
		scope installer = new Installer(Orb.load(orbPath));
		installer.install;
	}
	
	protected override void setupArguments ()
	{
		arguments["source"]
			.aliased('s')
			.params(1)
			.help("URL or local path used as the remote source for orbs.");
	}
	
private:

	string orbPath ()
	{
		auto path = Path.toAbsolute(arguments.first);
		return Path.setExtension(path, Orb.extension);
	}
}