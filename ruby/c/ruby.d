/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 30, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module ruby.c.ruby;

import tango.stdc.config;
import core.stdc.limits;
import tango.stdc.string;
import tango.stdc.stdarg;

import ruby.c.config;
import ruby.c.defines;
import ruby.c.io;
import ruby.c.intern;
import ruby.c.oniguruma;
import ruby.c.st;
import ruby.util.string;

extern (C):

const NORETURN_STYLE_NEW = 1;

template NORETURN (T)
{
	alias T NORETURN;
}

template DEPRECATED (T)
{
	alias T DEPRECATED;
}

template NOINLINE (T)
{
	alias T NOINLINE;
}

alias c_ulong VALUE;
alias c_ulong ID;
alias c_long SIGNED_VALUE;
const SIZEOF_VALUE = VALUE.sizeof;

const FIXNUM_MAX = LONG_MAX >> 1;
const FIXNUM_MIN = LONG_MIN >> 1;

VALUE INT2FIX (T) (T i)
{
	return cast(VALUE) ((cast(SIGNED_VALUE) i) << 1 | FIXNUM_FLAG);
}

alias INT2FIX LONG2FIX;
alias INT2FIX rb_fix_new;
VALUE rb_int2inum (SIGNED_VALUE);

alias rb_int2inum rb_int_new;
VALUE rb_uint2inum (VALUE);

alias rb_uint2inum rb_uint_new;

version (D_LP64)
{
	VALUE rb_ll2inum (long);
	alias rb_ll2inum LL2NUM;
	VALUE rb_ull2inum (ulong);
	alias rb_ull2inum ULL2NUM;
}

static if (SIZEOF_OFF_T > SIZEOF_LONG && HAVE_LONG_LONG)
	alias LL2NUM OFFT2NUM;

else static if (SIZEOF_OFF_T == SIZEOF_LONG)
	alias LONG2NUM OFFT2NUM;

else
	alias INT2NUM OFFT2NUM;

static if (SIZEOF_SIZE_T > SIZEOF_LONG && HAVE_LONG_LONG)
{
	alias ULL2NUM SIZET2NUM;
	alias LL2NUM SSIZET2NUM;
}

else static if (SIZEOF_SIZE_T == SIZEOF_LONG)
{
	alias ULONG2NUM SIZET2NUM;
	alias LONG2NUM SSIZET2NUM;
}

else
{
	alias UINT2NUM SIZET2NUM;
	alias INT2NUM SSIZET2NUM;
}

static if (SIZEOF_SIZE_T > SIZEOF_LONG && HAVE_LONG_LONG)
{
	alias LLONG_MAX SSIZE_MAX;
	alias LLONG_MIN SSIZE_MIN;
}

else static if (SIZEOF_SIZE_T == SIZEOF_LONG)
{
	alias LONG_MAX SSIZE_MAX;
	alias LONG_MIN SSIZE_MIN;
}

else static if (SIZEOF_SIZE_T == SIZEOF_INT)
{
	alias INT_MAX SSIZE_MAX;
	alias INT_MIN SSIZE_MIN;
}

else
{
	SHRT_MAX SSIZE_MAX;
	SSIZE_MIN SSIZE_MIN;
}

static if (SIZEOF_INT < SIZEOF_VALUE)
	void rb_out_of_int (SIGNED_VALUE num);

static if (SIZEOF_INT < SIZEOF_LONG)
{	
	int rb_long2int_internal (c_long n)
	{
		int i = cast(int) n;
		
		if (cast(c_long) i != n)
			rb_out_of_int(n);
		
		return i;
	}
	
	alias rb_long2int_internal rb_long2int;
}

else
{
	int rb_long2int (c_long n)
	{
		return cast(int) n; 
	}
}

alias LONG2NUM PIDT2NUM;
alias NUM2LONG NUM2PIDT;
alias LONG2NUM UIDT2NUM;
alias NUM2LONG NUM2UIDT;
alias LONG2NUM GIDT2NUM;
alias NUM2LONG NUM2GIDT;

VALUE FIX2LONG (VALUE x)
{
	return cast(SIGNED_VALUE) x >> 1;
}

VALUE FIX2ULONG (T) (T x)
{
	return ((cast(VALUE) x) >> 1) & LONG_MAX;
}

VALUE FIXNUM_P (VALUE f)
{
	return (cast(SIGNED_VALUE) f) & FIXNUM_FLAG;
}

bool POSFIXABLE (T) (T f)
{
	return f < FIXNUM_MAX + 1;
}

bool NEGFIXABLE (T) (T f)
{
	return f >= FIXNUM_MIN;
}

bool FIXABLE (T) (T f)
{
	return POSFIXABLE(f) && NEGFIXABLE(f);
}


bool IMMEDIATE_P (VALUE x)
{
	return cast(bool) (cast(VALUE) x & IMMEDIATE_MASK);
}


bool SYMBOL_P (VALUE x)
{
	return (cast(VALUE) x &~(~cast(VALUE) 0 << RUBY_SPECIAL_SHIFT)) == SYMBOL_FLAG;
}

VALUE ID2SYM (T) (T x)
{
	return (cast(VALUE) x << RUBY_SPECIAL_SHIFT) | SYMBOL_FLAG;
}

VALUE SYM2ID (T) (T x)
{
	return cast(c_ulong) x >>> RUBY_SPECIAL_SHIFT;
}

const USE_SYMBOL_AS_METHOD_NAME = true;

/* special constants - i.e. non-zero and non-fixnum constants */
enum ruby_special_consts 
{
	RUBY_Qfalse = 0,
	RUBY_Qtrue = 2,
	RUBY_Qnil = 4,
	RUBY_Qundef = 6,
	
	RUBY_IMMEDIATE_MASK = 0x03,
	RUBY_FIXNUM_FLAG = 0x01,
	RUBY_SYMBOL_FLAG = 0x0e,
	RUBY_SPECIAL_SHIFT = 8
}

alias ruby_special_consts.RUBY_Qfalse RUBY_Qfalse;
alias ruby_special_consts.RUBY_Qtrue RUBY_Qtrue;
alias ruby_special_consts.RUBY_Qnil RUBY_Qnil;
alias ruby_special_consts.RUBY_Qundef RUBY_Qundef;

alias ruby_special_consts.RUBY_IMMEDIATE_MASK RUBY_IMMEDIATE_MASK;
alias ruby_special_consts.RUBY_FIXNUM_FLAG RUBY_FIXNUM_FLAG;
alias ruby_special_consts.RUBY_SYMBOL_FLAG RUBY_SYMBOL_FLAG;
alias ruby_special_consts.RUBY_SPECIAL_SHIFT RUBY_SPECIAL_SHIFT;

const Qfalse = cast(VALUE) ruby_special_consts.RUBY_Qfalse;
const Qtrue = cast(VALUE) ruby_special_consts.RUBY_Qtrue;
const Qnil = cast(VALUE) ruby_special_consts.RUBY_Qnil;
const Qundef = cast(VALUE) ruby_special_consts.RUBY_Qundef; /* undefined value for placeholder */
alias ruby_special_consts.RUBY_IMMEDIATE_MASK IMMEDIATE_MASK;;
alias ruby_special_consts.RUBY_FIXNUM_FLAG FIXNUM_FLAG;
alias ruby_special_consts.RUBY_SYMBOL_FLAG SYMBOL_FLAG;


