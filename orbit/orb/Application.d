/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Application;

//import tango.core.tools.TraceExceptions;
import tango.io.Stdout;
import tango.stdc.stdlib : EXIT_SUCCESS, EXIT_FAILURE;

import mambo.core._;
import orbit.dsl.Specification;
import orbit.orbit.Exceptions;
import mambo.util.Singleton;
import mambo.util.Use;

import orbit.orb.CommandManager;
import orbit.orb.Options;
import orbit.orb.util.OptionParser;

class Application
{
	mixin Singleton;
	
	const Version = "0.0.1";
	
	enum ExitCode
	{
		success = EXIT_SUCCESS,
		failure = EXIT_FAILURE
	}
	
	private
	{
		alias ExitCode delegate () Runnable;
		
		Options options;
		string[] args;
		string[] topLevel;
		CommandManager commandManager;
	}

	private this ()
	{
		options = Options.instance;
		commandManager = CommandManager.instance;
		
		registerCommands;
	}

	int run (string[] args)
	{
		this.args = args;
		
		return debugHandleExceptions in {
			parseOptions;
			return ExitCode.success;
		};
	}
	
private:
	
	Use!(Runnable) handleExceptions ()
	{
		Use!(Runnable) use;
		
		use.args[0] = (Runnable dg) {
			try
				return dg();
			
			catch (OrbitException e)
			{
				stderr.format("An error occurred: {}", e).flush;
				return ExitCode.failure;
			}
			
			catch (Exception e)
			{
				stderr.format("An unknown error occurred:").newline;
				throw e;
			}
		};
		
		return use;
	}
	
	Use!(Runnable) debugHandleExceptions ()
	{
		Use!(Runnable) use;
	
		use.args[0] = (Runnable dg) {
			return dg();
		};
		
		return use;
	}
	
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
	
	void handleArgs (string[] args)
	{
		if (args.length > 0)
			handleCommand(args[0], args[1 .. $]);		
	}
	
	void parseOptions ()
	{
		auto helpMessage = "Use the `-h' flag for help.";
		auto opts = new OptionParser;
		auto commands = commandManager.summary;
		auto help = false;
		
		opts.banner = "Usage: orb [options] command [arg]";
		opts.separator("Version 0.0.1");
		opts.separator("");
		opts.separator("Commands:");
		opts.separator(commands);
		opts.separator("Options:");

		opts.on('v', "verbose", "Show additional output.", {
			options.verbose = true;
		});
		
		opts.on('h', "help", "Show this message and exit.", {
			help = true;
		});

		if (args.length == 1 || help)
		{
			println(opts);
			println(helpMessage);
		}

		else
		{
			opts.on((string[] args) {
				handleArgs(args);
			});
			
			opts.parse(args[1 .. $]);
		}
	}
}
