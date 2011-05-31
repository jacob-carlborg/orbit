/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orb;

import orbit.core._;

class Orb
{
	string name;
	string version_;
	
	this (string name = "", string version_ = "")
	{
		this.name = name;
		this.version_ = version_;
	}
}