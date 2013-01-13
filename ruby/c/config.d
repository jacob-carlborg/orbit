/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 30, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.c.config;

import tango.stdc.config;
import tango.stdc.posix.unistd;
import tango.stdc.posix.sys.select;

import mambo.util.Version;
	
version (linux)
{
	alias c_long __fd_mask;
    const __NFDBITS = 8 * __fd_mask.sizeof;
    alias __NFDBITS NFDBITS;
}

else version (darwin)
{
    const uint __DARWIN_NBBY = 8;                               /* bits in a byte */
    const uint __DARWIN_NFDBITS = (int.sizeof * __DARWIN_NBBY); /* bits per mask */
    alias __DARWIN_NFDBITS NFDBITS;
}

else version (freebsd)
{
	const uint FD_SETSIZE = 1024;
	const uint _NFDBITS = c_ulong.sizeof * 8;
	alias _NFDBITS NFDBITS;
}

else version (solaris)
{
    alias c_long __fd_mask;
	const NBBY = 8;
    const FD_NFDBITS = __fd_mask.sizeof * NBBY;	/* bits per mask */
    alias FD_NFDBITS NFDBITS;
}

else
	static assert (false, "NFDBITS missing for this platform");

const HAVE_LONG_LONG = true;
const HAVE_OFF_T = true;
const SIZEOF_INT = int.sizeof;
const SIZEOF_SHORT = short.sizeof;
const SIZEOF_LONG = c_long.sizeof;
const SIZEOF_LONG_LONG = long.sizeof;
const SIZEOF___INT64 = 0;
const SIZEOF_OFF_T = c_long.sizeof;
const SIZEOF_VOIDP = (void*).sizeof;
const SIZEOF_FLOAT = float.sizeof;
const SIZEOF_DOUBLE = double.sizeof;
const SIZEOF_TIME_T = c_long.sizeof;

const SIZEOF_SIZE_T = size_t.sizeof;
const SIZEOF_PTRDIFF_T = ptrdiff_t.sizeof;

//alias pid_t rb_gid_t;
/*alias INT2NUM PIDT2NUM;
alias NUM2INT NUM2PIDT;
alias uid_t rb_uid_t;
alias UINT2NUM UIDT2NUM;
alias NUM2UINT NUM2UIDT;
alias gid_t rb_gid_t;
alias UINT2NUM GIDT2NUM;
alias NUM2UINT NUM2GIDT;
alias time_t rb_time_t;
alias LONG2NUM TIMET2NUM;
alias NUM2LONG NUM2TIMET;
alias dev_t rb_dev_t;
alias INT2NUM DEVT2NUM;
alias NUM2INT NUM2DEVT;*/

const HAVE_RB_FD_INIT = true;

alias pid_t rb_pid_t ;