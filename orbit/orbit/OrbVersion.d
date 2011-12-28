/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 19, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orbit.OrbVersion;

import tango.text.Util;
import tango.util.Convert;

import orbit.core._;

struct OrbVersion
{
	int major = invalidPart;
	int minor = invalidPart;
	int build = invalidPart;
	
	private static const invalidPart = -1;
	
	static OrbVersion opCall (int major = 0, int minor = 0, int build = 0)
	{
		OrbVersion ver;
		
		ver.major = major;
		ver.minor = minor;
		ver.build = build;
		
		return ver;
	}

	static OrbVersion parse (string version_)
	{
		OrbVersion ver = OrbVersion.invalid;
		
		if (version_.isBlank())
			return ver;

		auto parts = version_.split(".");
		
		if (parts.length != 3)
			return ver;
		
		ver.major = toInt(cast(string)parts[0]);
		ver.minor = toInt(cast(string)parts[1]);
		ver.build = toInt(cast(string)parts[2]);

		return ver;
	}
	
	static OrbVersion invalid ()
	{
		OrbVersion ver;
		ver.major = invalidPart;
		ver.minor = invalidPart;
		ver.build = invalidPart;
		
		return ver;
	}
	
	bool isValid ()
	{
		return major > invalidPart && minor > invalidPart && build > invalidPart;
	}
	
	string toString ()
	{
		return format("{}.{}.{}", major, minor, build);
	}
	
	private:
	
	static int toInt (string str)
	{
		return to!(int)(str, invalidPart);
	}
}