VALUE RTEST (T) (T v)
{
	return (cast(VALUE) v & ~Qnil) != 0;
}

VALUE NIL_P (T) (T v)
{
	return cast(VALUE) v == Qnil;
}

VALUE CLASS_OF (T) (T v)
{
	return rb_class_of(cast(VALUE) v);
}

enum ruby_value_type
{
	RUBY_T_NONE = 0x00,

	RUBY_T_OBJECT = 0x01,
	RUBY_T_CLASS = 0x02,
	RUBY_T_MODULE = 0x03,
	RUBY_T_FLOAT = 0x04,
	RUBY_T_STRING = 0x05,
	RUBY_T_REGEXP = 0x06,
	RUBY_T_ARRAY = 0x07,
	RUBY_T_HASH = 0x08,
	RUBY_T_STRUCT = 0x09,
	RUBY_T_BIGNUM = 0x0a,
	RUBY_T_FILE = 0x0b,
	RUBY_T_DATA = 0x0c,
	RUBY_T_MATCH = 0x0d,
	RUBY_T_COMPLEX = 0x0e,
	RUBY_T_RATIONAL = 0x0f,

	RUBY_T_NIL	= 0x11,
	RUBY_T_TRUE = 0x12,
	RUBY_T_FALSE = 0x13,
	RUBY_T_SYMBOL = 0x14,
	RUBY_T_FIXNUM = 0x15,

	RUBY_T_UNDEF = 0x1b,
	RUBY_T_NODE = 0x1c,
	RUBY_T_ICLASS = 0x1d,
	RUBY_T_ZOMBIE = 0x1e,

	RUBY_T_MASK = 0x1f
}

alias ruby_value_type.RUBY_T_NONE T_NONE;
alias ruby_value_type.RUBY_T_NIL T_NIL;
alias ruby_value_type.RUBY_T_OBJECT T_OBJECT;
alias ruby_value_type.RUBY_T_CLASS T_CLASS;
alias ruby_value_type.RUBY_T_ICLASS T_ICLASS;
alias ruby_value_type.RUBY_T_MODULE T_MODULE;
alias ruby_value_type.RUBY_T_FLOAT T_FLOAT;
alias ruby_value_type.RUBY_T_STRING T_STRING;
alias ruby_value_type.RUBY_T_REGEXP T_REGEXP;
alias ruby_value_type.RUBY_T_ARRAY T_ARRAY;
alias ruby_value_type.RUBY_T_HASH T_HASH;
alias ruby_value_type.RUBY_T_STRUCT T_STRUCT;
alias ruby_value_type.RUBY_T_BIGNUM T_BIGNUM;
alias ruby_value_type.RUBY_T_FILE T_FILE;
alias ruby_value_type.RUBY_T_FIXNUM T_FIXNUM;
alias ruby_value_type.RUBY_T_TRUE T_TRUE;
alias ruby_value_type.RUBY_T_FALSE T_FALSE;
alias ruby_value_type.RUBY_T_DATA T_DATA;
alias ruby_value_type.RUBY_T_MATCH T_MATCH;
alias ruby_value_type.RUBY_T_SYMBOL T_SYMBOL;
alias ruby_value_type.RUBY_T_RATIONAL T_RATIONAL;
alias ruby_value_type.RUBY_T_COMPLEX T_COMPLEX;
alias ruby_value_type.RUBY_T_UNDEF T_UNDEF;
alias ruby_value_type.RUBY_T_NODE T_NODE;
alias ruby_value_type.RUBY_T_ZOMBIE T_ZOMBIE;
alias ruby_value_type.RUBY_T_MASK T_MASK;

int BUILTIN_TYPE (VALUE x)
{
	return cast(int) ((cast(RBasic*) x).flags & T_MASK);
}

int TYPE (T) (T x)
{
	return rb_type(cast(VALUE) x);
}

VALUE* rb_gc_guarded_ptr(VALUE* ptr)
{
	return ptr;
}

alias rb_gc_guarded_ptr RB_GC_GUARD_PTR;

VALUE RB_GC_GUARD (VALUE v)
{
	return (*RB_GC_GUARD_PTR(&v));
}

void rb_check_type (VALUE, int);

void Check_Type (T) (T v, int t)
{
	rb_check_type(cast(VALUE) v, t);
}

VALUE rb_str_to_str (VALUE);
VALUE rb_string_value (VALUE*);
char* rb_string_value_ptr (VALUE*);
char* rb_string_value_cstr (VALUE*);

VALUE StringValue (VALUE v)
{
	return rb_string_value(&v);
}

char* StringValuePtr (VALUE v)
{
	return rb_string_value_ptr(&v);
}

char* StringValueCStr (VALUE v)
{
	return rb_string_value_cstr(&v);
}

void rb_check_safe_obj (VALUE);
deprecated void rb_check_safe_str (VALUE);

void SafeStringValue (VALUE v)
{
	StringValue(v);
	rb_check_safe_obj(v);
}

/* obsolete macro - use SafeStringValue(v) */
deprecated void Check_SafeStr (T) (T v)
{
	rb_check_safe_str(cast(VALUE) v);
}

VALUE rb_str_export (VALUE);
VALUE rb_str_export_locale (VALUE);

void ExportStringValue (ref VALUE v)
{
	SafeStringValue(v);
	v = rb_str_export(v);
}

VALUE rb_get_path (VALUE);

VALUE FilePathValue (VALUE v)
{
	return RB_GC_GUARD(rb_get_path(v));
}

VALUE rb_get_path_no_checksafe (VALUE);

void FilePathStringValue (ref VALUE v)
{
	v = rb_get_path_no_checksafe(v);
}

void rb_secure (int);
int rb_safe_level ();
void rb_set_safe_level (int);
void rb_set_safe_level_force (int);
void rb_secure_update (VALUE);
void rb_insecure_operation ();

VALUE rb_errinfo ();
void rb_set_errinfo (VALUE);

SIGNED_VALUE rb_num2long (VALUE);
VALUE rb_num2ulong (VALUE);

VALUE NUM2LONG_internal (VALUE x)
{
	return FIXNUM_P(x) ? FIX2LONG(x) : rb_num2long(x);
}

c_long NUM2LONG (VALUE x)
{
    return NUM2LONG_internal(x);
}

VALUE NUM2ULONG (T) (T x)
{
	return rb_num2ulong(cast(VALUE) x);
}

static if (SIZEOF_INT < SIZEOF_LONG)
{
	c_long rb_num2int (VALUE);
	c_long rb_fix2int (VALUE);
	
	int FIX2INT (T) (T x)
	{
		return cast(int) rb_fix2int(cast(VALUE) x);
	}
	
	int NUM2INT_internal (VALUE x)
	{
		return FIXNUM_P(x) ? FIX2INT(x) : cast(int) rb_num2int(x);
	}
	
	int NUM2INT (VALUE x)
	{
		return NUM2INT_internal(x);
	}
	
	c_ulong rb_num2uint (VALUE);
	
	uint NUM2UINT (VALUE x)
	{
		return cast(uint) rb_num2uint(x); 
	}
	
	c_ulong rb_fix2uint (VALUE);
	
	uint FIX2UINT (VALUE x)
	{
		return cast(uint) rb_fix2uint(x);
	}
}

