/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 24, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Exceptions;

import orbit.core.string;

class OrbException : Exception
{
	this (string message, string file, long line)
	{
		super(message, file, line);
	}
}

class MissingArgumentException : OrbException
{
	this (string message, string file, long line)
	{
		super(message, file, line);
	}
}

class MissingCommandException : OrbException
{
	this (string message, string file, long line)
	{
		super(message, file, line);
	}
}