/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.dsl.ruby.SpecificationEnviroment;

import tango.text.Util;

import ruby.core.Object;
import ruby.core.Binding;
import ruby.core.String;
import ruby.core.Array;
import ruby.util.string;

struct SpecificationEnviroment
{
	mixin ObjectImpl;
	
	string summary ()
	{
		return String(call("summary")).toD;
	}
	
	string version_ ()
	{
		return String(call("version")).toD;
	}
	
	string author ()
	{
		return String(call("author")).toD;
	}

	string build ()
	{
		return String(call("build")).toD;
	}

	string[] build_dependencies ()
	{
		return Array(call("build_dependencies")).toStringArray;
	}

	string date ()
	{
		return String(call("date")).toD;
	}

	string description ()
	{
		return String(call("description")).toD;
	}

	string dvm ()
	{
		return String(call("dvm")).toD;
	}

	string email ()
	{
		return String(call("email")).toD;
	}

	string[] executables ()
	{
		return Array(call("executables")).toStringArray;
	}

	string[] files ()
	{
		// ugly workaround for a problem that seems related to
		// Ruby in combination with D and the Tango zip module
		//auto result = String(call("files")).toD;
		//return result.split(",");
		
		return Array(call("files")).toStringArray;
	}

	string homepage ()
	{
		return String(call("homepage")).toD;
	}

	string[] libraries ()
	{
		return Array(call("libraries")).toStringArray;
	}

	string name ()
	{
		return String(call("name")).toD;
	}

	string orbit_version ()
	{
		return String(call("orbit_version")).toD;
	}

	string[] platforms ()
	{
		return Array(call("platforms")).toStringArray;
	}

	string package_type ()
	{
		return String(call("package_type")).toD;
	}

	string[] runtime_dependencies ()
	{
		return Array(call("runtime_dependencies")).toStringArray;
	}

	string specification_version ()
	{
		return String(call("specification_version")).toD;
	}

	string type ()
	{
		return String(call("type")).toD;
	}
	
	Binding get_binding ()
	{
		return cast(Binding) call("get_binding");
	}
}