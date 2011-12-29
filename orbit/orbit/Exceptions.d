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
	this (string message, string file = "", size_t line = 0)
	{
		super(message, file, line);
	}
}

class RepositoryException : OrbitException
{
	const Repository repository;
	
	this (Repository repository, string message = "", string file = "", size_t line = 0)
	{
		this.repository = repository;
		super(message, file, line);
	}
}

class MissingOrbException : RepositoryException
{
	const Orb orb;
	
	this (Orb orb, Repository repository, string message = "", string file = "", size_t line = 0)
	{
		this.orb = orb;
		auto msg = message.isPresent() ? message : createMessage(repository);
		
		super(repository, msg, file, line);
	}
	
	this (Orb orb, Repository repository, string file, size_t line)
	{
		this(orb, repository, null, file, line);
	}
	
	private string createMessage (Repository repository)
	{
		return format(`The orb "{}" is not available in the repository "{}".`, orb, repository);
	}
}

class MissingLibraryException : OrbitException
{
	const string lib;
	const string dylib;
	
	this (string lib, string dylib, string message, string file = "", size_t line = 0)
	{
		super(message, file, line);
		this.lib = lib;
		this.dylib = dylib;
	}
	
	this (string lib, string dylib, string file = "", size_t line = 0)
	{
		auto message = format(`The required library, "{}" or "{}", could not be found.`, lib, dylib);
		this(lib, dylib, message, file, line);
	}
}