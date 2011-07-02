/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.core.Hash;

import ruby.core.Object;
import ruby.c.intern;
import ruby.c.ruby;

struct Hash
{	
	mixin ObjectImpl;
	
	static Hash new_ ()
	{
		return Hash(rb_hash_new);
	}
	
	VALUE opIndex (VALUE key)
	{
		return rb_hash_aref(self, key);
	}
	
	VALUE opIndexAssign (VALUE value, VALUE key)
	{
		return rb_hash_aset(self, key, value);
	}
}