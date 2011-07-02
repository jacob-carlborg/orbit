/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.core.Array;

import tango.stdc.config;
import tango.sys.win32.Types;

import ruby.c.intern;
import ruby.c.ruby;
import ruby.core.Object;

struct Array
{
	mixin ObjectImpl;

	static Array new_ ()
	{
		return Array(rb_ary_new);
	}
	
	static Array new_ (c_long length)
	{
		return Array(rb_ary_new2(length));
	}
	
	/*Array new_ (Args...) (c_long length, Args args)
	{
		return Array(rb_ary_new3(length, args));
	}*/
	
	static Array new_ (c_long length, VALUE* values)
	{
		return Array(rb_ary_new4(length, values));
	}
	
	void opIndexAssign (VALUE value, c_long index)
	{
		rb_ary_store(self, index, value);
	}
	
	VALUE push (VALUE value)
	{
		return rb_ary_push(self, value);
	}
	
	VALUE pop ()
	{
		return rb_ary_pop(self);
	}
	
	VALUE shift ()
	{
		return rb_ary_shift(self);
	}
	
	VALUE unshift (VALUE value)
	{
		return rb_ary_unshift(self, value);
	}
	
	VALUE opIndex (c_long index)
	{
		return rb_ary_entry(self, index);
	}
	
	size_t length ()
	{
		return RARRAY_LEN(self);
	}
	
	int opApply (int delegate (ref RubyObject) dg)
	{
		int result = 0;
		
		for (size_t i = 0; i < RARRAY_LEN(self); i++)
		{
			result = dg(RubyObject(RARRAY_PTR(self)[i]));
			
			if (result)
				break;
		}
		
		return result;
	}
}

