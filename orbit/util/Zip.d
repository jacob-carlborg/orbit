/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jul 10, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.util.Zip;

import Zip = std.zip;

import orbit.io.File;

struct ZipArchive
{
	struct Entry
	{
		private
		{
			Zip.ArchiveMember member_;
		}
		
		this (string name)
		{
			this.name = name;
		}
		
		private member ()
		{
			return member_ = member_ is null ? new Zip.ArchiveMember : member_;
		}
		
		string name (string name)
		{
			member.name = name;
			return name;
		}
		
		string name ()
		{
			return member.name;
		}
	}
	
	private
	{
		Zip.ZipArchive archive_;
		string path;
	}
	
	this (string path)
	{
		this.path = path;
	}
	
	private Zip.ZipArchive archive ()
	{
		return archive_ = archive_ is null ? new Zip.ZipArchive : archive_;
	}
	
	ZipArchive putFile (Entry entry, string path)
	{
		entry.member.expandedData = File.get("/Users/doob/development/d/test.d");
		archive.addMember(entry.member);

		return this;
	}
	
	ZipArchive putData (T) (Entry entry, T[] data)
	{
		entry.member.expandedData = data;
		archive.addMember(entry.member);
		
		return this;
	}
	
	ZipArchive write ()
	{
		File.set(path, archive.build);
		
		return this;
	}
}