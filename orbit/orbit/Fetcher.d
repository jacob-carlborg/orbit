/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 31, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Fetcher;

import orbit.core._;
import orbit.orbit.Repository;
import orbit.orbit.OrbVersion;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;

private alias orbit.orbit.Repository.Repository Repository;

abstract class Fetcher
{
	const Orbit orbit;
	const Repository repository;
	
	private template Constructor ()
	{
		private this (Repository repository, Orbit orbit)
		{
			super(repository, orbit);
		}
	}
	
	private this (Repository repository, Orbit orbit)
	{
		this.repository = repository;
		this.orbit = orbit;
	}
	
	static Fetcher instance (Repository repository = Repository.defaultRepository, Orbit orbit = Orbit.defaultOrbit)
	{
		orbit = orbit ? orbit : Orbit.defaultOrbit;
		repository = repository ? repository : Repository.defaultRepository;
		
		if (repository.isLocal)
			return new LocalFetcher(repository, orbit);
		
		else
			return new RemoteFetcher(repository, orbit);
	}
	
	abstract void fetch (string name, OrbVersion orbVersion = OrbVersion.invalid);
}

class LocalFetcher : Fetcher
{
	mixin Constructor;
	
	void fetch (string name, OrbVersion orbVersion = OrbVersion.invalid)
	{
		auto address = repository.addressOfOrb(name, orbVersion);
	}
}

class RemoteFetcher : Fetcher
{
	mixin Constructor;
	
	void fetch (string name, OrbVersion orbVersion = OrbVersion.invalid)
	{
		
	}
}