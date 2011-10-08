/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Sep 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Repository;

import tango.net.http.HttpGet;
import tango.text.Util;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit._;

abstract class Repository
{
	const Orbit orbit;
	const string source;
	const bool isLocal;
	const bool isRemote;
	const Api api;
	
	private
	{
		static Repository defaultRepository_;
	}
	
	private this (string source, Orbit orbit, bool local, Api api)
	{
		this.orbit = orbit;
		this.source = source;
		this.isLocal = local;
		this.isRemote = !local;
		this.api = api;
	}
	
	static Repository instance (string source = "", Orbit orbit = Orbit.defaultOrbit)
	{
		orbit = orbit ? orbit : Orbit.defaultOrbit;
		source = source.isPresent() ? source : orbit.repository.source;
		
		if (local(source, orbit))
			return new LocalRepository(source, orbit);
		
		else
			return new RemoteRepository(source, orbit);
	}
	
	private static bool local (string source, Orbit orbit)
	{
		auto len = orbit.repository.fileProtocol.length;
		return source.length > len && source[0 .. len] == orbit.repository.fileProtocol;
	}
	
	static Repository defaultRepository ()
	{
		return defaultRepository_ ? defaultRepository_ : Repository.instance(Orbit.defaultOrbit.repository.source, Orbit.defaultOrbit);
	}
	
	abstract string addressOfOrb (Orb orb)
	{
		return join([source, orbit.repository.orbs, orb.fullName]);
	}
	
	abstract string join (string[] arr);
	
	string toString ()
	{
		return source;
	}
	
static:
	
	abstract class Api
	{
		abstract void upload (Orb orb);
		abstract OrbVersion latestVersion (string name);
		
		OrbVersion latestVersion (Orb orb)
		{
			return latestVersion(orb.name);
		}
	}
}

class LocalRepository : Repository
{
	private this (string source, Orbit orbit)
	{
		super(source, orbit, true, new Api);
	}
	
	string addressOfOrb (Orb orb)
	{
		auto path = super.addressOfOrb(orb);
		
		if (Path.exists(path))
			return path;
		
		throw new RepositoryException(orb, this, null, __FILE__, __LINE__);
	}
	
	string join (string[] arr)
	{
		return Path.join(arr);
	}
	
	private void updateIndex ()
	{
		scope index = new Index(this);
		index.update;
	}
	
	class Api : Repository.Api
	{
		void upload (Orb orb)
		{
			auto dest = join(source, orbit.constants.orbs, orb.fullName);
			Path.copy(orb.path, dest);
			updateIndex;
		}
		
		OrbVersion latestVersion (string name)
		{
			return OrbVersion.invalid;
		}
	}
}

class RemoteRepository : Repository
{
	private this (string source, Orbit orbit)
	{
		super(source, orbit, false, new Api);
	}
	
	string addressOfOrb (Orb orb)
	{
		auto path = super.addressOfOrb(orb);
		scope resource = new HttpGet(path);
		resource.open;
		
		if (resource.isResponseOK)
			return path;
		
		throw new RepositoryException(orb, this, null, __FILE__, __LINE__);
	}
	
	string join (string[] arr)
	{
		return tango.text.Util.join(arr, "/");
	}
	
static:
	
	class Api : Repository.Api
	{
		OrbVersion latestVersion (string name)
		{
			return OrbVersion.invalid;
		}
	}
}