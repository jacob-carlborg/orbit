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

		string name_;
		string summary_;
		string version__;
		string[] files_;
		string orbspecPath_;
	}
	
	static Specification load (string file)
	{
		mixin RUBY_INIT_STACK;
		scope env = new Environment;

		auto content = cast(string) File.get(file);
		env.eval(specEnvContent);

		auto specEnv = SpecificationEnviroment.new_;
		auto binding = specEnv.get_binding;

		binding.eval(content);
		auto spec = new Specification(specEnv);
		spec.orbspecPath_ = Path.toAbsolute(file);

		return setSpecValues(spec, specEnv);
	}
	
	private this (SpecificationEnviroment specEnv)
	{
		this.specEnv = specEnv;
	}
	
	string[] files ()
	{
		return files_;
	}
	
	string name ()
	{
		return name_;
	}
	
	string summary ()
	{
		return summary_;
	}
	
	/// The version of the orb package
	string version_ ()
	{
		return version__;
	}
	
	string date ()
	{
		return null;
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
	
	string toYaml ()
	{
		auto yaml = format("--- !d/object: {}\nname: {}\nversion: {}\nsummary: {}\nbuild: {}\nfiles:\n",
							this.classinfo.name, name, version_, summary);
		
		foreach (file ; files)
			yaml ~= format("    - {}\n", file);
			
		return yaml;
	}
	
	private static Specification setSpecValues (Specification spec, SpecificationEnviroment specEnv)
	{
		spec.name_ = specEnv.name;
		spec.summary_ = specEnv.summary;
		spec.version__ = specEnv.version_;
		spec.files_ = specEnv.files;

		return spec;
	}
}