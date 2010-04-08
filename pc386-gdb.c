/*
 *  $Id$
 *
 * RTEMS Project (http://www.rtems.org/)
 *
 * Copyright 2007 Chris Johns (chrisj@rtems.org)
 */

/**
 * PC386 GDB support.
 */

#include <stdio.h>

#include <bsp.h>
#include <uart.h>

int remote_debug;

void
pc386_gdb_init ()
{
  printf ("GDB Initialisation\n");

  i386_stub_glue_init (BSP_UART_COM2);

  /*
   * Init GDB stub itself
   */
  set_debug_traps();

  /*
   * Init GDB break in capability, has to be called after set_debug_traps
   */
  i386_stub_glue_init_breakin();

  /*
   * Put breakpoint in and stop and wait for GDB.
   */
  breakpoint();
}
