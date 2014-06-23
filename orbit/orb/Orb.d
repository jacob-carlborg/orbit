/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orbit.orb.Orb;

import dstack.application.DStack;
import orbit.orb.Application;
import orbit.config.Configuration;

int main (string[] args)
{
    DStack.application = Application.instance;
	DStack.config = new Configuration;

	return DStack.application.start(args);
}