else
{	
	int NUM2INT (VALUE x)
	{
		return cast(int) NUM2LONG(x);
	}
	
	uint NUM2UINT (VALUE x)
	{
		return cast(uint) NUM2ULONG(x);
	}
	
	int FIX2INT (VALUE x)
	{
		return cast(int) FIX2UINT(x);
	}
	
	uint FIX2UINT (VALUE x)
	{
		return cast(uint) FIX2ULONG(x);
	}
}

static if (HAVE_LONG_LONG)
{
	long rb_num2ll (VALUE);
	ulong rb_num2ull (VALUE);
	
	long NUM2LL_internal (VALUE x)
	{
		return FIXNUM_P(x) ? FIX2LONG(x) : rb_num2ll(x);
	}
	
	alias NUM2LL_internal NUM2LL;
	
	ulong NUM2ULL (T) (T x)
	{
		return rb_num2ull(cast(VALUE) x);
	}
}

static if (HAVE_LONG_LONG && SIZEOF_OFF_T > SIZEOF_LONG)
{
	long NUM2OFFT (T) (T x)
	{
		return cast(off_t) NUM2LL(x);
	}
}

else
	alias NUM2LONG NUM2OFFT;


static if (HAVE_LONG_LONG && SIZEOF_SIZE_T > SIZEOF_LONG)
{
	size_t NUM2SIZET (T) (T x)
	{
		return cast(size_t) NUM2ULL(x);
	}
	
	size_t NUM2SSIZET (T) (T x)
	{
		return cast(size_t) NUM2LL(x);
	}
}

else
{
	alias NUM2ULONG NUM2SIZET;
	alias NUM2LONG NUM2SSIZET;
}

double rb_num2dbl (VALUE);

double NUM2DBL (T) (T x)
{
	return rb_num2dbl(cast(VALUE) x);
}

VALUE rb_uint2big (VALUE);
VALUE rb_int2big (SIGNED_VALUE);

VALUE rb_newobj ();

type* NEWOBJ (type) ()
{
	return cast(type*) rb_newobj;
}

void OBJSETUP (Obj, C, T) (ref Obj obj, C c, T t)
{
	RBASIC(obj).flags = t;
	RBASIC(obj).klass = c;
	
	if (rb_safe_level >= 3)
		FL_SET(obj, FL_TAINT | FL_UNTRUSTED);
}

void CLONESETUP (Clone, Obj) (Clone clone, Obj obj)
{
	OBJSETUP(clone, rb_singleton_class_clone(cast(VALUE) obj), RBASIC(obj).flags);
	rb_singleton_class_attached(RBASIC(clone).klass, cast(VALUE) clone);
	
	if (FL_TEST(obj, FL_EXIVAR))
		rb_copy_generic_ivar(cast(VALUE) clone, cast(VALUE) obj);
}

void DUPSETUP (Dup, Obj) (Dup dup, Obj obj)
{
	OBJSETUP(dup, rb_obj_class(obj), (RBASIC(obj).flags) & (T_MASK | FL_EXIVAR | FL_TAINT | FL_UNTRUSTED));
	
	if (FL_TEST(obj, FL_EXIVAR))
		rb_copy_generic_ivar(cast(VALUE) dup, cast(VALUE) obj);
}

struct RBasic
{
	VALUE flags;
	VALUE klass;
}

const ROBJECT_EMBED_LEN_MAX = 3;

struct RObject
{
	RBasic basic;
	
	union
	{
		struct
		{
			c_long numiv;
			VALUE* ivptr;
			st_table* iv_index_tbl; /* shortcut for RCLASS_IV_INDEX_TBL(rb_obj_class(obj)) */
		}
		
		VALUE[ROBJECT_EMBED_LEN_MAX] ary;
	}
}

alias FL_USER1 ROBJECT_EMBED;

c_long ROBJECT_NUMIV (T) (T o)
{
	return (RBASIC(o).flags & ROBJECT_EMBED) ? ROBJECT_EMBED_LEN_MAX : ROBJECT(o).numiv;
}

VALUE* ROBJECT_IVPTR (T) (T o)
{
	return (RBASIC(o).flags & ROBJECT_EMBED) ? ROBJECT(o).ary : ROBJECT(o).ivptr;
}

st_table* ROBJECT_IV_INDEX_TBL (T) (T o)
{
	return (RBASIC(o).flags & ROBJECT_EMBED) ? RCLASS_IV_INDEX_TBL(rb_obj_class(o)) : ROBJECT(o).iv_index_tbl;
}

/** @internal */

struct rb_classext_t
{
	VALUE super_;
	st_table* iv_tbl;
}

struct RClass
{
	RBasic basic;
	rb_classext_t* ptr;
	st_table* m_tbl;
	st_table* iv_index_tbl;
}

st_table* RCLASS_IV_TBL (T) (T c)
{
	return RCLASS(c).ptr.iv_tbl;
}

st_table* RCLASS_M_TBL (T) (T c)
{
	return RCLASS(c).ptr.m_tbl;
}

st_table* RCLASS_SUPER (T) (T c)
{
	return RCLASS(c).ptr.super_;
}

st_table* RCLASS_IV_INDEX_TBL (T) (T c)
{
	return RCLASS(c).iv_index_tbl;
}

alias RCLASS_IV_TBL RMODULE_IV_TBL;
alias RCLASS_M_TBL RMODULE_M_TBL;
alias RCLASS_SUPER RMODULE_SUPER;

struct RFloat
{
	RBasic basic;
	double float_value;
}

double RFLOAT_VALUE (T) (T v)
{
	return RFLOAT(v).float_value;
}

alias rb_float_new DBL2NUM;
alias FL_USER2 ELTS_SHARED;

const int RSTRING_EMBED_LEN_MAX = (VALUE.sizeof * 3) / char.sizeof - 1;

struct RString
{
	RBasic basic;
	
	union
	{
		struct
		{
			c_long len;
			char* ptr;
			
			union
			{
				c_long capa;
				VALUE _shared;
			}
		}
		
		char[RSTRING_EMBED_LEN_MAX + 1] ary;
	}
}

alias FL_USER1 RSTRING_NOEMBED;
const RSTRING_EMBED_LEN_MASK = FL_USER2 | FL_USER3 | FL_USER4 | FL_USER5 | FL_USER6;
const RSTRING_EMBED_LEN_SHIFT = FL_USHIFT + 2;

c_long RSTRING_LEN (T) (T str)
{
	return !(RBASIC(str).flags & RSTRING_NOEMBED) ?
			cast(c_long)((RBASIC(str).flags >> RSTRING_EMBED_LEN_SHIFT) &
			    (RSTRING_EMBED_LEN_MASK >> RSTRING_EMBED_LEN_SHIFT)) :
			    	RSTRING(str).len;
}

char* RSTRING_PTR (T) (T str)
{
	return !(RBASIC(str).flags & RSTRING_NOEMBED) ? RSTRING(str).ary.ptr : RSTRING(str).ptr;
}

c_long RSTRING_END (T) (T str)
{
	return !(RBASIC(str).flags & RSTRING_NOEMBED) ?
			(RSTRING(str).ary +
			 	((RBASIC(str).flags >> RSTRING_EMBED_LEN_SHIFT) &
			 	 	(RSTRING_EMBED_LEN_MASK >> RSTRING_EMBED_LEN_SHIFT))) :
			 	 		(RSTRING(str).ptr + RSTRING(str).len);
}

