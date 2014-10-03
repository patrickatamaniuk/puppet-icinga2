# Use this to define icinga monitored ports
# This is an exported resource.
# It should be included on the nodes to be monitored but
# has effects on the icinga server
#
define icinga2::target::port(
  $protocol = 'tcp',
  $port,
  $ensure,
) {
  include icinga2::target::host

  $icinga_svc = "check_${protocol}_${port}"
  exported_vars::set { "icinga_servicevar_${icinga_svc}":
    value => $icinga_svc
  }

}
