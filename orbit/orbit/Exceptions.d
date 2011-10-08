/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 25, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Exceptions;

import orbit.orbit.Orb;
import orbit.orbit.Repository;
import orbit.core.string;

class OrbitException : Exception
{
	this (string message, string file = "", long line = 0)
	{
		super(message, file, line);
	}
}

class RepositoryException : OrbitException
{
	const Orb orb;
	const Repository repository;
	
	this (Orb orb, Repository repository, string message = "", string file = "", long line = 0)
	{
		this.orb = orb;
		this.repository = repository;
		auto msg = message.isPresent() ? message : toString;
		
		super(msg, file, line);
	}
	
	this (Orb orb, Repository repository, string file, long line)
	{
		this(orb, repository, null, file, line);
	}
	
	string toString ()
	{
		return format(`The orb "{}" is not available in the repository "{}".`, orb, repository);
	}
}