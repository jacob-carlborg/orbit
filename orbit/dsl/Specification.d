/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 16, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.dsl.Specification;

import ruby.c.ruby;
import ruby.c.intern;
import ruby.core.Environment;
import ruby.core.Object;
import ruby.core.String;

import tango.io.device.File;

import orbit.core._;
import orbit.dsl.ruby._;

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
		string filename_;
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

		return setSpecValues(new Specification(specEnv), specEnv);
	}
	
	private this (SpecificationEnviroment specEnv)
	{
		this.specEnv = specEnv;
	}
	
	string[] files ()
	{
		return ["/Users/doob/development/eclipse_workspace/orbit/src/test.orbspec"[]];
	}
	
	string name ()
	{
		return name_;
	}
	
	string summary ()
	{
		return summary_;
	}
	
	string version_ ()
	{
		return version__;
	}
	
	string date ()
	{
		return null;
	}
	
	string orbitVersion ()
	{
		return null;
	}
	
	string specificationVersion ()
	{
		return null;
	}
	
	string filename ()
	{
		return filename_;
	}
	
	private static Specification setSpecValues (Specification spec, SpecificationEnviroment specEnv)
	{
		spec.name_ = specEnv.name;
		spec.summary_ = specEnv.summary;
		spec.version__ = specEnv.version_;
		
		return spec;
	}
}