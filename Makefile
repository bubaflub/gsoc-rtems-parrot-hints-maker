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

all: HINTS

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

realclean:
	rm -f $(RTEMS_CPU)-$(RTEMS_BSP).pm
