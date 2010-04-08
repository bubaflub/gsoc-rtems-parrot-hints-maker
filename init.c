/*
 * $Id$
 */

/**
 * Configure the RTEMS initialisation.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdlib.h>

#include <rtems.h>

#if !RTEMS_APP_NETWORKING
#undef RTEMS_NETWORKING
#endif

#ifdef RTEMS_NETWORKING
#include <rtems/rtems_bsdnet.h>
#include <rtems/dhcp.h>
#endif

/**
 * Configure base RTEMS resources.
 */
#define CONFIGURE_RTEMS_INIT_TASKS_TABLE
#define CONFIGURE_MEMORY_OVERHEAD                  512
#define CONFIGURE_MAXIMUM_TASKS                    rtems_resource_unlimited (10)
#define CONFIGURE_MAXIMUM_SEMAPHORES               rtems_resource_unlimited (10)
#define CONFIGURE_MAXIMUM_MESSAGE_QUEUES           rtems_resource_unlimited (5)
#define CONFIGURE_MAXIMUM_PARTITIONS               rtems_resource_unlimited (2)
#define CONFIGURE_MAXIMUM_TIMERS                   10

/**
 * Configure drivers.
 */
#define CONFIGURE_MAXIMUM_DRIVERS                  10
#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER

/**
 * Configure file system and libblock.
 */
#define CONFIGURE_USE_IMFS_AS_BASE_FILESYSTEM
#define CONFIGURE_LIBIO_MAXIMUM_FILE_DESCRIPTORS   20
#define CONFIGURE_APPLICATION_NEEDS_LIBBLOCK
#define CONFIGURE_SWAPOUT_TASK_PRIORITY            15

#if RTEMS_APP_IDEDISK
#define CONFIGURE_BDBUF_CACHE_MEMORY_SIZE          (16 * 1024 * 1024)
#define CONFIGURE_BDBUF_MAX_READ_AHEAD_BLOCKS      8
#define CONFIGURE_BDBUF_MAX_WRITE_BLOCKS           32
#define CONFIGURE_APPLICATION_NEEDS_IDE_DRIVER
#define CONFIGURE_APPLICATION_NEEDS_ATA_DRIVER
#define CONFIGURE_ATA_DRIVER_TASK_PRIORITY         14
#endif

/**
 * Tell confdefs.h to provide the configuration.
 */
#define CONFIGURE_INIT

#include <rtems/confdefs.h>

#ifdef RTEMS_NETWORKING

#define CONFIGURE_NETWORK_PRIORITY      10

#if pc586
#define LIBBSDPORT      1
#define MULTI_NETDRIVER 0
#define NEK             0

#include <rtems/pci.h>

#if LIBBSDPORT

#include <bsp/libbsdport_api.h>

driver_t* libbsdport_netdriver_table[] =
{
  &libbsdport_rl_driver,
  &libbsdport_re_driver,
  &libbsdport_fxp_driver,
  NULL
};

static int libbsdport_net_attach (struct rtems_bsdnet_ifconfig* ocfg, int attaching);

static struct rtems_bsdnet_ifconfig libbsdport_config[] =
{
  { "", libbsdport_net_attach, NULL }
};

static int libbsdport_net_attach (struct rtems_bsdnet_ifconfig* ocfg, int attaching)
{
  int result;
  result = pci_initialize ();
  if (result)
  {
    printk ("PCI initialise failed\n");
    return result;
  }
  printk ("Initialising libbsdport...\n");
  result = libbsdport_netdriver_attach (&libbsdport_config[0], attaching);
  if (result)
    printk ("libbsdport failed: %d: %s\n", result, strerror (result));
  return result;
}

#define CONFIGURE_NETWORK_DRIVER_NAME   ""
#define CONFIGURE_NETWORK_DRIVER_ATTACH libbsdport_net_attach

#elif MULTI_NETDRIVER

int rtems_fxp_attach(struct rtems_bsdnet_ifconfig *config, int attaching);
int rtems_3c509_driver_attach (struct rtems_bsdnet_ifconfig *, int);
int rtems_fxp_attach (struct rtems_bsdnet_ifconfig *, int);
int rtems_elnk_driver_attach (struct rtems_bsdnet_ifconfig *, int);
int rtems_dec21140_driver_attach (struct rtems_bsdnet_ifconfig *, int);
/* these don't probe and will be used even if there's no device :-( */
int rtems_ne_driver_attach (struct rtems_bsdnet_ifconfig *, int);
int rtems_wd_driver_attach (struct rtems_bsdnet_ifconfig *, int);

