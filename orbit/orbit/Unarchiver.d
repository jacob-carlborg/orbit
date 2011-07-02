/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 19, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Unarchiver;

import orbit.orbit.OrbitObject;
import orbit.orbit.Orb;
import tango.util.compress.Zip : extractArchive;

class Unarchiver : OrbitObject
{	
	private Orb orb;
	
	this (Orb orb, Orbit orbit = null)
	{
		super(orbit);
		this.orb = orb;
	}
	
	void unarchive ()
	{
		
	}
}