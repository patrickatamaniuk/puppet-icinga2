#
# Class: icinga2::target
#
# Basic host target class
# Include it on nodes to be monitored by icinga2
#
# Usage:
# include icinga2::target
#
class icinga2::target(
  $customconfigdir = '/etc/icinga2/objects', #dir on icinga _server_
) {

  $magic_tag = '' #get_magicvar($::icinga_grouplogic)
  $magic_hostgroup = '' #get_magicvar($::icinga_hostgrouplogic)

  include icinga2::target::host
}