int RSTRING_LENINT (T) (T str)
{
	return rb_long2int(RSTRING_LEN(str));
}

const RARRAY_EMBED_LEN_MAX = 3;

struct RArray
{
	RBasic basic;
	
	union
	{
		struct
		{
			c_long len;
			
			union
			{
				c_long capa;
				VALUE _shared;
			}
			
			VALUE* ptr;
		}
		
		VALUE[RARRAY_EMBED_LEN_MAX] ary;
	}
}

alias FL_USER1 RARRAY_EMBED_FLAG;
/* FL_USER2 is for ELTS_SHARED */
const RARRAY_EMBED_LEN_MASK = FL_USER4 | FL_USER3;
const RARRAY_EMBED_LEN_SHIFT = FL_USHIFT + 3;

c_long RARRAY_LEN (T) (T a)
{
	return (RBASIC(a).flags & RARRAY_EMBED_FLAG) ?
			cast(c_long) ((RBASIC(a).flags >> RARRAY_EMBED_LEN_SHIFT) &
			    (RARRAY_EMBED_LEN_MASK >> RARRAY_EMBED_LEN_SHIFT)) :
			    	RARRAY(a).len;
}

VALUE* RARRAY_PTR (T) (T a)
{
	return (RBASIC(a).flags & RARRAY_EMBED_FLAG) ? RARRAY(a).ary.ptr : RARRAY(a).ptr;
}

int RARRAY_LENINT (T) (T ary)
{
	return rb_long2int(RARRAY_LEN(ary));
}

struct RRegexp
{
	RBasic basic;
	re_pattern_buffer* ptr;
	VALUE src;
	c_ulong usecnt;
}

VALUE RREGEXP_SRC (T) (T r)
{
	return RREGEXP(r).src;
}

char* RREGEXP_SRC_PTR (T) (T r)
{
	return RSTRING_PTR(RREGEXP(r).src);
}

c_long RREGEXP_SRC_LEN (T) (T r)
{
	return RSTRING_LEN(RREGEXP(r).src);
}

c_long RREGEXP_SRC_END (T) (T r)
{
	return RSTRING_END(RREGEXP(r).src);
}

struct RHash
{
	RBasic basic;
	st_table* ntbl; // possibly 0
	int iter_lev;
	VALUE ifnone;
}

/* RHASH_TBL allocates st_table if not available. */

alias rb_hash_tbl RHASH_TBL;

int RHASH_ITER_LEV (T) (T h)
{
	return RHASH(h).iter_lev;
}

VALUE RHASH_IFNONE (T) (T h)
{
	return RHASH(h).ifnone;
}

st_table* RHASH_SIZE (T) (T h)
{
	return RHASH(h).ntbl ? RHASH(h).ntbl.num_entries : 0;
}

bool RHASH_EMPTY_P (T) (T h)
{
	return RHASH_SIZE(h) == 0;
}

struct RFile
{
	RBasic basic;
	rb_io_t* fptr;
}

struct RRational
{
	RBasic basic;
	VALUE num;
	VALUE den;
}

struct RComplex
{
	RBasic basic;
	VALUE real_;
	VALUE imag;
}

struct RData
{
	RBasic basic;
	void function (void*) dmark;
	void function (void*) dfree;
	void* data;
}

struct rb_data_type_t
{
	char* wrap_struct_name;
	void function (void*) dmark;
	void function (void*) dfree;
	size_t function (void*) dsize;
	void* reserved[3]; // For future extension. This array *must* be filled with ZERO.
	void* data; // This area can be used for any purpose by a programmer who define the type.
}

struct RTypedData
{
	RBasic basic;
	rb_data_type_t* type;
	VALUE typed_flag; // 1 or not
	void* data;
}

void* DATA_PTR (T) (T data)
{
	return RDATA(data).data;
}

bool RTYPEDDATA_P (VALUE v)
{
	return RTYPEDDATA(v).typed_flag == 1;
}

rb_data_type_t* RTYPEDDATA_TYPE (VALUE v)
{
	return RTYPEDDATA(v).type;
}

void* RTYPEDDATA_DATA (VALUE v)
{
	return RTYPEDDATA(v).data;
}

alias void function (void*) RUBY_DATA_FUNC;

VALUE rb_data_object_alloc (VALUE, void*, RUBY_DATA_FUNC, RUBY_DATA_FUNC);
VALUE rb_data_typed_object_alloc (VALUE klass, void* datap, rb_data_type_t*);
int rb_typeddata_is_kind_of (VALUE, rb_data_type_t*);
void* rb_check_typeddata (VALUE, rb_data_type_t*);

void* Check_TypedStruct (V) (V v, rb_data_type_t* t)
{
	return rb_check_typeddata(cast(VALUE) v, t);
}

const RUBY_DEFAULT_FREE = cast(RUBY_DATA_FUNC) - 1;
const RUBY_NEVER_FREE = cast(RUBY_DATA_FUNC) 0;

alias RUBY_DEFAULT_FREE RUBY_TYPED_DEFAULT_FREE;
alias RUBY_NEVER_FREE RUBY_TYPED_NEVER_FREE;

void Data_Wrap_Struct (Mark, Free) (VALUE klass, Mark mark, Free free, void* sval)
{
	rb_data_object_alloc(klass, sval, cast(RUBY_DATA_FUNC) mark, cast(RUBY_DATA_FUNC) free);
}

void Data_Wrap_Struct (Type, Free, Mark) (VALUE klass, Type type, Free free, Mark mark, Free free, ref void* sval)
{
	sval = ALLOC(type);
	memset(sval, 0, type.sizeof);
	Data_Wrap_Struct(klass, mark, free, sval);
}

VALUE TypedData_Wrap_Struct (VALUE klass, rb_data_type_t* data_type, void* sval)
{
	return rb_data_typed_object_alloc(klass, sval, data_type);
}

VALUE TypedData_Make_Struct (T) (VALUE klass, T type, rb_data_type_t* data_type, ref void* sval)
{
	sval = ALLOC(type);
	memset(sval, 0, type.sizeof);
	return TypedData_Wrap_Struct(klass, data_type, sval);
}

void Data_Get_Struct (type) (VALUE obj, ref void* sval)
{
	Check_Type(obj, T_DATA);
	sval = cast(T*)DATA_PTR(obj);
}

void TypedData_Get_Struct (type) (VALUE obj, rb_data_type_t* data_type, ref void* sval)
{
	sval = cast(type*)rb_check_typeddata(obj, data_type);
}

const RSTRUCT_EMBED_LEN_MAX = 3;

struct RStruct
{
	RBasic basic;
	
	union
	{
		struct
		{
			c_long len;
			VALUE* ptr;
		}
		
		VALUE[RSTRUCT_EMBED_LEN_MAX] ary;
	}
}

const RSTRUCT_EMBED_LEN_MASK = FL_USER2 | FL_USER1;
const RSTRUCT_EMBED_LEN_SHIFT = FL_USHIFT + 1;

c_long RSTRUCT_LEN (T) (T st)
{
	(RBASIC(st).flags & RSTRUCT_EMBED_LEN_MASK) ?
		cast(c_long)((RBASIC(st).flags >> RSTRUCT_EMBED_LEN_SHIFT) &
		    (RSTRUCT_EMBED_LEN_MASK >> RSTRUCT_EMBED_LEN_SHIFT)) :
		    	RSTRUCT(st).len;
}

