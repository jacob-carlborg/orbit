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
	
	string summary;
	string version_;

	string author;
	string bindir;
	string build;
	string date;
	string description;
	string dvm;
	string email;
	string homepage;
	string name;
	string packageType;
	string type;
	string[] buildDependencies;
	string[] executables;
	string[] files;
	string[] imports;
	string[] libraries;
	string[] platforms;
	string[] runtimeDependencies;

	string orbspecPath;
	
	private
	{
		const specEnvContent = import("specification_enviroment.rb");
		SpecificationEnviroment specEnv;
		
		string orbitVersion_;
		string specificationVersion_;
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
		summary = specEnv.summary;
		version_ = specEnv.version_;

		author = specEnv.author;
		bindir = specEnv.bindir;
		build = specEnv.build;
		buildDependencies = specEnv.build_dependencies;
		date = specEnv.date;
		description = specEnv.description;
		dvm = specEnv.dvm;
		email = specEnv.email;
		executables = specEnv.executables;
		files = specEnv.files;
		homepage = specEnv.homepage;
		libraries = specEnv.libraries;
		name = specEnv.name;
		packageType = specEnv.package_type;
		platforms = specEnv.platforms;
		runtimeDependencies = specEnv.runtime_dependencies;
		type = specEnv.type;
	}
}