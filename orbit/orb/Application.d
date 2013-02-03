/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Application;

//import tango.core.tools.TraceExceptions;

import mambo.core._;
import mambo.util.Singleton;
import mambo.util.Use;

import DStack = dstack.application.Application;
import dstack.controller.CommandManager;

import orbit.dsl.Specification;
import orbit.orb.commands._;
import orbit.orb.Options;
import orbit.orb.util.OptionParser;
import orbit.orbit.Exceptions;

class Application : DStack.Application
{
	mixin Singleton;

	protected override void setupArguments ()
	{
		arguments('v', "verbose", "Show additional output");
	}

	protected override void registerCommands (CommandManager manager)
	{
		manager.register!(Build);
		manager.register!(Fetch);
		manager.register!(Install);
		manager.register!(Push);
	}

private:

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
