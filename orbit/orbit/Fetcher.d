/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 31, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Fetcher;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.net.Http;
import orbit.orbit.Repository;
import orbit.orbit.Orb;
import orbit.orbit.OrbVersion;
import orbit.orbit.Orbit;
import orbit.orbit.OrbitObject;

abstract class Fetcher
{
    @property Orbit orbit() { return orbit_; }
    @property Repository repository() { return repository_; }

    private 
    {
    	Orbit orbit_;
    	Repository repository_;
    }
	
	private template Constructor ()
	{
		private this (Repository repository, Orbit orbit)
		{
			super(repository, orbit);
		}
	}
	
	private this (Repository repository, Orbit orbit)
	{
		this.repository_ = repository;
		this.orbit_ = orbit;
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
	
	abstract void fetch (Orb orb, string output = null);
}

class LocalFetcher : Fetcher
{
	mixin Constructor;
	
	void fetch (Orb orb, string output = null)
	{
		auto source = repository.addressOfOrb(orb);

		if (output.isBlank())
 			output = Path.join([cast(string)Path.workingDirectory, cast(string)orb.name]);
		
		Path.copy(source, output);
	}
}

class RemoteFetcher : Fetcher
{
	mixin Constructor;
	
	void fetch (Orb orb, string output = null)
	{
		auto source = repository.addressOfOrb(orb);

		if (output.isBlank)
			output = Path.join(cast(string) Path.workingDirectory, orb.name);
		
		Http.download(source, output);
	}
}
