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

  #ensure that an apply Service file is on the icinga server
  # add fqdn to make the resource unique, other hosts may use this service, too.
  @@icinga2::server::stdservices::apply_port_service { "${protocol}_${port}_${::fqdn}":
    object_servicename => "${protocol}_${port}", # use a common object for every target
    assign_where  => "host.vars.${icinga_svc} == true",
    tag           => "icinga2_check_${icinga2::target::magic_tag}",
  }

}
