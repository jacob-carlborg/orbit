/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 16, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.dsl.Specification;

import tango.io.device.File;
import tango.text.convert.Format : format = Format;

import ruby.c.ruby;
import ruby.c.intern;
import ruby.core.Environment;
import ruby.core.Object;
import ruby.core.String;

import orbit.core._;
import orbit.dsl.ruby._;
import Path = orbit.io.Path;

class Specification
{
	static const extension = "orbspec";
	
	private
	{
		const specEnvContent = import("specification_enviroment.rb");
		SpecificationEnviroment specEnv;
		
		string summary_;
		string version__;

		string author_;
		string build_;
		string bindir_;
		string[] build_dependencies_;
		string date_;
		string description_;
		string dvm_;
		string email_;
		string[] executables_;
		string[] files_;
		string homepage_;
		string[] imports_;
		string[] libraries_;
		string name_;
		string orbit_version_;
		string[] platforms_;
		string package_type_;
		string[] runtime_dependencies_;
		string specification_version_;
		string type_;

		string orbspecPath_;
	}
	
	static Specification load (string path)
	{
		mixin RUBY_INIT_STACK;
		scope env = new Environment;

		auto content = cast(string) File.get(path);
		env.eval(specEnvContent);

		auto specEnv = SpecificationEnviroment.new_;
		auto binding = specEnv.get_binding;

		binding.eval(content);
		return new Specification(specEnv, path);
	}
	
	this ()
	{
		
	}
	
	private this (SpecificationEnviroment specEnv, string path)
	{
		this.specEnv = specEnv;
		orbspecPath = Path.toAbsolute(path);
		setSpecValues;
	}
	
	string summary ()
	{
		return summary_;
	}

	string summary (string summary)
	{
		return summary_ = summary;
	}

	string version_ ()
	{
		return version__;
	}

	string version_ (string version_)
	{
		return version__ = version_;
	}

	string author ()
	{
		return author_;
	}

	string author (string author)
	{
		return author_ = author;
	}
	
	string bindir ()
	{
		return bindir_;
	}
	
	string bindir (string bindir)
	{
		return bindir_ = bindir;
	}

	string build ()
	{
		return build_;
	}

	string build (string build)
	{
		return build_ = build;
	}

	string[] build_dependencies ()
	{
		return build_dependencies_;
	}

	string[] build_dependencies (string[] build_dependencies)
	{
		return build_dependencies_ = build_dependencies;
	}

	string date ()
	{
		return date_;
	}

	string date (string date)
	{
		return date_ = date;
	}

	string description ()
	{
		return description_;
	}

	string description (string description)
	{
		return description_ = description;
	}

	string dvm ()
	{
		return dvm_;
	}

	string dvm (string dvm)
	{
		return dvm_ = dvm;
	}

	string email ()
	{
		return email_;
	}

	string email (string email)
	{
		return email_ = email;
	}

	string[] executables ()
	{
		//return executables_;
		return ["orb"];
	}

	string[] executables (string[] executables)
	{
		return executables_ = executables;
	}

	string[] files ()
	{
		return files_;
	}

	string[] files (string[] files)
	{
		return files_ = files;
	}

	string homepage ()
	{
		return homepage_;
	}

	string homepage (string homepage)
	{
		return homepage_ = homepage;
	}

	string[] imports ()
	{
		return imports_;
	}
	
	string[] imports (string[] imports)
	{
		return imports_ = imports;
	}

	string[] libraries ()
	{
		return libraries_;
	}

	string[] libraries (string[] libraries)
	{
		return libraries_ = libraries;
	}

	string name ()
	{
		return name_;
	}

	string name (string name)
	{
		return name_ = name;
	}

	string orbit_version ()
	{
		return orbit_version_;
	}

	string orbit_version (string orbit_version)
	{
		return orbit_version_ = orbit_version;
	}

	string[] platforms ()
	{
		return platforms_;
	}

	string[] platforms (string[] platforms)
	{
		return platforms_ = platforms;
	}

	string package_type ()
	{
		return package_type_;
	}

	string package_type (string package_type)
	{
		return package_type_ = package_type;
	}

	string[] runtime_dependencies ()
	{
		return runtime_dependencies_;
	}

	string[] runtime_dependencies (string[] runtime_dependencies)
	{
		return runtime_dependencies_ = runtime_dependencies;
	}

	string specification_version ()
	{
		return specification_version_;
	}

	string specification_version (string specification_version)
	{
		return specification_version_ = specification_version;
	}

	string type ()
	{
		return type_;
	}
	
	string type (string type)
	{
		return type_ = type;
	}
	
	/// The version of orbit this specification was created with
	string orbitVersion ()
	{
		return null;
	}
	
	/// The version this specification is written in
	string specificationVersion ()
	{
		return null;
	}
	
	/// The path to the orbspec file that this instance represents
	string orbspecPath ()
	{
		return orbspecPath_;
	}
	
	private string orbspecPath (string path)
	{
		return orbspecPath_ = path;
	}
	
	string toYaml ()
	{
		auto yaml = format("--- !d/object: {}\nname: {}\nversion: {}\nsummary: {}\nbuild: {}\nfiles:\n",
							this.classinfo.name, name, version_, summary);
		
		foreach (file ; files)
			yaml ~= format("    - {}\n", file);
			
		return yaml;
	}
	
	string toOrbspec ()
	{
		return null;
	}
	
	private void setSpecValues ()
	{
		name = specEnv.name;
		summary = specEnv.summary;
		version_ = specEnv.version_;
		executables_ = specEnv.executables;
		files_ = specEnv.files;
		bindir_ = specEnv.bindir;
		build_ = specEnv.build;
	}
}