int RSTRUCT_LENINT (T) (T st)
{
	return rb_long2int(RSTRUCT_LEN(st));
}

const RBIGNUM_EMBED_LEN_MAX = cast(int)((VALUE.sizeof * 3) / BDIGIT.sizeof);

struct RBignum
{
	RBasic basic;
	
	union
	{
		struct
		{
			c_long len;
			BDIGIT* digits;
		}
		
		BDIGIT[RBIGNUM_EMBED_LEN_MAX] ary;
	}
}

alias FL_USER1 RBIGNUM_SIGN_BIT;

bool RBIGNUM_SIGN (T) (T b)
{
	(RBASIC(b).flags & RBIGNUM_SIGN_BIT) != 0;
}

void RBIGNUM_SET_SIGN (B, Sign) (B b, Sign sign)
{
	sign ? (RBASIC(b).flags |= RBIGNUM_SIGN_BIT) : (RBASIC(b).flags &= ~RBIGNUM_SIGN_BIT);
}

alias RBIGNUM_SIGN RBIGNUM_POSITIVE_P;

void RBIGNUM_NEGATIVE_P (T) (T b)
{
	return !RBIGNUM_SIGN(b);
}

alias FL_USER2 RBIGNUM_EMBED_FLAG;
const RBIGNUM_EMBED_LEN_MASK = FL_USER5 | FL_USER4 | FL_USER3;
const RBIGNUM_EMBED_LEN_SHIFT = FL_USHIFT + 3;

c_long RBIGNUM_LEN (T) (T b)
{
	return (RBASIC(b).flags & RBIGNUM_EMBED_FLAG) ?
			cast(c_long)((RBASIC(b).flags >> RBIGNUM_EMBED_LEN_SHIFT) &
			    (RBIGNUM_EMBED_LEN_MASK >> RBIGNUM_EMBED_LEN_SHIFT)) :
			    	RBIGNUM(b).len;
}

BDIGIT* RBIGNUM_DIGITS (T) (T b)
{
	return (RBASIC(b).flags & RBIGNUM_EMBED_FLAG) ? RBIGNUM(b).ary : RBIGNUM(b).digits;
}

int BIGNUM_LENINT (T) (T b)
{
	return rb_long2int(RBIGNUM_LEN(b));
}

template R_CAST (T)
{
	alias T* R_CAST; 
}


R_CAST!(RBasic) RBASIC (T) (T obj)
{
	return cast(R_CAST!(RBasic)) obj;
}

R_CAST!(RObject) ROBJECT (T) (T obj)
{
	return cast(R_CAST!(RObject)) obj;
}

R_CAST!(RClass) RCLASS (T) (T obj)
{
	return cast(R_CAST!(RClass)) obj;
}

alias RCLASS RMODULE;

R_CAST!(RFloat) RFLOAT (T) (T obj)
{
	return cast(R_CAST!(RFloat)) obj;
}

R_CAST!(RString) RSTRING (T) (T obj)
{
	return cast(R_CAST!(RString)) obj;
}

R_CAST!(RRegexp) RREGEXP (T) (T obj)
{
	return cast(R_CAST!(RRegexp)) obj;
}

R_CAST!(RArray) RARRAY (T) (T obj)
{
	return cast(R_CAST!(RArray)) obj;
}

R_CAST!(RHash) RHASH (T) (T obj)
{
	return cast(R_CAST!(RHash)) obj;
}

R_CAST!(RData) RDATA (T) (T obj)
{
	return cast(R_CAST!(RData)) obj;
}

R_CAST!(RTypedData) RTYPEDDATA (T) (T obj)
{
	return cast(R_CAST!(RTypedData)) obj;
}

R_CAST!(RStruct) RSTRUCT (T) (T obj)
{
	return cast(R_CAST!(RStruct)) obj;
}

R_CAST!(RBignum) RBIGNUM (T) (T obj)
{
	return cast(R_CAST!(RBignum)) obj;
}

R_CAST!(RFile) RFILE (T) (T obj)
{
	return cast(R_CAST!(RFile)) obj;
}

R_CAST!(RRational) RRATIONAL (T) (T obj)
{
	return cast(R_CAST!(RRational)) obj;
}

R_CAST!(RComplex) RCOMPLEX (T) (T obj)
{
	return cast(R_CAST!(RComplex)) obj;
}

const FL_MARK = (cast(VALUE) 1) << 5;
const FL_RESERVED = (cast(VALUE) 1) << 6; /* will be used in the future GC */
const FL_FINALIZE = (cast(VALUE) 1) << 7;
const FL_TAINT = (cast(VALUE) 1) << 8;
const FL_UNTRUSTED = (cast(VALUE) 1) << 9;
const FL_EXIVAR = (cast(VALUE) 1) << 10;
const FL_FREEZE = (cast(VALUE) 1) << 11;

const FL_USHIFT = 12;

const FL_USER0 = (cast(VALUE) 1) << (FL_USHIFT + 0);
const FL_USER1 = (cast(VALUE) 1) << (FL_USHIFT + 1);
const FL_USER2 = (cast(VALUE) 1) << (FL_USHIFT + 2);
const FL_USER3 = (cast(VALUE) 1) << (FL_USHIFT + 3);
const FL_USER4 = (cast(VALUE) 1) << (FL_USHIFT + 4);
const FL_USER5 = (cast(VALUE) 1) << (FL_USHIFT + 5);
const FL_USER6 = (cast(VALUE) 1) << (FL_USHIFT + 6);
const FL_USER7 = (cast(VALUE) 1) << (FL_USHIFT + 7);
const FL_USER8 = (cast(VALUE) 1) << (FL_USHIFT + 8);
const FL_USER9 = (cast(VALUE) 1) << (FL_USHIFT + 9);
const FL_USER10 = (cast(VALUE) 1) << (FL_USHIFT + 10);
const FL_USER11 = (cast(VALUE) 1) << (FL_USHIFT + 11);
const FL_USER12 = (cast(VALUE) 1) << (FL_USHIFT + 12);
const FL_USER13 = (cast(VALUE) 1) << (FL_USHIFT + 13);
const FL_USER14 = (cast(VALUE) 1) << (FL_USHIFT + 14);
const FL_USER15 = (cast(VALUE) 1) << (FL_USHIFT + 15);
const FL_USER16 = (cast(VALUE) 1) << (FL_USHIFT + 16);
const FL_USER17 = (cast(VALUE) 1) << (FL_USHIFT + 17);
const FL_USER18 = (cast(VALUE) 1) << (FL_USHIFT + 18);
const FL_USER19 = (cast(VALUE) 1) << (FL_USHIFT + 19);

alias FL_USER0 FL_SINGLETON;

bool SPECIAL_CONST_P (VALUE x)
{
	return IMMEDIATE_P(x) || !RTEST(x);
}

bool FL_ABLE (VALUE x)
{
	return !SPECIAL_CONST_P(x) && BUILTIN_TYPE(x) != T_NODE;
}

bool FL_TEST (VALUE x, VALUE f)
{
	return FL_ABLE(x) ? cast(bool) (RBASIC(x).flags & f) : cast(bool) 0;
	/*auto a = cast(bool) (RBASIC(x).flags & f);
	pragma(msg, typeof(a).stringof);
	return false;*/
}

