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
import ruby.core.String;

import orbit.core._;

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
		auto ptr = RARRAY_PTR(self);
		
		for (size_t i = 0; i < length; i++, ptr++)
		{
			result = dg(RubyObject(*ptr));
			
			if (result)
				break;
		}
		
		// for (size_t i = 0; i < length; i++)
		// {
		// 	result = dg(RubyObject(RARRAY_PTR(self)[i]));
		// 	
		// 	if (result)
		// 		break;
		// }
		
		return result;
	}
	
	string[] toStringArray ()
	{
		string[] result;
		result.reserve(length);

		size_t len = RARRAY_LEN(self);
		auto ptr = RARRAY_PTR(self);
		
		for (size_t i = 0; i < len; i++, ptr++)
		{
			auto str = *ptr;
			size_t strLen = RSTRING_LEN(str);
			auto f = StringValuePtr(str)[0 .. strLen].dup;
			result ~= f;
		}
		
		// foreach (e ; *this)
		// 	result ~= String(e).toD;
		return result.dup;
	}
}