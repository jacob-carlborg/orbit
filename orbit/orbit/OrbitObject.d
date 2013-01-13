/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.OrbitObject;

import mambo.core._;
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


    @property Orbit orbit() { return orbit_; }
    @property Orb orb() { return orb_; }
	
    private 
    {
	    Orbit orbit_;
	    Orb orb_;
    }
	
	this (Orb orb)
	{
		this(Orbit.defaultOrbit, orb);
	}
	
	this (Orbit orbit, Orb orb)
	{
		this.orb_ = orb;
		this.orbit_ = orbit ? orbit : Orbit.defaultOrbit;
	}
	
	void verbose (string[] args ...)
	{
		orbit_.verbose(args);
	}
}
