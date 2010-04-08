/*
 *  $Id$
 *
 * RTEMS Project (http://www.rtems.org/)
 *
 */

/**
 * Parrot start and shell command.
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>

#include <rtems.h>
#include <rtems/shell.h>
#include <rtems/untar.h>

/*
 *  The tarfile is built automatically externally so we need to account
 *  for the leading symbol on the names.
 */
#if defined(__sh__)
#define SYM(_x) _x
  #else
#define SYM(_x) _ ## _x
  #endif

/**
 * The shell-init tarfile parameters.
 */
extern int SYM(binary_shell_init_tar_start);
extern int SYM(binary_shell_init_tar_size);

#define TARFILE_START SYM(binary_shell_init_tar_start)
#define TARFILE_SIZE  SYM(binary_shell_init_tar_size)

/**
 * Start the RTEMS Shell.
 */
void
shell_start (void)
{
  rtems_status_code sc;
  printf ("Starting shell....\n\n");
  sc = rtems_shell_init ("rp", 60 * 1024, 150, "/dev/console", 0, 1, NULL);
  if (sc != RTEMS_SUCCESSFUL)
    printf ("error: starting shell: %s (%d)\n", rtems_status_text (sc), sc);
}

/**
 * Run the /shell-init script.
 */
void
shell_init_script (void)
{
  rtems_status_code sc;
  printf ("Running /shell-init....\n\n");
  sc = rtems_shell_script ("rp", 60 * 1024, 160, "/shell-init", "stdout",
                           0, 1, 1);
  if (sc != RTEMS_SUCCESSFUL)
    printf ("error: running shell script: %s (%d)\n", rtems_status_text (sc), sc);
}

int
setup_rootfs (void)
{
  rtems_status_code sc;

  printf("Loading filesystem: ");

  sc = Untar_FromMemory((void *)(&TARFILE_START), (size_t)&TARFILE_SIZE);
  
  if (sc != RTEMS_SUCCESSFUL)
  {
    printf ("error: untar failed: %s\n", rtems_status_text (sc));
    return 1;
  }

  printf ("successful\n");

  return 0;
}

int shell_parrot_main(int argc, char * argv[]);

int
main (int argc, char* argv[])
{
  struct termios term;
  int            ret;

#if pc586
  int arg;
  for (arg = 1; arg < argc; arg++)
    if (strcmp (argv[arg], "--gdb") == 0)
      pc386_gdb_init ();
#endif

  if (tcgetattr(fileno(stdout), &term) < 0)
    printf ("error: cannot get terminal attributes: %s\n", strerror (errno));
  cfsetispeed (&term, B115200);
  cfsetospeed (&term, B115200);
  if (tcsetattr (fileno(stdout), TCSADRAIN, &term) < 0)
    printf ("error: cannot set terminal attributes: %s\n", strerror (errno));
  
  if (tcgetattr(fileno(stdin), &term) < 0)
    printf ("error: cannot get terminal attributes: %s\n", strerror (errno));
  cfsetispeed (&term, B115200);
  cfsetospeed (&term, B115200);
  if (tcsetattr (fileno(stdin), TCSADRAIN, &term) < 0)
    printf ("error: cannot set terminal attributes: %s\n", strerror (errno));

  ret = setup_rootfs ();
  if (ret)
    exit (ret);
  
  rtems_shell_add_cmd ("parrot", "misc",
                       "Parrot VM", shell_parrot_main);
  
  shell_init_script ();
  while (true)
    shell_start ();
  
  rtems_task_delete (RTEMS_SELF);

  return 0;
}

#if pc586
void
rtems_fatal_error_occurred (uint32_t code)
{
  printf ("fatal error: %08lx\n", code);
  for (;;);
}
#endif
