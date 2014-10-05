# Use this to define icinga monitored processes
# This is an exported resource.
# It should be included on the nodes to be monitored but
# has effects on the icinga server
#
define icinga2::target::process(
  $ensure = true,
  $process,
) {
  $safe_name = regsubst($process, '[^a-zA-Z0-9_-]', '_', 'G')

  #make the host subscribe to that
  exported_vars::set { "icinga_servicevar_check_nrpe_process_${safe_name}":
    value => "check_nrpe_process_${safe_name}"
  }

  #ensure that an apply Service file is on the icinga server
  @@icinga2::server::stdservices::apply_process_service { "check_nrpe_process_${safe_name}_${::fqdn}":
    process       => $process,
    assign_where  => "host.vars.check_nrpe_process_${safe_name} == true",
    tag           => "icinga2_check_${icinga2::target::magic_tag}",
  }

}
