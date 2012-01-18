/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 11, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Push;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit.Orb;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

import orbit.orb.Command;

class Push : Command
{
	this ()
	{
		super("push", "Push an orb up to DOrbit.org.");
	}
	
	void execute ()
	{
		scope repository = Repository.instance(arguments.source);
		scope orb = Orb.load(orbPath);

		repository.api.upload(orb);
	}
	
	protected override void setupArguments ()
	{
		arguments.source
			.aliased('s')
			.params(1)
			.help("URL or local path used as the remote source for orbs.");
	}
	
private:
	
	string orbPath ()
	{
		auto path = Path.toAbsolute(arguments.first);
		return Path.setExtension(cast(string)path, Orb.extension);
	}
}
