# Use this to define icinga monitored processes
#
# This is an exported resource.
# It should be included on the nodes to be monitored but
# has effects on the icinga server
#
# Usage:
# icinga2::target::process { 'httpd': }
#
define icinga2::target::process(
  $process = $name,
  $ensure = true,
) {
  include icinga2::target

  $safe_name = regsubst($process, '[^a-zA-Z0-9_-]', '_', 'G')
  $assign_var = "check_nrpe_process_${safe_name}"

  #make the host object subscribe to that
  exported_vars::set { "icinga_servicevar_${assign_var}":
    value => $assign_var,
  }

  #ensure that an apply Service file is on the icinga server
  # add fqdn to make the resource unique, other hosts may use this service, too.
  @@icinga2::server::stdservices::apply_nrpe_service { "${assign_var}_${::fqdn}":
    object_servicename => "${process}", # use a common object for every target
    nrpe_command  => "check_process_${process}",
    display_name  => "Process check ${process}",
    assign_where  => "host.vars.${assign_var} == true",
    tag           => "icinga2_check_${icinga2::target::magic_tag}",
  }

}
