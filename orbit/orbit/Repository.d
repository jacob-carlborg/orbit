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
import orbit.net.Http;
import Path = orbit.io.Path;
import orbit.orbit._;

abstract class Repository
{
    @property Orbit orbit() { return orbit_; }
    @property string source() { return source_; }
    @property bool isLocal() { return isLocal_; }
    @property bool isRemote() { return isRemote_; }
    @property Api api() { return api_; }
    @property Index index() { return index_; }
	
	private
	{
		static Repository defaultRepository_;
		string orbsPath_;
        Orbit orbit_;
        string source_;
        bool isLocal_;
        bool isRemote_;
        Api api_;
        Index index_;
	}
	
	private this (string source, Orbit orbit, bool local, Api api)
	{
		this.orbit_ = orbit;
		this.source_ = source;
		this.isLocal_ = local;
		this.isRemote_ = !local;
		this.api_ = api;
		this.index_ = new Index(this, indexPath);
		this.orbsPath_ = join([source, orbit.repository.orbs]);
	}
	
	static Repository instance (string source = "", Orbit orbit = Orbit.defaultOrbit)
	{
		orbit = orbit ? orbit : Orbit.defaultOrbit;
		source = source.isPresent() ? source : orbit.repository.source;
		auto path = Path.toAbsolute(Path.normalize(source));
		
		if (Path.exists(path))
			return new LocalRepository(cast(string) path, orbit);
		
		else
			return new RemoteRepository(source, orbit);
	}
	
	static Repository defaultRepository ()
	{
		return defaultRepository_ ? defaultRepository_ : Repository.instance(Orbit.defaultOrbit.repository.source, Orbit.defaultOrbit);
	}
	
	abstract string join (string[] arr ...);
	
	abstract string addressOfOrb (Orb orb) 
	{
		string fullName;
		
		if (orb.version_.isValid)
			fullName = orb.fullName;
			
		else
		{
			auto orbVersion = api.latestVersion(orb);
			fullName = Orb.buildFullName(orb.name, orbVersion);
		}
		
		auto path = join(orbsPath(), fullName);
		return Path.setExtension(path, Orb.extension);
	}
	
	string toString ()
	{
		return source;
	}

protected:
	
	@property string orbsPath ()
	{
		return orbsPath_;
	}
	
	string indexPath ()
	{
		auto path = join(source, orbit.constants.index);
		return Path.setExtension(path, orbit.constants.indexFormat);
	}
	
public:
	
	static abstract class Api
	{
		private Index index_;
		
		this (Index index)
		{
			this.index_ = index;
		}
		
		abstract void upload (Orb orb);

		Orb[OrbVersion][string] orbs ()
		{
			return index_.orbs;
		}
		
		OrbVersion latestVersion (string name)
		{
			return index_.latestVersion(name);
		}
		
		Orb getOrb (Orb orb)
		{
			return index_[orb];
		}
		
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
		
		throw new MissingOrbException(orb, this, __FILE__, __LINE__);
	}
	
	string join (string[] arr ...)
	{
		return Path.join(arr);
	}
	
	class Api : Repository.Api
	{
		this ()
		{
			super(index);
		}
		
		void upload (Orb orb) 
		{
			auto dest = Path.join(cast(string)source, cast(string)orbit.constants.orbs);
			
			if (!Path.exists(dest))
				Path.createPath(dest);
			
			dest = Path.join(cast(string)dest, cast(string)orb.fullName);
			dest = Path.setExtension(dest, Orb.extension);

			Path.copy(orb.path, dest);
			index.update(orb);
		}
	}
}

class RemoteRepository : Repository
{
	private string indexPath_;
	
	private this (string source, Orbit orbit)
	{
		super(source, orbit, false, new Api);
	}
	
	@property string indexPath ()
	{
		if (indexPath_.any())
			return indexPath_;
		
		auto destination = Path.join(orbit.path.tmp(), orbit.constants.index);
		destination = Path.setExtension(destination, orbit.constants.indexFormat);

		Http.download(super.indexPath, destination);
		
		return indexPath_ = destination;
	}
	
	string addressOfOrb (Orb orb) 
	{
		auto path = super.addressOfOrb(orb);
		
		if (Http.exists(path))
			return path;
		
		throw new MissingOrbException(orb, this, null, __FILE__, __LINE__);
	}
	
	string join (string[] arr ...)
	{
		return cast(string) tango.text.Util.join(arr, "/");
	}
	
	class Api : Repository.Api
	{
		this ()
		{
			super(index);
		}
		
		void upload (Orb orb)
		{
			assert(0, "unimplemented");
		}
	}
}
