#
#   Makefile to pull BSP specific information and write a Parrot hints file
#

# bail if $RTEMS_MAKEFILE_PATH is not set
#ifeq($(origin RTEMS_MAKEFILE_PATH),undefined)
#	$(warning RTEMS_MAKEFILE_PATH is not set)
#endif

include $(RTEMS_MAKEFILE_PATH)/Makefile.inc

include $(RTEMS_CUSTOM)
include $(PROJECT_ROOT)/make/leaf.cfg

all: HINTS CONFIGURE

HINTS:
	(echo "package init::hints::$(RTEMS_CPU)_$(RTEMS_BSP);";\
	 echo ;\
	 echo "use strict;"; \
	 echo "use warnings;"; \
	 echo ;\
	 echo "sub runstep {"; \
	 echo "    my ( \$$self, \$$conf ) = @_;"; \
	 echo "    # set rtems lib"; \
	 echo "    \$$conf->data->set( libs => ' -lrtemsbsp -lrtemscpu' );"; \
	 echo "    # set os specific information, corresponds to auto::arch"; \
	 echo "    \$$conf->data->set("; \
	 echo "        cpuarch => '$(RTEMS_CPU)',"; \
	 echo "        osname => '$(RTEMS_BSP)',"; \
	 echo "        TEMP_atomic_o => '',"; \
	 echo "        platform => 'generic',"; \
	 echo "    );"; \
	 echo "    # set jit information, corresponds to auto::jit"; \
	 echo "    \$$conf->data->set("; \
	 echo "        jitcapable => 0,"; \
	 echo "        execcapable => 0"; \
	 echo "    );"; \
	 echo "    # set size information, corresponds to auto::sizes"; \
	 echo "    \$$conf->data->set("; \
	 echo "        int2_t => 'short',"; \
	 echo "        int4_t => 'int',"; \
	 echo "        float4_t => 'float',"; \
	 echo "        float8_t => 'double',"; \
	 echo "        intvalmin => 'LONG_MIN',"; \
	 echo "        intvalmax => 'LONG_MAX',"; \
	 echo "        intvalsize => 8,"; \
	 echo "        floatvalmin => 'DBL_MIN',"; \
	 echo "        floatvalmax => 'DBL_MAX',"; \
	 echo "        hugeintval => 'long',"; \
	 echo "        hugeintvalsize => 8,"; \
	 echo "        hugefloatval => 'long double',"; \
	 echo "        hugefloatvalsize => 16,"; \
	 echo "        opcode_t_size => 8,"; \
	 echo "        ptrsize => 8,"; \
	 echo "        shortsize => 2,"; \
	 echo "        intsize => 4,"; \
	 echo "        doublesize => 8,"; \
	 echo "        longsize => 8,"; \
	 echo "        numvalsize => 8,"; \
	 echo "    );"; \
	 echo "    # set number format, corresponds to auto::format"; \
	 echo "    \$$conf->data->set("; \
	 echo "        intvalfmt => '\%ld',"; \
	 echo "        floatvalfmt => '\%.15g',"; \
	 echo "        nvsize => 8,"; \
	 echo "    );"; \
	 echo "    # set endian information, corresponds to auto::byteorder"; \
	 echo "    \$$conf->data->set("; \
	 echo "        bigendian => 1,"; \
	 echo "        byteorder => '4321'"; \
	 echo "    );"; \
	 echo "    # disable ICU, corresponds to auto::icu"; \
	 echo "    \$$conf->data->set("; \
	 echo "        has_icu    => 0,"; \
	 echo "        icu_shared => '',"; \
	 echo "        icu_dir    => '',"; \
	 echo "    );"; \
	 echo "    # disable OpenGL, corresponds to auto::opengl"; \
	 echo "    \$$conf->data->set("; \
	 echo "        has_opengl => 0,"; \
	 echo "        HAS_OPENGL => 0,"; \
	 echo "        opengl_lib => '',"; \
	 echo "        has_glut   => 0,"; \
	 echo "        HAS_GLUT   => 0,"; \
	 echo "    );"; \
	 echo "    # disable dynamic building of NCI call frames,"; \
	 echo "    # corresponds to auto::frames"; \
	 echo "    \$$conf->data->set( cc_build_call_frames  => '');"; \
	 echo "    # set memory information, corresponds to auto::memalign"; \
	 echo "    \$$conf->data->set("; \
	 echo "        memalign => 'memalign',"; \
	 echo "        ptrcast => 'long',"; \
	 echo "    );"; \
	 echo "    # set isreg information, corresponds to auto::isreg"; \
	 echo "    \$$conf->data->set("; \
	 echo "        isreg => 1,"; \
	 echo "    );"; \
	 echo "    # set pointer information, corresponds to auto::va_ptr"; \
	 echo "    \$$conf->data->set("; \
	 echo "        va_ptr_type => 'register',"; \
	 echo "    );"; \
	 echo "    # set signal information, corresponds to auto::signals"; \
	 echo "    \$$conf->data->set("; \
	 echo "        has___sighandler_t => undef,"; \
	 echo "        has_sigatomic_t => undef,"; \
	 echo "        has_sigaction => undef,"; \
	 echo "        has_setitimer => undef,"; \
	 echo "    );"; \
	 echo "    # set un/setenv, corresponds to auto::env"; \
	 echo "    \$$conf->data->set("; \
	 echo "        setenv => 1,"; \
	 echo "        unsetenv => 1,"; \
	 echo "    );"; \
	 echo "    # set inline information, corresponds to auto::inline"; \
	 echo "    \$$conf->data->set("; \
	 echo "        inline => 'inline',"; \
	 echo "    );"; \
	 echo "    # set socklen_t information, corresponds to auto::socklen_t"; \
	 echo "    \$$conf->data->set("; \
	 echo "        has_socklen_t => 1,"; \
	 echo "    );"; \
	 echo "    # set backtrace information, corresponds to auto::backtrace"; \
	 echo "    \$$conf->data->set("; \
	 echo "        PARROT_HAS_DLINFO => 1 ,"; \
	 echo "        backtrace => 1,"; \
	 echo "    );"; \
	 echo "    # set negative zero information,"; \
	 echo "    # corresponds to auto::neg_0"; \
	 echo "    \$$conf->data->set("; \
	 echo "        has_negative_zero => 0,"; \
	 echo "    );"; \
	 echo "}"; \
	 echo ;\
	 echo "1;"; \
	 echo ;\
         ) >$(RTEMS_CPU)_$(RTEMS_BSP).pm

