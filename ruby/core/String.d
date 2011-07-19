/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.core.String;

import ruby.core.Object;
import ruby.util.string;
import tango.stdc.config;

import ruby.c.ruby;
import ruby.c.intern;

struct String
{	
	mixin ObjectImpl;
	
	static String new_ (in char* src, c_long length)
	{
		return String(rb_str_new(src, length));
	}
	
	/*static String new_ (in char* src)
	{
		return String(rb_str_new2(src));
	}*/
	
	static String new_ (string src)
	{
		return new_(src.ptr, src.length);
	}
	
	String dup ()
	{
		return String(rb_str_dup(self));
	}
	
	String opCat (in char* src, c_long length)
	{
		self = rb_str_cat(self, src, length);
		return *this;
	}
	
	String opCat (VALUE other)
	{
		self = rb_str_concat(self, other);
		return *this;
	}
	
	String opCat (string src)
	{
		self = rb_str_cat(self, src.ptr, src.length);
		return *this;
	}
	
	VALUE split (in char* delim)
	{
		return rb_str_split(self, delim);
	}
	
	VALUE split (string delim)
	{
		return rb_str_split(self, (delim ~ '\0').ptr);
	}
	
	string toD ()
	{
		return self != Qnil ? fromStringz(StringValueCStr(self)) : null;
	}
}