/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 11, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Push;

import mambo.core._;

import dstack.controller.Command;

import Path = orbit.io.Path;
import orbit.orbit.Orb;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

class Push : Command
{
	this ()
	{
		//super("push", "Push an orb up to DOrbit.org.");
	}

	protected override bool run ()
	{
		scope repository = Repository.instance(arguments.source);
		scope orb = Orb.load(orbPath);

		repository.api.upload(orb);

		return true;
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
		auto path = Path.toAbsolute(cast(char[]) arguments.first).assumeUnique;
		return Path.setExtension(path, Orb.extension);
	}
}
