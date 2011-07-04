/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.c.defines;

import ruby.c.config;

static if (SIZEOF_INT * 2 <= SIZEOF_LONG_LONG)
{
	alias uint BDIGIT;
	alias SIZEOF_INT SIZEOF_BDIGITS;
	alias ulong BDIGIT_DBL;
	alias long BDIGIT_DBL_SIGNED;
}

else static if (SIZEOF_INT * 2 <= SIZEOF_LONG)
{
	alias uint BDIGIT;
	alias SIZEOF_INT SIZEOF_BDIGITS;
	alias c_ulong BDIGIT_DBL;
	alias c_long BDIGIT_DBL_SIGNED;
}

else static if (SIZEOF_SHORT * 2 <= SIZEOF_LONG)
{
	alias ushort BDIGIT;
	alias SIZEOF_SHORT SIZEOF_BDIGITS;
	alias c_ulong BDIGIT_DBL;
	alias c_long BDIGIT_DBL_SIGNED;
}

else
{
	alias ushort BDIGIT;
	const SIZEOF_BDIGITS = SIZEOF_LONG / 2;
	alias c_ulong BDIGIT_DBL;
	alias c_long BDIGIT_DBL_SIGNED;
}