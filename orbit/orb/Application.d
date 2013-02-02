/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Application;

//import tango.core.tools.TraceExceptions;
import DStack = dstack.application.Application;

import mambo.core._;
import mambo.util.Singleton;
import mambo.util.Use;

import orbit.dsl.Specification;
import orbit.orb.CommandManager;
import orbit.orb.Options;
import orbit.orb.util.OptionParser;
import orbit.orbit.Exceptions;

class Application : DStack.Application
{
	mixin Singleton;

	private
	{
		CommandManager commandManager;
	}

	protected override void run ()
	{
		handleCommands();
		commandManager = CommandManager.instance;
		registerCommands();
	}

	protected override void setupArguments ()
	{
		arguments('v', "verbose", "Show additional output");
	}

private:

	void registerCommands ()
	{
		commandManager.register("build", "orbit.orb.commands.Build.Build");
		commandManager.register("fetch", "orbit.orb.commands.Fetch.Fetch");
		commandManager.register("install", "orbit.orb.commands.Install.Install");
		commandManager.register("push", "orbit.orb.commands.Push.Push");
	}

	void handleCommand (string command, string[] args)
	{
		commandManager[command].invoke(args);
	}

	void handleCommands ()
	{
		if (arguments.args.any)
			handleCommand(arguments.args[0], arguments.args[1 .. $]);
	}

	// void parseOptions ()
	// {
	// 	auto helpMessage = "Use the `-h' flag for help.";
	// 	auto opts = new OptionParser;
	// 	auto commands = commandManager.summary;
	// 	auto help = false;
	//
	// 	opts.banner = "Usage: orb [options] command [arg]";
	// 	opts.separator("Version 0.0.1");
	// 	opts.separator("");
	// 	opts.separator("Commands:");
	// 	opts.separator(commands);
	// 	opts.separator("Options:");
	//
	// 	opts.on('v', "verbose", "Show additional output.", {
	// 		options.verbose = true;
	// 	});
	//
	// 	opts.on('h', "help", "Show this message and exit.", {
	// 		help = true;
	// 	});
	//
	// 	if (args.length == 1 || help)
	// 	{
	// 		println(opts);
	// 		println(helpMessage);
	// 	}
	//
	// 	else
	// 	{
	// 		opts.on((string[] args) {
	// 			handleArgs(args);
	// 		});
	//
	// 		opts.parse(args[1 .. $]);
	// 	}
	// }
}
