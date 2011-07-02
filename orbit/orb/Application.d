/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Application;

import tango.io.Stdout;
import tango.stdc.stdlib;

import orbit.core._;
import orbit.dsl.Specification;
import orbit.util.Singleton;
import orbit.util.Use;

import orbit.orb.CommandManager;
import orbit.orb.Options;
import orbit.orb.util.OptionParser;

class Application
{
	mixin Singleton;
	
	const Version = "0.0.1";
	
	private
	{
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

	void run (string[] args)
	{
		//spec = Specification.load("/Users/doob/development/eclipse_workspace/orbit/src/test.orbspec");
		// println(spec.name);
		// println(spec.version_);
		// println(spec.summary);

		this.args = args;
		
		debugHandleExceptions in {
			parseOptions;
		};
	}
	
private:
	
	Use!(void delegate ()) handleExceptions ()
	{
		Use!(void delegate ()) use;
		
		use.args[0] = (void delegate () dg) {
			try
				dg();
			
			catch (Exception e)
				die(e.toString);
		};
		
		return use;
	}
	
	Use!(void delegate ()) debugHandleExceptions ()
	{
		Use!(void delegate ()) use;
	
		use.args[0] = (void delegate () dg) {
			dg();
		};
		
		return use;
	}
	
	void registerCommands ()
	{
		commandManager.register("orbit.orb.commands.Build.Build");
		// commandManager.register("orbit.orb.commands.Fetch.Fetch");
		commandManager.register("orbit.orb.commands.Install.Install");
	}
	
	void handleCommand (string command, string[] args)
	{
		commandManager[command].invoke(args);
	}
	
	void handleArgs (string[] args)
	{
		if (args.length > 0)
		{	
			string command;
			
			switch (args[0])
			{
				case "build": command = "orbit.orb.commands.Build.Build"; break;
				case "fetch": command = "orbit.orb.commands.Fetch.Fetch"; break;
				case "install":	command = "orbit.orb.commands.Install.Install"; break;
				default:
					return;
			}
		
			handleCommand(command, args[1 .. $]);			
		}			
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
	
	void die (Args...) (Args args)
	{
		Stderr.print(args).newline;
		exit(1);
	}
}