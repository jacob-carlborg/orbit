/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Install;

import orbit.core._;
import orbit.orb.Command;
import orbit.orbit.Installer;
import orbit.orbit.Orb;

class Install : Command
{
	private string name;
	
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
		auto orbPath = "/Users/doob/development/eclipse_workspace/orbit/src/test.zip";
		
		scope installer = new Installer(Orb.load(orbPath));
		installer.install;
		
		// name = args.first;
		// auto ver = "";
		// 
		// Orbit.getDefault.install(name, ver);
	}
}