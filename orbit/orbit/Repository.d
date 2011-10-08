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
	
	private
	{
		static Repository defaultRepository_;
	}
	
	private this (string source, Orbit orbit, bool local)
	{
		this.orbit = orbit;
		this.source = source;
		this.isLocal = local;
		this.isRemote = !local;
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
		println(orb.fullName);
		return join([source, orbit.repository.orbs, orb.fullName], "/");
	}
	
	string toString ()
	{
		return source;
	}
}

class LocalRepository : Repository
{
	private this (string source, Orbit orbit)
	{
		super(source, orbit, true);
	}
	
	string addressOfOrb (Orb orb)
	{
		auto path = super.addressOfOrb(orb);
		
		if (Path.exists(path))
			return path;
		
		throw new RepositoryException(orb, this, null, __FILE__, __LINE__);
	}
}

class RemoteRepository : Repository
{
	private this (string source, Orbit orbit)
	{
		super(source, orbit, false);
	}
	
	string addressOfOrb (Orb orb)
	{
		auto path = super.addressOfOrb(orb);
		scope resource = new HttpGet(path);
		resource.open;
		
		if (resource.isResponseOK)
			return path;
		
		throw new RepositoryException(orb, this, "", __FILE__, __LINE__);
	}
}