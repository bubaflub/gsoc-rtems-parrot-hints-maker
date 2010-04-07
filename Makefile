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
	(echo "package init::hints::$(RTEMS_CPU)";\
	 echo ;\
	 echo "use strict;"; \
	 echo "use warnings;"; \
	 echo ;\
	 echo "sub runstep {"; \
	 echo "    my ( \$$self, \$$conf ) = @_;"; \
	 echo "}"; \
	 echo ;\
	 echo "1;"; \
	 echo ;\
         ) >$(RTEMS_CPU)-$(RTEMS_BSP).pm

CONFIGURE:
	(echo "=variables";\
	echo ;\
	echo "CC=$(CC)";\
	echo "CXX=$(CXX)";\
	echo "AS=$(AS)";\
	echo "LD=$(LD)";\
	echo "NM=$(NM)";\
	echo "AR=$(AR)";\
	echo ;\
	echo "=general";\
	echo "cc=\$$CC";\
	echo "cxx=\$$CXX";\
	echo "ld=\$$LD";\
	echo "verbose";\
	echo "hintsfile=$(RTEMS_CPU)-$(RTEMS_BSP)";\
	echo ;\
	echo "=steps";\
	echo ;\
	echo "init::manifest nomanicheck";\
	echo "init::defaults";\
	echo "init::install";\
	echo "init::hints verbose-step";\
	echo "init::headers";\
	echo "inter::progs verbose-step";\
	echo "inter::make";\
	echo "inter::lex";\
	echo "inter::yacc";\
	echo "auto::gcc";\
	echo "auto::glibc";\
	echo "auto::backtrace";\
	echo "auto::fink";\
	echo "# auto::macports";\
	echo "# auto::msvc";\
	echo "auto::attributes";\
	echo "auto::warnings";\
	echo "init::optimize";\
	echo "inter::shlibs";\
	echo "inter::libparrot";\
	echo "inter::charset";\
	echo "inter::encoding";\
	echo "inter::types";\
	echo "auto::ops";\
	echo "auto::alignptrs";\
	echo "auto::headers";\
	echo "auto::sizes";\
	echo "auto::byteorder";\
	echo "auto::va_ptr";\
	echo "auto::format";\
	echo "auto::isreg";\
	echo "auto::arch";\
	echo "auto::jit";\
	echo "auto::frames";\
	echo "auto::cpu";\
	echo "auto::inline";\
	echo "auto::gc";\
	echo "auto::memalign";\
	echo "auto::signal";\
	echo "auto::socklen_t";\
	echo "auto::env";\
	echo "auto::extra_nci_thunks";\
	echo "# auto::gmp";\
	echo "auto::readline";\
	echo "# auto::pcre";\
	echo "# auto::opengl";\
	echo "auto::gettext";\
	echo "auto::snprintf";\
	echo "# auto::perldoc";\
	echo "# auto::ctags";\
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
	rm -f $(RTEMS_CPU)-$(RTEMS_BSP).pm
	rm -f rtems_parrot_config_directives
