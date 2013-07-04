/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.config.Configuration;

import mambo.util.Singleton;

import dstack.application.Configuration;

class Configuration : dstack.application.Configuration.Configuration
{
	auto appName = "orb";
	auto appVersion = "0.0.1";

	this ()
	{
		super(this);
	}
}