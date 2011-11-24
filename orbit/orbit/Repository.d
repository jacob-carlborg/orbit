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
	private const Index index;
	
	private
	{
		static Repository defaultRepository_;
		string orbsPath_;
	}
	
	private this (string source, Orbit orbit, bool local, Api api)
	{
		this.orbit = orbit;
		this.source = source;
		this.isLocal = local;
		this.isRemote = !local;
		this.api = api;
		index = new Index(this);
	}
	
	static Repository instance (string source = "", Orbit orbit = Orbit.defaultOrbit)
	{
		orbit = orbit ? orbit : Orbit.defaultOrbit;
		source = source.isPresent() ? source : orbit.repository.source;
		auto path = Path.toAbsolute(Path.normalize(source));
		
		if (Path.exists(path))
			return new LocalRepository(path, orbit);
		
		else
			return new RemoteRepository(source, orbit);
	}
	
	static Repository defaultRepository ()
	{
		return defaultRepository_ ? defaultRepository_ : Repository.instance(Orbit.defaultOrbit.repository.source, Orbit.defaultOrbit);
	}
	
	abstract string addressOfOrb (Orb orb);	
	abstract string join (string[] arr ...);
	
	string toString ()
	{
		return source;
	}

	protected string orbsPath ()
	{
		return orbsPath_ = orbsPath_.any() ? orbsPath_ : join([source, orbit.repository.orbs]);
	}
	
	static abstract class Api
	{
		abstract void upload (Orb orb);
		abstract Orb[OrbVersion][string] index;
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
		string fullName;

		if (orb.version_.isValid)
			fullName = orb.fullName;
			
		else
		{
			auto orbVersion = api.latestVersion(orb);
			fullName = Orb.buildFullName(orb.name, orbVersion);
		}
		
		auto path = join(orbsPath, fullName);
		path = Path.setExtension(path, Orb.extension);

		if (Path.exists(path))
			return path;
		
		throw new RepositoryException(orb, this, __FILE__, __LINE__);
	}
	
	string join (string[] arr ...)
	{
		return Path.join(arr);
	}
	
	static class Api : Repository.Api
	{
		void upload (Orb orb)
		{
			auto dest = join(source, orbit.constants.orbs);
			
			if (!Path.exists(dest))
				Path.createPath(dest);
			
			dest = join(dest, orb.fullName);
			dest = Path.setExtension(dest, Orb.extension);

			Path.copy(orb.path, dest);
			index.update(orb);
		}
		
		Orb[OrbVersion][string] index ()
		{
			return super.index.index;
		}
		
		OrbVersion latestVersion (string name)
		{
			return index.latestVersion(name);
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
		auto path = join(orbsPath, orb.fullName);
		scope resource = new HttpGet(path);
		resource.open;
		
		if (resource.isResponseOK)
			return path;
		
		throw new RepositoryException(orb, this, null, __FILE__, __LINE__);
	}
	
	string join (string[] arr ...)
	{
		return tango.text.Util.join(arr, "/");
	}
	
	static class Api : Repository.Api
	{
		OrbVersion latestVersion (string name)
		{
			assert(0, "unimplemented");
		}
		
		void upload (Orb orb)
		{
			assert(0, "unimplemented");
		}
	}
}