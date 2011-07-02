/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 18, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */

module ruby.core.Binding;

import ruby.c.ruby;
import ruby.core.Object;
import ruby.core.String;
import ruby.util.string;

struct Binding
{
	mixin ObjectImpl;

	void eval (string str, string filename = null, int lineno = int.min)
	{
		auto name = filename ? String.new_(filename).self : Qnil;
		auto line = lineno != int.min ? INT2FIX(lineno) : Qnil;

		call("eval", String.new_(str));
	}
}