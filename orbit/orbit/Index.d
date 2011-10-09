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
import orbit.orbit.Orb;
import orbit.orbit.Orbit;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

class Index
{
	const LocalRepository repository;
	
	private
	{
		const string path;
		
		Orb[string][string] orbs;
		XmlArchive!() archive;
		Serializer serializer;
	}
	
	this (LocalRepository repository)
	{
		this.repository = repository;
		this.path = repository.join(repository.source, repository.orbit.constants.index);
		
		archive = new XmlArchive!();
		serializer = new Serializer(archive);
	}
	
	void update (Orb orb)
	{
		if (!Path.exists(path))
			create(orb);
		
		else
		{
			orbs = serializer.deserialize!(typeof(orbs))(File.get(path));
			orbs[orb.name][orb.version_.toString] = orb;
		}
		
		write;
	}
	
private:
	
	void create (Orb orb)
	{
		orbs = [orb.name : [orb.version_.toString : orb]];
	}
	
	void write ()
	{
		serializer.reset;
		auto index = serializer.serialize(orbs);
		File.set(path, index);
	}
	
	// Orb[OrbVersion] oldOrbs (Orb orb)
	// {
	// 	if (auto oldOrbs = orb.name in orbs)
	// 		return *oldOrbs;
	// 	
	// 	else
	// 		return [];
	// }
}