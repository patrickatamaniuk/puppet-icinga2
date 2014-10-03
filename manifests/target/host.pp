#
# will export object host resource to icinga server
#
# usage: include icinga2::target::host
#
class icinga2::target::host(
  $enable_nrpe_generic_checks = true,
) {
  include "icinga2::target"

  notice("Exporting icinga2::object::host ${fqdn}")
  @@icinga2::object::host { $::fqdn:
    display_name     => $::fqdn,
    target_dir       => "${icinga2::target::customconfigdir}/hosts",
    target_file_name => "${::fqdn}.conf",
    ipv4_address     => $::fqdn,
    vars             => {
      os => $operatingsystem,
      osmajrelease => $operatingsystemmajrelease,
      osfamily => $osfamily,
      virtual  => $virtual,
    }
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
