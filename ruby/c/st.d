/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.c.st;

import tango.stdc.config;
import tango.stdc.stdint;

import ruby.c.ruby;
import ruby.c.config;

extern (C):

static if (SIZEOF_LONG == SIZEOF_VOIDP)
	alias c_ulong st_data_t;

else static if (SIZEOF_LONG_LONG == SIZEOF_VOIDP)
	alias ulong st_data_t;

else
	static assert(false, "ruby.c.st requires (void*).sizeof == c_long.sizeof to be compiled.");

alias st_data_t st_index_t;

/*
struct st_table {
    const struct st_hash_type *type;
    st_index_t num_bins;
    unsigned int entries_packed : 1;
#ifdef __GNUC__
    __extension__
#endif
    st_index_t num_entries : ST_INDEX_BITS - 1;
    struct st_table_entry **bins;
    struct st_table_entry *head, *tail;
};
*/

struct st_table;

st_index_t st_hash_uint32 (st_index_t h, uint32_t i);
st_index_t st_hash_uint (st_index_t h, st_index_t i);
st_index_t st_hash_end (st_index_t h);