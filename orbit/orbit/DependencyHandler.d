/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 21, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.DependencyHandler;

import tango.util.container.HashSet;

import orbit.core.string;
import orbit.orbit.Index;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;

class DependencyHandler : OrbitObject
{
	private
	{
		const Index index;
		HashSet!(string) buildDependencies_;
	}
	
	this (Orb orb, Index index, Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		this.index = index;
		buildDependencies_ = new HashSet!(string);
	}
	
	string[] buildDependencies ()
	{	
		collectBuildDependencies(orb.buildDependencies);
		return buildDependencies_.toArray;
	}
	
	void collectBuildDependencies (string[] dependencies)
	{	
		foreach (dep ; dependencies)
		{
			scope orb = Orb.parse(dep);
			orb = index[orb];
			
			collectBuildDependencies(orb.buildDependencies);
			
			if (!buildDependencies_.contains(dep))
				buildDependencies_.add(dep);
		}
	}
}