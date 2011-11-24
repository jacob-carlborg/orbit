/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orb;

import tango.text.Util;

import orange.serialization.Serializable;
import orange.serialization.Events;

import orbit.core._;
import orbit.dsl.Specification;
import Path = orbit.io.Path;
import orbit.orbit.Builder;
import orbit.orbit.Fetcher;
import orbit.orbit.Loader;
import orbit.orbit.Orbit;
import orbit.orbit.OrbVersion;
import orbit.orbit.Repository;

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
	
	static const extension = "orb";
		
	Builder.Tool buildTool;
	
	string summary;
	OrbVersion version_;

	string author;
	string bindir;
	string build;
	string[] buildDependencies;
	string date;
	string description;
	string dvm;
	string email;
	string[] executables;
	string[] files;
	string homepage;
	string[] imports;
	string[] libraries;
	string name;
	string orbitVersion;
	string[] platforms;
	string packageType;
	string[] runtimeDependencies;
	string specificationVersion;
	//string type;
	
	private
	{		
		string fullName_;
		string target_;
		string path_;

		Orbit orbit_;
		Type type_ = Type.executable;
		bool loaded;
	}
	
	mixin NonSerialized!(orbit_, fullName_, target_, path_, type_);
	
	this (Orbit orbit = Orbit.defaultOrbit)
	{
		orbit_ = orbit;
	}
	
	this (string name, string version_, Orbit orbit = Orbit.defaultOrbit)
	{
		this(name, OrbVersion.parse(version_), orbit);
	}
	
	this (string name, OrbVersion version_, Orbit orbit = Orbit.defaultOrbit)
	{
		this(orbit);
		
		this.name = name;
		this.version_ = version_;
	}
	
	this (Specification spec, Orbit orbit = Orbit.defaultOrbit)
	{
		this(orbit);
		setValues(spec);
	}
	
	private void deserializing ()
	{
		orbit_ = Orbit.defaultOrbit;
	}
	
	mixin OnDeserializing!(deserializing);
	
	static Orb load (string path, Orbit orbit = Orbit.defaultOrbit)
	{
		scope loader = new Loader(orbit);
		loader.load(path);
		auto metaDataPath = Path.join(loader.temporaryPath, orbit.constants.orbMetaData);

		auto orb = new Orb(Specification.load(metaDataPath), orbit);
		orb.path_ = path;
		orb.loaded = true;
		
		return orb;
	}
	
	static Orb load (Orb orb, string source = "", Orbit orbit = Orbit.defaultOrbit)
	{
		if (Path.exists(orb.path))
			return Orb.load(orb.path, orbit);
			
		scope repository = Repository.instance(source);
		scope fetcher = Fetcher.instance(repository);
		auto orbPath = orb.defaultTempPath;
		
		fetcher.fetch(orb, orbPath);
		
		return Orb.load(orbPath, orbit);
	}
	
	static Orb parse (string orb, Orbit orbit = Orbit.defaultOrbit)
	{
		auto orbParts = orb.split("-");
		
		if (orbParts.length == 1)
			return new Orb(orbParts.first(), OrbVersion.invalid);
		
		auto name = orbParts[0 .. $ - 1].join("-");
		auto version_ = OrbVersion.parse(orbParts[$ - 1]);
		
		return new Orb(name, version_, orbit);
	}
	
	static string buildFullName (string name, OrbVersion version_)
	{
		return name ~ "-" ~ version_.toString;
	}
	
	Orbit orbit ()
	{
		return orbit_;
	}
	
	bool isLoaded ()
	{
		return loaded;
	}
	
	string fullName ()
	{
		return fullName_ = fullName_.any() ? fullName_ : Orb.buildFullName(name, version_);
	}
	
	Type type ()
	{
		return type_;
	}
	
	string[] buildArgs ()
	{
		//assert(false, "not implemented");
		return null;
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
			default: return "";
		}
	}
	
	string target (string target)
	{
		return target_ = target_;
	}
	
	string toString ()
	{
		return fullName;
	}
	
	string defaultTempPath ()
	{
		auto name = version_.isValid ? fullName : this.name;
		auto path = Path.join(orbit.path.tmp, name);
		return Path.setExtension(path, Orb.extension);
	}
	
private:
	
	void setValues (Specification spec)
	{
		if (!spec.build)
			buildTool = orbit.spec.defaultBuildTool;
			
		else
			buildTool = Builder.toBuilder(spec.build);

		summary = spec.summary;
		version_ = OrbVersion.parse(spec.version_);

		author = spec.author;
		bindir = spec.bindir;
		build = spec.build;
		buildDependencies = spec.build_dependencies;
		date = spec.date;
		description = spec.description;
		dvm = spec.dvm;
		email = spec.email;
		executables = spec.executables;
		files = spec.files;
		homepage = spec.homepage;
		imports = spec.imports;
		libraries = spec.libraries;
		name = spec.name;
		orbitVersion = spec.orbit_version;
		platforms = spec.platforms;
		packageType = spec.package_type;
		runtimeDependencies = spec.runtime_dependencies;
		specificationVersion = spec.specification_version;
	}
}