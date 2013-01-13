/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 24, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Exceptions;

import mambo.core.string;
import orbit.orbit.Exceptions;

class OrbException : OrbitException
{
	template Constructor ()
	{
		this (string message, string file, size_t line)
		{
			super(message, file, line);
		}
	}

	mixin Constructor;
}

class MissingArgumentException : OrbException
{
	mixin Constructor;
}

class MissingCommandException : OrbException
{
	mixin Constructor;
}

class InvalidOptionException : OrbException
{
	mixin Constructor;
}

class InvalidArgumentException : OrbException
{
	mixin Constructor;
}