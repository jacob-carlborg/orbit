/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 26, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.commands.Build;

import orbit.core._;
import orbit.dsl.Specification;
import orbit.orbit.Builder;

import orbit.orb.Command;

class Build : Command
{
	private string name;
	
	this (string name, string summary = "")
	{
		super(name, summary);
	}
	
	this ()
	{
		super("build", "Build an orb from an orbspec");
	}
	
	void execute ()
	{
		auto spec = Specification.load("/Users/doob/development/eclipse_workspace/orbit/src/test.orbspec");
		auto builder = new Builder(spec, "/Users/doob/development/eclipse_workspace/orbit/src/test.zip");
		builder.build;
	}
}