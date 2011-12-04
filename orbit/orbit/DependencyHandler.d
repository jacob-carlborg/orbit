/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 21, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.DependencyHandler;

import tango.util.container.HashSet;

import orbit.core._;
import orbit.orbit.Index;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;
import orbit.orbit.Repository;

class DependencyHandler : OrbitObject
{
	private
	{
		const Repository repository;
		Orb[string] buildDependencies_;
	}
	
	this (Orb orb, Repository repository, Orbit orbit = Orbit.defaultOrbit)
	{
		super(orbit, orb);
		this.repository = repository;
	}
	
	Orb[] buildDependencies ()
	{
		collectBuildDependencies(orb.buildDependencies);
		return buildDependencies_.values;
	}
	
	private void collectBuildDependencies (string[] dependencies)
	{
		foreach (dep ; dependencies)
		{
			scope orb = Orb.parse(dep);
			
			if (!orb.version_.isValid)
				orb.version_ = repository.api.latestVersion(orb.name);
			
			orb = repository.api.getOrb(orb);
			
			if (!(orb.fullName in buildDependencies_))
			{
				collectBuildDependencies(orb.buildDependencies);
				buildDependencies_[orb.fullName] = orb;
			}
		}
	}
}