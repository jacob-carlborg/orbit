/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Dec 7, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.util.Tuple;

Tuple!(Types) tuple (Types ...) (Types values)
{
	Tuple!(Types) t;
	t.values = values;
	
	return t;
}

struct Tuple (Types ...)
{
	Types values;
}
