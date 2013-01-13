/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 25, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.Archiver;

import tango.util.compress.Zip;
import tango.io.FilePath;

import mambo.core._;
import orbit.dsl.Specification;
import Path = orbit.io.Path;
import orbit.orbit._;

class Archiver
{
	string path;
	const Specification spec;
	const Orbit orbit;
	
	private ZipBlockWriter writer;
	
	this (Specification specification, string path, Orbit orbit = Orbit.defaultOrbit)
	{
		this.orbit = orbit;
		spec = specification;
		this.path = path;
	}
	
	void archive ()
	{
		writer = new ZipBlockWriter(cast(char[])path);
		writer.method = Method.Deflate;

		foreach (file ; spec.files)
			addFileToArchive(file);

		addMetaData;
		writer.finish;
	}
	
private:
	
	void addFileToArchive (string path)
	{
		auto zipPath = Path.join(orbit.constants.orbData, path);
		writer.putFile(ZipEntryInfo(cast(char[])zipPath), cast(char[])Path.toAbsolute(cast(char[]) path));
	}
	
	void addMetaData ()
	{
		auto zipEntry = ZipEntryInfo(cast(char[])orbit.constants.orbMetaData);
		writer.putFile(zipEntry, cast(char[])spec.orbspecPath);
		//writer.putData(zipEntry, spec.toYaml);
	}
}