#
# attempt to config with the bare minimum set of steps
#
# notes:
#
# currently, auto::jit is run because it unconditionally sets 
# many jit configure variables to zero.  when parrot gets a
# different jit setup then we'll have to disable that step
# and provide that information in the hints file
#
# auto::ctags checks the development environment if
# ctags is installed and thus can be run
#
# auto::perldoc checks if the development environment has
# a sane perldoc installation 
#
# auto::ops checks the parrot source to see which ops
# files exist
#
# since auto::gc currently has an unconditional default
# we can enable it.  in the future we may have to specify
# a garbage collector if parrot has an incompatible default
#
# inter::libparrot determines if we should build libparrot
# statically or dynamically.  we will probably have to 
# provide this information in the hints file eventually
#
# inter::charset and inter::encoding determine which
# charset and encoding should be included with parrot
#
# inter::types sets defaults for intval (defaults to long)
# floatval (defaults to double) and opcode_t (defaults to long)
#
# auto::pmc sets the list of PMCs to build
# 

CONFIGURE:
	(echo "=variables";\
	echo ;\
	echo "CC=$(CC)";\
	echo "CXX=$(CXX)";\
	echo "AS=$(AS)";\
	echo "LD=$(LD)";\
	echo "NM=$(NM)";\
	echo "AR=$(AR)";\
	echo "CFLAGS=$(CFLAGS)";\
	echo ;\
	echo "=general";\
	echo ;\
	echo "cc=\$$CC";\
	echo "cxx=\$$CXX";\
	echo "link=\$$CXX";\
	echo "ld=\$$LD";\
	echo "ccflags=\$$CFLAGS";\
	echo "hintsfile=$(RTEMS_CPU)_$(RTEMS_BSP)";\
	echo ;\
	echo "=steps";\
	echo ;\
	echo "init::manifest nomanicheck";\
	echo "init::defaults";\
	echo "init::install";\
	echo "init::hints verbose-step";\
	echo "init::headers";\
	echo "# inter::progs";\
	echo "# inter::make";\
	echo "# inter::lex";\
	echo "# inter::yacc";\
	echo "# auto::gcc";\
	echo "# auto::glibc";\
	echo "# auto::backtrace";\
	echo "# auto::msvc";\
	echo "# auto::attributes";\
	echo "# auto::warnings";\
	echo "# auto::arch";\
	echo "# auto::cpu";\
	echo "# init::optimize";\
	echo "# inter::shlibs";\
	echo "inter::libparrot";\
	echo "inter::charset";\
	echo "inter::encoding";\
	echo "inter::types";\
	echo "auto::ops";\
	echo "auto::pmc";\
	echo "# auto::alignptrs";\
	echo "# auto::headers";\
	echo "# auto::sizes";\
	echo "# auto::byteorder";\
	echo "# auto::va_ptr";\
	echo "# auto::format";\
	echo "# auto::isreg";\
	echo "auto::jit";\
	echo "# auto::frames";\
	echo "# auto::inline";\
	echo "auto::gc";\
	echo "# auto::memalign";\
	echo "# auto::signal";\
	echo "# auto::socklen_t";\
	echo "# auto::neg_0";\
	echo "# auto::thread";\
	echo "# auto::env";\
	echo "# auto::gmp";\
	echo "# auto::readline";\
	echo "# auto::pcre";\
	echo "# auto::opengl";\
	echo "# auto::zlib";\
	echo "# auto::gettext";\
	echo "# auto::snprintf";\
	echo "auto::perldoc";\
	echo "auto::ctags";\
	echo "auto::revision";\
	echo "# auto::icu";\
	echo "gen::config_h";\
	echo "gen::core_pmcs";\
	echo "# gen::opengl";\
	echo "gen::makefiles";\
	echo "gen::platform";\
	echo "gen::config_pm";\
	echo ;\
	echo "=cut";\
	) >rtems_parrot_config_directives

realclean:
	rm -f $(RTEMS_CPU)_$(RTEMS_BSP).pm
	rm -f rtems_parrot_config_directives
