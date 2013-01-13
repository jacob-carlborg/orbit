/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Orb;

import tango.text.Util;

import mambo.serialization.Serializable;
import mambo.serialization.Events;

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
	
	static immutable string extension = "orb";
		
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
	
	mixin NonSerialized!(fullName_, target_, path_, orbit_, type_, loaded);
	
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

		auto currentWorkingDirectory = Path.workingDirectory;
		
		scope (exit)
			Path.workingDirectory = currentWorkingDirectory;
		
		Path.workingDirectory = Path.join(loader.temporaryPath, orbit.constants.orbData);

		auto orb = new Orb(Specification.load(metaDataPath), orbit);
		orb.path_ = path;
		orb.loaded = true;
		
		return orb;
	}
	
	static Orb load (Orb orb, Repository repository = Repository.defaultRepository, Orbit orbit = Orbit.defaultOrbit)
	{
		if (Path.exists(orb.path))
			return Orb.load(orb.path, orbit);

		scope fetcher = Fetcher.instance(repository);

		if (!orb.version_.isValid)
			orb.version_ = repository.api.latestVersion(orb.name);

		auto tmpOrbPath = orb.defaultTempPath;
		fetcher.fetch(orb, tmpOrbPath);
		
		return Orb.load(tmpOrbPath, orbit);
	}
	
	static Orb parse (string orb, Orbit orbit = Orbit.defaultOrbit)
	{
		auto orbParts = orb.split("-");
		
		if (orbParts.length == 1)
			return new Orb(cast(string)orbParts.first(), OrbVersion.invalid);
		
		auto name = orbParts[0 .. $ - 1].join("-");
		auto version_ = OrbVersion.parse(cast(string)orbParts[$ - 1]);
		
		return new Orb(cast(string)name, version_, orbit);
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
		return version_.isValid ? Orb.buildFullName(name, version_) : name;
	}
	
	Type type ()
	{
		return type_;
	}
	
	string[] buildArgs () const
	{
		//assert(false, "not implemented");
		return null;
	}
	
	string path () const
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
			case Type.dynamicLibrary: return target_ = orbit.dylibName(name);
			case Type.executable: return target_ = orbit.exeName(name);
			case Type.library: return target_ = orbit.libName(name);
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
		return version_.isValid ? fullName : name;
	}
	
	string defaultTempPath ()
	{
		auto path = Path.join(orbit.path.tmp, fullName);
		return Path.setExtension(path, Orb.extension);
	}
	
	string importPath ()
	{
		return Path.join(orbit.path.orbs, fullName, orbit.constants.imports);
	}
	
	string libPath ()
	{
		return Path.join(orbit.path.orbs, fullName, orbit.constants.lib);
	}
	
	string binPath ()
	{
		return Path.join(orbit.path.orbs, fullName, orbit.constants.bin);
	}
	
	string srcPath ()
	{
		return Path.join(orbit.path.orbs, fullName, orbit.constants.src);
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
		buildDependencies = spec.buildDependencies;
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
		orbitVersion = spec.orbitVersion;
		platforms = spec.platforms;
		packageType = spec.packageType;
		runtimeDependencies = spec.runtimeDependencies;
		specificationVersion = spec.specificationVersion;
	}
}
