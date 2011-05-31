/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.dsl.ruby.SpecificationEnviroment;

import ruby.core.Object;
import ruby.core.Binding;
import ruby.core.String;
import ruby.core.Array;

struct SpecificationEnviroment
{
	mixin ObjectImpl;
	
	string name ()
	{
		auto str = cast(String) call("name");
		return str.get;
	}
	
	string summary ()
	{
		auto str = cast(String) call("summary");
		return str.get;
	}
	
	string version_ ()
	{
		auto str = cast(String) call("version");
		return str.get;
	}
	
	Binding get_binding ()
	{
		return cast(Binding) call("get_binding");
	}
}