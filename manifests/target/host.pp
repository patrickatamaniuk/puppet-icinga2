#
# will export object host resource to icinga server
#
# usage: include icinga2::target::host
#
class icinga2::target::host(
  #
  # enable a set of default checks for this target
  #
  $enable_nrpe_generic_checks = true,

  #
  # ipv4_address to monitor, defaults to $::ipaddress
  #  possible values: 'eth0' 'eth1' any ip '1.2.3.4' or a fqdn
  #
  $address = undef,

  #
  # define vars in host.conf for this target to specify manual configurations
  #
  $extra_vars = {'sla'=>'8x5'},

) {
  include "icinga2::target"

  validate_hash($extra_vars)

  $ipv4_address = $address ? {
    undef   => $::ipaddress,
    'eth0'  => $::ipaddress_eth0,
    'eth1'  => $::ipaddress_eth1,
    default => $address
  }

  notice("Exporting icinga2::object::host ${fqdn}")
  @@icinga2::object::host { $::fqdn:
    display_name     => $::fqdn,
    target_dir       => "${icinga2::target::customconfigdir}/hosts",
    target_file_name => "${::fqdn}.conf",
    ipv4_address     => $ipv4_address,
    vars             => merge($extra_vars, {
      os => $operatingsystem,
      kernel => $kernel,
      osmajrelease => $operatingsystemmajrelease,
      osfamily => $osfamily,
      virtual  => $virtual,
    })
  }

  if ($enable_nrpe_generic_checks) {
    # icinga2 best practices: service apply
    exported_vars::set { "icinga_servicevar_check_nrpe_stdservices":
      value => 'check_nrpe_stdservices'
    }
    # or static service objects for every host.
#    icinga2::target::baseservices { $::fqdn:
#      use      => 'generic-service',
#    }
  }
}
