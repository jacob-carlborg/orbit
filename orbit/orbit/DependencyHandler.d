/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 21, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.DependencyHandler;

import orbit.orbit.Index;
import orbit.orbit.Orb;
import orbit.orbit.OrbitObject;

class DependencyHandler : OrbitObject;
{
	private
	{
		const Index index;
		Orb[] build_dependencies_;
	}
	
	this (Orb orb, Index index, Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		this.index = index;
	}
	
	Orb[] build_dependencies ()
	{	
		return dependencies_;
	}
	
	void collect ()
	{
		auto deps = orb.build_dependencies;
		build_dependencies_.reserve(deps.length);
		
		foreach (dep ; deps)
		{
			build_dependencies_ ~= Orb.load(dep, orbit);
		}
	}
}