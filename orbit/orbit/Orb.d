/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orb;

import Zip = tango.util.compress.Zip : extractArchive;

import orbit.core._;
import orbit.dsl.Specification;
import orbit.io.Path;
import orbit.orbit.Builder;
import orbit.orbit.Loader;
import orbit.orbit.Orbit;
import orbit.orbit.OrbVersion;

class Orb
{
	enum Type
	{
		bindings,
		dynamicLibrary,
		executable,
		library,
		source,
	}
	
	const Specification specification;
	const Orbit orbit;
	const OrbVersion version_;
	
	private
	{
		string fullName_;
		Type type_ = Type.library;
		string target_;
		string path_;
	}
	
	this (Orbit orbit, Specification spec)
	{
		this.orbit = orbit;
		specification = spec;
		version_ = OrbVersion.parse(spec.version_);
	}
	
	static Orb load (string path, Orbit orbit = Orbit.defaultOrbit)
	{
		scope loader = new Loader(orbit);
		loader.load(path);
		auto metaDataPath = join(loader.temporaryPath, orbit.constants.orbMetaData);

		auto orb = new Orb(orbit, Specification.load(metaDataPath));
		orb.path_ = path;
		
		return orb;
	}
	
	string name ()
	{
		return specification.name;
	}
	
	string fullName ()
	{
		return fullName_ = fullName_.any() ? fullName_ : name ~ "-" ~ version_.toString;
	}
	
	Builder.Tool buildTool () 
	{
		return orbit.spec.defaultBuildTool;
	}
	
	Type type ()
	{
		return type_;
	}
	
	Orb[] dependencies ()
	{
		assert(false, "not implemented");
		return [];
	}
	
	string[] files ()
	{
		return specification.files;
	}
	
	string[] buildArgs ()
	{
		//assert(false, "not implemented");
		return [""];
	}
	
	string path ()
	{
		return path_;
	}
	
	/// returns the target name, i.e. libname.a if the type is a library
	string target ()
	{
		if (target_.any())
			return target_;
		
		switch (type)
		{
			case Type.bindings: return target_ = name;
			case Type.dynamicLibrary: return target_ = orbit.constants.dylibPrefix ~ name ~ orbit.constants.dylibExtension;
			case Type.executable: return target_ = name ~ orbit.constants.exeExtension;
			case Type.library: return target_ = orbit.constants.libPrefix ~ name ~ orbit.constants.libExtension;
			case Type.source: return target_ = name;
		}
	}
}