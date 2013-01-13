/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Options;

import mambo.core._;
import mambo.util._;

class Options
{
	mixin Singleton;

	const string indentation = "    ";
	const int numberOfIndentations = 1;
	const Path path = Path();
	
	bool verbose = false;
}

private struct Path
{
	
}