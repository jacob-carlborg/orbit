/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.core.Object;

import ruby.c.ruby;
import ruby.c.intern;
import ruby.util.string;

template ObjectImpl ()
{
	import ruby.util.string;
	import ruby.util.Array;
	import ruby.c.ruby;
	import ruby.c.intern;
	
	VALUE self;
	
	invariant ()
	{
		//assert(RTEST(self));
	}
	
	static typeof(this) opCall (VALUE rubyObject)
	{
		//assert(RTEST(rubyObject), `Tried to create a new "` ~ typeof(*this).stringof ~ `" with an nil value.`);
		typeof(this) object;
		object.self = rubyObject;
		
		return object;
	}
	
	static typeof(this) opCall (RubyObject rubyObject)
	{
		//assert(RTEST(rubyObject.self), `Tried to create a new "` ~ typeof(*this).stringof ~ `" with an nil value.`);
		typeof(this) object;
		object.self = rubyObject.self;
		
		return object;
	}
	
	static typeof(this) new_ (VALUE[] args ...)
	{
		return typeof(this)(rb_class_new_instance(cast(int)args.length, args.ptr, rb_path2class(this.stringof.ptr)));
	}
	
	bool respond_to (ID method)
	{
		return rb_respond_to(self, method) != 0;
	}
	
	bool instance_of (VALUE klass)
	{
		return rb_obj_is_instance_of(self, klass) == Qtrue;
	}
	
	bool kind_of (VALUE klass)
	{
		return rb_obj_is_kind_of(self, klass) == Qtrue;
	}
	
	alias kind_of is_a;
	
	RubyObject send (Args ...) (string name, Args args)
	{
		VALUE[] rubyArgs;
		rubyArgs.reserve(Args.length);
		
		foreach (i, arg ; args)
			static if (is(typeof(Args[i]) == VALUE))
				rubyArgs ~= arg;
			
			else
				rubyArgs ~= arg.self;

		auto result = rb_funcall2(self, rb_intern(name.toStringz()), rubyArgs.length, rubyArgs.ptr);
		//assert(RTEST(result), `The method call "` ~ name ~ `" returned an invalid result.`);

		return RubyObject();
	}

	RubyObject call (Args ...) (string name, Args args)
	{
		VALUE[] rubyArgs;
		rubyArgs.reserve(Args.length);
		
		foreach (i, arg ; args)
			static if (is(Args[i] == VALUE))
				rubyArgs ~= arg;
			
			else
				rubyArgs ~= arg.self;

		auto result = rb_funcall3(self, rb_intern(name.toStringz()), cast(int)rubyArgs.length, rubyArgs.ptr);
		//assert(RTEST(result), `The method call "` ~ name ~ `" returned an invalid result.`);

		return RubyObject(result);
	}
	
	bool nil ()
	{
		return cast(bool) NIL_P(self);
	}
}

struct RubyObject
{
	mixin ObjectImpl;
}
