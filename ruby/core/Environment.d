/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.core.Environment;

import ruby.c.intern;
import ruby.c.ruby;
import ruby.util.string;

class Environment
{
	static this ()
	{
		ruby_init;
		ruby_init_loadpath;
	}
	
	static ~this ()
	{
		ruby_cleanup(0);
	}
	
	VALUE eval (string code)
	{
		return rb_eval_string(code.toStringz());
	}

	VALUE getVariable (string name)
	{
		return rb_gv_get(name.toStringz());
	}
	
	VALUE setVariable (string name, VALUE value)
	{
		return rb_gv_set(name.toStringz(), value);
	}
	
	VALUE opIndex (string name)
	{
		return getVariable(name);
	}
	
	VALUE opIndexAssign (VALUE value, string name)
	{
		return setVariable(name, value);
	}
	
	void* load (string file)
	{
		return rb_load_file(file.toStringz());
	}
	
	VALUE getClass (string name)
	{
		return rb_path2class(name.toStringz());
	}
}