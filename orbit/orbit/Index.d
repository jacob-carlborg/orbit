/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 8, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Index;

import tango.io.device.File;

import orange.serialization._;
import orange.serialization.archives._;

import orbit.core._;
import Path = orbit.io.Path;
import orbit.orbit.Exceptions;
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

class Index
{
	const Repository repository;
	
	private
	{
		const string path;
		
		Orb[OrbVersion][string] orbs_;
		XmlArchive!() archive;
		Serializer serializer;
	}
	
	this (Repository repository)
	{
		this.repository = repository;
		this.path = repository.join(repository.source,
				repository.orbit.constants.index ~
				"." ~ repository.orbit.constants.indexFormat);
		
		archive = new XmlArchive!();
		serializer = new Serializer(archive);
	}
	
	void update (Orb orb)
	{
		if (!Path.exists(path))
			create(orb);
		
		else
		{
			auto oldOrbs = orbs;
			oldOrbs[orb.name][orb.version_] = orb;
			orbs = oldOrbs;
		}
		
		write;
	}
	
	OrbVersion latestVersion (string name)
	{
		if (auto orb = name in orbs)
		{
			auto versions = orb.keys;
			return versions.sort.last();
		}
		
		auto orb = new Orb(name, OrbVersion.invalid, repository.orbit);
		throw new MissingOrbException(orb, repository, __FILE__, __LINE__);
	}

	Orb opIndex (Orb orb)
	{
		if (auto t = orb.name in orbs)
			if (auto o = orb.version_ in *t)
				return *o;
				
		throw new MissingOrbException(orb, repository, __FILE__, __LINE__);
	}
	
	Orb[OrbVersion][string] orbs ()
	{
		return orbs_ = isLoaded ? orbs_ : load;
	}
	
private:
	
	Orb[OrbVersion][string] orbs (Orb[OrbVersion][string] orbs)
	{
		return orbs_ = orbs;
	}
	
	void create (Orb orb)
	{
		orbs = [orb.name : [orb.version_ : orb]];
	}
	
	void write ()
	{
		serializer.reset;
		auto index = serializer.serialize(orbs);
		File.set(path, index);
	}
	
	Orb[OrbVersion][string] load ()
	{
		return serializer.deserialize!(Orb[OrbVersion][string])(File.get(path));
	}
	
	bool isLoaded ()
	{
		return orbs_ !is null;
	}
}