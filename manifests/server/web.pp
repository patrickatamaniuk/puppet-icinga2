# = Class: icinga2::web
#
# This class provides the Icinga-web functionality
#
# Rather than invoking this class directly, it should be invoked
# via the main Icinga class. Generally, you should enable idoutils
# for icinga-web to function.
#
# = Examples:
#
#  class { '::icinga2':
#    puppi                     => true,
#    enable_idoutils           => true,
#    enable_icingaweb          => true,
#    enable_debian_repo_legacy => false,
#    manage_repos              => true,
#  }
#
#
class icinga2::server::web inherits icinga2::server {

  include icinga2::server

  package { 'icinga-web':
    ensure  => installed,
  }

}