alias FL_TEST FL_ANY;

bool FL_ALL (VALUE x, VALUE f)
{
	return FL_TEST(x, f) == f;
}

void FL_SET (VALUE x, VALUE f)
{
	if (FL_ABLE(x))
		RBASIC(x).flags |= f;
}

void FL_UNSET (VALUE x, VALUE f)
{
	if (FL_ABLE(x))
		RBASIC(x).flags &= ~f;
}

void FL_REVERSE (VALUE x, VALUE f)
{
	if (FL_ABLE(x))
		RBASIC(x).flags ^= ~f;
}

bool OBJ_TAINTED (VALUE x)
{
	return !!FL_TEST(x, FL_TAINT);
}

void OBJ_TAINT (VALUE x)
{
	FL_SET(x, FL_TAINT);
}

bool OBJ_UNTRUSTED (VALUE x)
{
	return !!FL_TEST(x, FL_UNTRUSTED);
}

void OBJ_UNTRUST (VALUE x)
{
	FL_SET(x, FL_UNTRUSTED);
}

void OBJ_INFECT (VALUE x, VALUE s)
{
	if (FL_ABLE(x) && FL_ABLE(s))
		RBASIC(x).flags |= RBASIC(s).flags & (FL_TAINT | FL_UNTRUSTED);
}

bool OBJ_FROZEN (VALUE x)
{
	return !!FL_TEST(x, FL_FREEZE);
}

void OBJ_FREEZE (VALUE x)
{
	FL_SET(x, FL_FREEZE);
}

static if (SIZEOF_INT < SIZEOF_LONG)
{
	VALUE INT2NUM (VALUE v)
	{
		return INT2FIX(cast(int) v);
	}
	
	VALUE UINT2NUM (VALUE v)
	{
		return LONG2FIX(cast(uint) v);
	}
}

else
{
	VALUE INT2NUM_internal (int v)
	{
		return FIXABLE(v) ? INT2FIX(v) : rb_int2big(v);
	}
	
	alias INT2NUM_internal INT2NUM;
	
	VALUE UINT2NUM_internal (uint v)
	{
		return POSFIXABLE(v) ? LONG2FIX(v) : rb_uint2big(v);
	}

	alias UINT2NUM_internal UINT2NUM;
}

VALUE LONG2NUM_internal (c_long v)
{
	return FIXABLE(v) ? LONG2FIX(v) : rb_int2big(v);
}

alias LONG2NUM_internal LONG2NUM;

VALUE ULONG2NUM_internal (c_ulong v)
{
	return POSFIXABLE(v) ? LONG2FIX(v) : rb_uint2big(v);
}

alias ULONG2NUM_internal ULONG2NUM;

char NUM2CHR_internal (VALUE x)
{
	return ((TYPE(x) == T_STRING) && (RSTRING_LEN(x) >= 1)) ? RSTRING_PTR(x)[0] : cast(char)(NUM2INT(x) & 0xff);
}

alias NUM2CHR_internal NUM2CHR;

VALUE CHR2FIX (VALUE x)
{
	return INT2FIX(cast(c_long)(x & 0xff));
}

type* ALLOC_N (type) (size_t n)
{
	return cast(type*) xmalloc2(n, type.sizeof);
}

type* ALLOC (type) ()
{
	return cast(type*) xmalloc(type.sizeof);
}

void REALLOC_N (type) (ref type* var, size_t n)
{
	var = cast(type*)xrealloc2(cast(byte*) var, n, type.sizeof);
}

type* ALLOCA_N (type) (size_t n)
{
	return cast(type*) alloca(type.sizeof * n);
}

void MEMZERO (type) (void* p, size_t n)
{
	memset(p, 0, type.sizeof * n);
}

void MEMCPY (type) (void* p1, void* p2, size_t n)
{
	memcpy(p1, p2, type.sizeof * n);
}

void MEMMOVE (type) (void* p1, void* p2, size_t n)
{
	memmove(p1, p2, type.sizeof * n);
}

void MEMCMP (type) (void* p1, void* p2, size_t n)
{
	memcmp(p1, p2, type.sizeof * n);
}

void rb_obj_infect (VALUE, VALUE);

alias int ruby_glob_func (in char*, VALUE,  void*);
void rb_glob (in char*, void function (in char*, VALUE, void*), VALUE);
int ruby_glob (in char*, int, ruby_glob_func*, VALUE);
int ruby_brace_glob (in char*, int, ruby_glob_func*, VALUE);

VALUE rb_define_class (in char*, VALUE);
VALUE rb_define_module (in char*);
VALUE rb_define_class_under (VALUE, in char*, VALUE);
VALUE rb_define_module_under (VALUE, in char*);

void rb_include_module (VALUE, VALUE);
void rb_extend_object (VALUE, VALUE);

struct rb_global_variable_;

alias VALUE rb_gvar_getter_t (ID id, void* data, rb_global_variable_* gvar);
alias void rb_gvar_setter_t (VALUE val, ID id, void* data, rb_global_variable_* gvar);
alias void rb_gvar_marker_t (VALUE* var);

