/**
 * Copyright: Copyright (c) 2010-2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 8, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.CommandManager;

import tango.text.convert.Format : format = Format;

import mambo.core._;
import mambo.util.Singleton;

import orbit.orb.Command;
import orbit.orb.commands._;
import orbit.orb.Exceptions;
import orbit.orb.Options;

class CommandManager
{
	mixin Singleton;
	
	private Command[string] commands;
	
	void register (string command, string className)
	{
		commands[command] = createCommand(className);
	}

	Command opIndex (string command)
	{
		if (auto c = command in commands)
			if (*c)
				return *c;
		
		throw new MissingCommandException(`The command "` ~ command ~ `" was missing.`);
	}
	
	string[] names ()
	{
		return commands.keys.sort;
	}
	
	string summary ()
	{
		string result;
		
		auto len = lenghtOfLongestCommand;
		auto options = Options.instance;

		foreach (name, _ ; commands)
		{
			auto command = this[name];
			result ~= format("{}{}{}{}{}\n",
						options.indentation,
						command.name,
						" ".repeat(len - command.name.length),
						options.indentation.repeat(options.numberOfIndentations),
						command.summary);
		}
		
		return result;
	}
	
	private Command createCommand (string command)
	{
		auto classInfo = ClassInfo.find(command);

		if (!classInfo)
			throw new MissingCommandException(`The command "` ~ command ~ `" was missing.`);
		
		return cast(Command) classInfo.create;
	}
	
	private size_t lenghtOfLongestCommand ()
	{
		size_t len;
		
		foreach (name, _ ; commands)
		{
			auto command = this[name];
			
			if (command.name.length > len)
				len = command.name.length;
		}

		return len;
	}
}