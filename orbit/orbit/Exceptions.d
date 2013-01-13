/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 25, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Exceptions;

import mambo.core._;

import orbit.orbit.Orb;
import orbit.orbit.Repository;

class OrbitException : Exception
{
	this (string message, string file = "")
	{
		super(message);
	}
}

class RepositoryException : OrbitException
{
	const Repository repository;
	
	this (Repository repository, string message = "")
	{
		this.repository = repository;
		super(message);
	}
}

class MissingOrbException : RepositoryException
{
	const Orb orb;
	
	this (Orb orb, Repository repository, string message = "")
	{
		this.orb = orb;
		auto msg = message.isPresent ? message : createMessage(repository);
		
		super(repository, msg);
	}
	
	this (Orb orb, Repository repository)
	{
		this(orb, repository, null);
	}
	
	private string createMessage (Repository repository)
	{
		return format(`The orb "{}" is not available in the repository "{}".`, orb, repository).assumeUnique;
	}
}

class MissingLibraryException : OrbitException
{
	const string lib;
	const string dylib;
	
	this (string lib, string dylib, string message)
	{
		super(message);
		this.lib = lib;
		this.dylib = dylib;
	}
	
	this (string lib, string dylib)
	{
		auto message = format(`The required library, "{}" or "{}", could not be found.`, lib, dylib).assumeUnique;
		this(lib, dylib, message);
	}
}