static struct rtems_bsdnet_ifconfig isa_netdriver_config[] =
{
  { "ep0", rtems_3c509_driver_attach,         isa_netdriver_config + 1 },
  /* qemu cannot configure irq-no :-(; has it hardwired to 9 */
  { "ne1", rtems_ne_driver_attach, 0, irno: 9 },
};

static struct rtems_bsdnet_ifconfig pci_netdriver_config[]=
{
  { "dc1",   rtems_dec21140_driver_attach, pci_netdriver_config + 1 },
  { "fxp1",  rtems_fxp_attach,             pci_netdriver_config + 2 },
  { "elnk1", rtems_elnk_driver_attach,     isa_netdriver_config },
};

extern int if_index;

static int net_prober (struct rtems_bsdnet_ifconfig* ocfg, int attaching)
{
  struct rtems_bsdnet_ifconfig* cfg = NULL;
  int                           if_index_pre;
  if (attaching)
    cfg = pci_initialize () ? isa_netdriver_config : pci_netdriver_config;

  while ( cfg )
  {
    printk ("Probing %s : ", cfg->name);
    /*
     * Unfortunately, the return value is unreliable - some drivers report
     * success even if they fail. Check if they chained an interface (ifnet)
     * structure instead
     */
    if_index_pre = if_index;
    cfg->attach (cfg, attaching);
    if (if_index > if_index_pre)
    {
      /*
       * Assume success.
       */
      printk("attached\n");
      ocfg->name   = cfg->name;
      ocfg->attach = cfg->attach;
      return 0;
    }
    printk ("Probing %s : failed\n", cfg->name);
    cfg = cfg->next;
  }
  return -1;
}

#define CONFIGURE_NETWORK_DRIVER_NAME   "probing"
#define CONFIGURE_NETWORK_DRIVER_ATTACH net_prober
#define CONFIGURE_ETHERNET_ADDRESS      0x00, 0x08, 0xc7, 0x21, 0x01, 0xf9
#elif NEK
int rtems_ne_driver_attach (struct rtems_bsdnet_ifconfig *, int);
#define CONFIGURE_NETWORK_DRIVER_NAME   "ne1"
#define CONFIGURE_NETWORK_DRIVER_ATTACH rtems_ne_driver_attach
#define CONFIGURE_ETHERNET_ADDRESS      0x00, 0x08, 0xc7, 0x21, 0x01, 0xf9
#else
int rtems_fxp_attach(struct rtems_bsdnet_ifconfig *config, int attaching);
#define CONFIGURE_NETWORK_DRIVER_NAME   "fxp1"
#define CONFIGURE_NETWORK_DRIVER_ATTACH rtems_fxp_attach
#define CONFIGURE_ETHERNET_ADDRESS      0x00, 0x08, 0xc7, 0x21, 0x01, 0xf9
#endif
#else
#define CONFIGURE_NETWORK_DRIVER_NAME   "fec0"
#define CONFIGURE_NETWORK_DRIVER_ATTACH rtems_fec_driver_attach
#define CONFIGURE_ETHERNET_ADDRESS      0x00, 0x20, 0xDD, 0xFF, 0x00, 0x01
#endif

#if RTEMS_APP_NETWORKING_DHCP
#define CONFIGURE_NETWORK_DHCP
#endif

#if RTEMS_APP_NETWORKING_STATIC
#define CONFIGURE_NETWORK_IPADDR  "172.16.100.50"
#define CONFIGURE_NETWORK_NETMASK "255.255.255.0"
#define CONFIGURE_NETWORK_GATEWAY "172.16.100.1"
#endif

#define CONFIGURE_NETWORK_MBUFS     (180*1024)
#define CONFIGURE_NETWORK_MCLUSTERS (350*1024)

#include "networkconfig.h"
#endif

#define CONFIGURE_SHELL_COMMANDS_INIT
#define CONFIGURE_SHELL_COMMANDS_ALL
#define CONFIGURE_SHELL_MOUNT_MSDOS
#ifdef RTEMS_NETWORKING
#define CONFIGURE_SHELL_COMMANDS_ALL_NETWORKING
#define CONFIGURE_SHELL_MOUNT_TFTP
#define CONFIGURE_SHELL_MOUNT_FTP
#define CONFIGURE_SHELL_MOUNT_NFS
#endif

#include <rtems/shellconfig.h>