VALUE rb_gvar_undef_getter (ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_undef_setter (VALUE val, ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_undef_marker (VALUE* var);

VALUE rb_gvar_val_getter (ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_val_setter (VALUE val, ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_val_marker (VALUE* var);

VALUE rb_gvar_var_getter (ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_var_setter (VALUE val, ID id, void* data, rb_global_variable_* gvar);
void rb_gvar_var_marker (VALUE* var);

void rb_gvar_readonly_setter (VALUE val, ID id, void* data, rb_global_variable_* gvar);

void rb_define_variable (in char*, VALUE*);
void rb_define_virtual_variable (in char*, VALUE function (), void function ());
void rb_define_hooked_variable (in char*, VALUE*, VALUE function (), void function ());
void rb_define_readonly_variable (in char*, VALUE*);
void rb_define_in (VALUE, in char*, VALUE);
void rb_define_global_in (in char*, VALUE);

template RUBY_METHOD_FUNC (string func)
{
	const RUBY_METHOD_FUNC = "VALUE function () " ~ func; 
}

void rb_define_method (VALUE, in char*, VALUE function (), int);
void rb_define_module_function (VALUE, in char*, VALUE function (), int);
void rb_define_global_function (in char*, VALUE function (), int);

void rb_undef_method (VALUE, in char*);
void rb_define_alias (VALUE, in char*, in char*);
void rb_define_attr (VALUE, in char*, int, int);

void rb_global_variable (VALUE*);
void rb_gc_register_mark_object (VALUE);
void rb_gc_register_address (VALUE*);
void rb_gc_unregister_address (VALUE*);

ID rb_intern (in char*);
ID rb_intern2 (in char*, long);
ID rb_intern_str (VALUE str);
char *rb_id2name (ID);
ID rb_to_id (VALUE);
VALUE rb_id2str (ID);

template CONST_ID_CACHE (string result, alias str)
{
	const CONST_ID_CACHE = "static ID rb_intern_id_cache;

if (!rb_intern_id_cache)
    rb_intern_id_cache = rb_intern2(" ~ str.stringof ~ ", cast(c_long) strlen(" ~ str.stringof ~ "));

" ~ result ~ "rb_intern_id_cache;";
}

template CONST_ID (alias var, alias str)
{
	const CONST_ID = CONST_ID_CACHE!(var ~ " = ", str);
}

void rb_intern_const (char* str)
{
	rb_intern2(str, cast(c_long) strlen(str));
}

char *rb_class2name (VALUE);
char *rb_obj_classname (VALUE);

void rb_p (VALUE);

VALUE rb_eval_string (in char*);
VALUE rb_eval_string_protect (in char*, int*);
VALUE rb_eval_string_wrap (in char*, int*);
VALUE rb_funcall (VALUE, ID, int, ...);
VALUE rb_funcall2 (VALUE, ID, int, in VALUE*);
VALUE rb_funcall3 (VALUE, ID, int, in VALUE*);
int rb_scan_args (int, in VALUE*, in char*, ...);
VALUE rb_call_super (int, in VALUE*);

VALUE rb_gv_set (in char*, VALUE);
VALUE rb_gv_get (in char*);
VALUE rb_iv_get (VALUE, in char*);
VALUE rb_iv_set (VALUE, in char*, VALUE);

VALUE rb_equal (VALUE,VALUE);

VALUE *rb_ruby_verbose_ptr ();
VALUE *rb_ruby_debug_ptr ();

const ruby_verbose = "*rb_ruby_verbose_ptr()";
const ruby_debug = "*rb_ruby_debug_ptr()";

void rb_raise (VALUE, in char*, ...);
void rb_fatal (in char*, ...);
void rb_bug (in char*, ...);
void rb_bug_errno (in char*, int);
void rb_sys_fail (in char*);
void rb_mod_sys_fail (VALUE, in char*);
void rb_iter_break ();
void rb_exit (int);
void rb_notimplement ();

/* reports if `-W' specified */
void rb_warning (in char*, ...);
void rb_compile_warning (in char *, int, in char*, ...);
void rb_sys_warning (in char*, ...);
/* reports always */
void rb_warn (in char*, ...);
void rb_compile_warn (in char *, int, in char*, ...);

alias VALUE rb_block_call_func (VALUE, VALUE, int, VALUE*);

VALUE rb_each (VALUE);
VALUE rb_yield (VALUE);
VALUE rb_yield_values (int n, ...);
VALUE rb_yield_values2 (int n, in VALUE *argv);
VALUE rb_yield_splat (VALUE);
int rb_block_given_p ();
void rb_need_block ();
VALUE rb_iterate (VALUE function (VALUE), VALUE, VALUE function (), VALUE);
VALUE rb_block_call (VALUE, ID, int, VALUE*, VALUE function (), VALUE);
VALUE rb_rescue (VALUE function (), VALUE, VALUE function (), VALUE);
VALUE rb_rescue2 (VALUE function (), VALUE, VALUE function (), VALUE, ...);
VALUE rb_ensure (VALUE function (), VALUE, VALUE function (), VALUE);
VALUE rb_catch (in char*, VALUE function (), VALUE);
VALUE rb_catch_obj (VALUE, VALUE function (), VALUE);
void rb_throw (in char*, VALUE);
void rb_throw_obj (VALUE, VALUE);

VALUE rb_require (in char*);

version (D_LP64)
{
	void ruby_init_stack (VALUE*);
	
	void ruby_init_stack_ (VALUE* addr)
	{
		auto tmp = addr;
		ruby_init_stack(tmp);
	}
}

else
{
	void ruby_init_stack(VALUE*);
	
	void ruby_init_stack_ (VALUE* addr)
	{
		auto tmp = addr;
		ruby_init_stack(tmp);
	}
}

template RUBY_INIT_STACK ()
{
	const RUBY_INIT_STACK = "VALUE variable_in_this_stack_frame;
ruby_init_stack_(&variable_in_this_stack_frame);";
}

void ruby_init ();
void *ruby_options (int, char**);
int ruby_run_node (void*);
int ruby_exec_node (void*);

extern __gshared VALUE rb_mKernel;
extern __gshared VALUE rb_mComparable;
extern __gshared VALUE rb_mEnumerable;
extern __gshared VALUE rb_mErrno;
extern __gshared VALUE rb_mFileTest;
extern __gshared VALUE rb_mGC;
extern __gshared VALUE rb_mMath;
extern __gshared VALUE rb_mProcess;
extern __gshared VALUE rb_mWaitReadable;
extern __gshared VALUE rb_mWaitWritable;

extern __gshared VALUE rb_cBasicObject;
extern __gshared VALUE rb_cObject;
extern __gshared VALUE rb_cArray;
extern __gshared VALUE rb_cBignum;
extern __gshared VALUE rb_cBinding;
extern __gshared VALUE rb_cClass;
extern __gshared VALUE rb_cCont;
extern __gshared VALUE rb_cDir;
extern __gshared VALUE rb_cData;
extern __gshared VALUE rb_cFalseClass;
extern __gshared VALUE rb_cEncoding;
extern __gshared VALUE rb_cEnumerator;
extern __gshared VALUE rb_cFile;
extern __gshared VALUE rb_cFixnum;
extern __gshared VALUE rb_cFloat;
extern __gshared VALUE rb_cHash;
extern __gshared VALUE rb_cInteger;
extern __gshared VALUE rb_cIO;
extern __gshared VALUE rb_cMatch;
extern __gshared VALUE rb_cMethod;
extern __gshared VALUE rb_cModule;
extern __gshared VALUE rb_cNameErrorMesg;
extern __gshared VALUE rb_cNilClass;
extern __gshared VALUE rb_cNumeric;
extern __gshared VALUE rb_cProc;
extern __gshared VALUE rb_cRandom;
extern __gshared VALUE rb_cRange;
extern __gshared VALUE rb_cRational;
extern __gshared VALUE rb_cComplex;
extern __gshared VALUE rb_cRegexp;
extern __gshared VALUE rb_cStat;
extern __gshared VALUE rb_cString;
extern __gshared VALUE rb_cStruct;
extern __gshared VALUE rb_cSymbol;
extern __gshared VALUE rb_cThread;
extern __gshared VALUE rb_cTime;
extern __gshared VALUE rb_cTrueClass;
extern __gshared VALUE rb_cUnboundMethod;

extern __gshared VALUE rb_eException;
extern __gshared VALUE rb_eStandardError;
extern __gshared VALUE rb_eSystemExit;
extern __gshared VALUE rb_eInterrupt;
extern __gshared VALUE rb_eSignal;
extern __gshared VALUE rb_eFatal;
extern __gshared VALUE rb_eArgError;
extern __gshared VALUE rb_eEOFError;
extern __gshared VALUE rb_eIndexError;
extern __gshared VALUE rb_eStopIteration;
extern __gshared VALUE rb_eKeyError;
extern __gshared VALUE rb_eRangeError;
extern __gshared VALUE rb_eIOError;
extern __gshared VALUE rb_eRuntimeError;
extern __gshared VALUE rb_eSecurityError;
extern __gshared VALUE rb_eSystemCallError;
extern __gshared VALUE rb_eThreadError;
extern __gshared VALUE rb_eTypeError;
extern __gshared VALUE rb_eZeroDivError;
extern __gshared VALUE rb_eNotImpError;
extern __gshared VALUE rb_eNoMemError;
extern __gshared VALUE rb_eNoMethodError;
extern __gshared VALUE rb_eFloatDomainError;
extern __gshared VALUE rb_eLocalJumpError;
extern __gshared VALUE rb_eSysStackError;
extern __gshared VALUE rb_eRegexpError;
extern __gshared VALUE rb_eEncodingError;
extern __gshared VALUE rb_eEncCompatError;

extern __gshared VALUE rb_eScriptError;
extern __gshared VALUE rb_eNameError;
extern __gshared VALUE rb_eSyntaxError;
extern __gshared VALUE rb_eLoadError;

extern __gshared VALUE rb_eMathDomainError;

extern __gshared VALUE rb_stdin, rb_stdout, rb_stderr;

VALUE rb_class_of (VALUE obj)
{
	if (IMMEDIATE_P(obj))
	{
		if (FIXNUM_P(obj)) return rb_cFixnum;
		if (obj == Qtrue) return rb_cTrueClass;
		if (SYMBOL_P(obj)) return rb_cSymbol;
	}
	
	else if (!RTEST(obj))
	{
		if (obj == Qnil) return rb_cNilClass;
		if (obj == Qfalse) return rb_cFalseClass;
	}
	
	return RBASIC(obj).klass;
}

int rb_type (VALUE obj)
{
	if (IMMEDIATE_P(obj))
	{
		if (FIXNUM_P(obj)) return T_FIXNUM;
		if (obj == Qtrue) return T_TRUE;
		if (SYMBOL_P(obj)) return T_SYMBOL;
		if (obj == Qundef) return T_UNDEF;
	}
	
	else if (!RTEST(obj))
	{
		if (obj == Qnil) return T_NIL;
		if (obj == Qfalse) return T_FALSE;
	}
	
	return BUILTIN_TYPE(obj);
}

/*
#define RB_TYPE_P(obj, type) ( \
((type) == T_FIXNUM) ? FIXNUM_P(obj) : \
((type) == T_TRUE) ? ((obj) == Qtrue) : \
((type) == T_FALSE) ? ((obj) == Qfalse) : \
((type) == T_NIL) ? ((obj) == Qnil) : \
((type) == T_UNDEF) ? ((obj) == Qundef) : \
((type) == T_SYMBOL) ? SYMBOL_P(obj) : \
(!SPECIAL_CONST_P(obj) && BUILTIN_TYPE(obj) == (type)))
*/

bool rb_type_p (VALUE obj, int type)
{
	return rb_type(obj) == type;
}


int rb_special_const_p(VALUE obj)
{
	return SPECIAL_CONST_P(obj) ? Qtrue : Qfalse;
}

//import ruby.c.missing;
//import ruby.c.intern;

/*static if (EXTLIB && USE_DLN_A_OUT)
{
	char** dln_libs_to_be_linked = [EXTLIB, 0].ptr;
}*/

const RUBY_GLOBAL_SETUP = true;

void ruby_sysinit (int*, char***);

const RUBY_VM = 1; /* YARV */
const HAVE_NATIVETHREAD = true;
int ruby_native_thread_p ();

const RUBY_EVENT_NONE = 0x0000;
const RUBY_EVENT_LINE = 0x0001;
const RUBY_EVENT_CLASS = 0x0002;
const RUBY_EVENT_END = 0x0004;
const RUBY_EVENT_CALL = 0x0008;
const RUBY_EVENT_RETURN = 0x0010;
const RUBY_EVENT_C_CALL = 0x0020;
const RUBY_EVENT_C_RETURN = 0x0040;
const RUBY_EVENT_RAISE = 0x0080;
const RUBY_EVENT_ALL = 0xffff;
const RUBY_EVENT_VM = 0x10000;
const RUBY_EVENT_SWITCH = 0x20000;
const RUBY_EVENT_COVERAGE = 0x40000;

alias uint rb_event_flag_t;
alias void function (rb_event_flag_t, VALUE data, VALUE, ID, VALUE klass) rb_event_hook_func_t;

struct rb_event_hook_t
{
	rb_event_flag_t flag;
	rb_event_hook_func_t func;
	VALUE data;
	rb_event_hook_t* next;
}

const RB_EVENT_HOOKS_HAVE_CALLBACK_DATA = true;

void rb_add_event_hook (rb_event_hook_func_t func, rb_event_flag_t events, VALUE data);
int rb_remove_event_hook (rb_event_hook_func_t func);

void* rb_ia64_bsp();

/* locale insensitive functions */

int rb_isascii (int c)
{
	return cast(c_ulong) c < 128;
}

/*int rb_isalnum (int c);
int rb_isalpha (int c);
int rb_isblank (int c);
int rb_iscntrl (int c);
int rb_isdigit (int c);
int rb_isgraph (int c);
int rb_islower (int c);
int rb_isprint (int c);
int rb_ispunct (int c);
int rb_isspace (int c);
int rb_isupper (int c);
int rb_isxdigit (int c);
int rb_tolower (int c);
int rb_toupper (int c);*/

/*
#ifndef ISPRINT
#define ISASCII(c) rb_isascii((unsigned char)(c))
#undef ISPRINT
#define ISPRINT(c) rb_isprint((unsigned char)(c))
#define ISSPACE(c) rb_isspace((unsigned char)(c))
#define ISUPPER(c) rb_isupper((unsigned char)(c))
#define ISLOWER(c) rb_islower((unsigned char)(c))
#define ISALNUM(c) rb_isalnum((unsigned char)(c))
#define ISALPHA(c) rb_isalpha((unsigned char)(c))
#define ISDIGIT(c) rb_isdigit((unsigned char)(c))
#define ISXDIGIT(c) rb_isxdigit((unsigned char)(c))
#endif
#define TOUPPER(c) rb_toupper((unsigned char)(c))
#define TOLOWER(c) rb_tolower((unsigned char)(c))*/

/*static if (ISPRINT)
{
	int ISASCII (int c)
	{
		return rb_isascii(cast(ubyte) c);
	}
}*/


/*int ISPRINT (int c)
{
	return rb_isprint(cast(ubyte) c);
}

int ISSPACE (int c)
{
	return rb_isspace(cast(ubyte) c);
}

int ISUPPER (int c)
{
	return rb_isupper(cast(ubyte) c);
}

int ISLOWER (int c)
{
	return rb_islower(cast(ubyte) c);
}

int ISALNUM (int c)
{
	return rb_isalnum(cast(ubyte) c);
}

int ISALPHA (int c)
{
	return rb_isalpha(cast(ubyte) c);
}

int ISDIGIT (int c)
{
	return rb_isdigit(cast(ubyte) c);
}

int ISXDIGIT (int c)
{
	return rb_isxdigit(cast(ubyte) c);
}

int TOUPPER (int c)
{
	return rb_toupper(cast(ubyte) c);
}

int TOLOWER (int c)
{
	return rb_tolower(cast(ubyte) c);
}*/

int st_strcasecmp (in char* s1, in char* s2);
int st_strncasecmp(in char* s1, in char* s2, size_t n);
alias st_strcasecmp STRCASECMP;
alias st_strncasecmp STRNCASECMP;

c_ulong ruby_strtoul (in char* str, char** endptr,int base);
alias ruby_strtoul STRTOUL;

template InitVM (string ext)
{
	const InitVM = "{void InitVM_" ~ ext ~ "();InitVM_" ~ ext ~ "();}";
}

int ruby_snprintf (char* str, size_t n, in char* fmt, ...);
int ruby_vsnprintf (char* str, size_t n, in char* fmt, va_list ap);
