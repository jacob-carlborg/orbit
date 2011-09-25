/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.OrbitObject;

import orbit.core._;
import orbit.orbit.Orbit;
import orbit.orbit.Orb;

abstract class OrbitObject
{
	template Constructors ()
	{
		this (Orb orb)
		{
			super(orb);
		}

		this (Orbit orbit, Orb orb)
		{
			super(orbit, orb);
		}
	}
	
	const Orbit orbit;
	const Orb orb;
	
	this (Orb orb)
	{
		this(Orbit.defaultOrbit, orb);
	}
	
	this (Orbit orbit, Orb orb)
	{
		this.orb = orb;
		this.orbit = orbit ? orbit : Orbit.defaultOrbit;
	}
	
	void verbose (string[] args ...)
	{
		orbit.verbose(args);
	}
}