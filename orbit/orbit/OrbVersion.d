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
	int major;
	int minor;
	int build;
	string custom;
	
	private static const invalidPart = -1;
	
	static OrbVersion opCall (string custom)
	{
		OrbVersion ver;
		ver.custom = custom;
		
		return ver;
	}
	
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
		{
			ver.custom = version_;
			return ver;
		}
		
		ver.major = toInt(parts[0]);
		ver.minor = toInt(parts[1]);
		ver.build = toInt(parts[2]);

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
	
	bool isCustom ()
	{
		return major == invalidPart && minor == invalidPart && build == invalidPart && custom.isPresent();
	}
	
	bool isStandard ()
	{
		return major > invalidPart && minor > invalidPart && build > invalidPart && custom.isBlank();
	}
	
	bool isValid ()
	{
		return isCustom || isStandard;
	}
	
	int opEquals (OrbVersion rhs)		
	{
		if (isCustom && rhs.isCustom)
			return custom == rhs.custom;
			
		if (isStandard && rhs.isStandard)
			return major == rhs.major && minor == rhs.minor && build == rhs.build;
		
		if (!isValid && !rhs.isValid)
			return true;
		
		return false;
	}
	
	int opCmp (OrbVersion rhs)
	{
		assert(false, "not implemented");
	}
	
	string toString ()
	{
		if (isCustom)
			return custom;
			
		else
			return format("{}.{}.{}", major, minor, build);
	}
	
	private:
	
	static int toInt (string str)
	{
		return to!(int)(str, invalidPart);
	}
}