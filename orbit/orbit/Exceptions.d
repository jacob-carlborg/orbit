/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 25, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Exceptions;

import orbit.core.string;

class OrbitException : Exception
{
	this (string message, string file = "", long line = 0)
	{
		super(message, file, line);
	}
}