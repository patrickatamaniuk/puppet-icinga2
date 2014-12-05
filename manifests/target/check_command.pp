#
# subscribe this target to an icinga check_command.
#
# The targets host.conf will set a custom var which will
# apply an autogenerated Service to this host
#
# Usage:
#  icinga2::target::check_command { 'ssh': }
#
#  icinga2::target::check_command { 'http':
#    command   => 'http',
#    parameter => {
#      http_uri => '/icinga-web/',
#    }
#  }
#
define icinga2::target::check_command (
  $command = $name,
  $parameter = {},
) {
  validate_string($command)
  validate_hash($parameter)

  include icinga2::target
  include icinga2::target::host

  $icinga_svc = "${name}"
  exported_vars::set { "icinga_servicevar_${icinga_svc}":
    value => $icinga_svc
  }

  #ensure that an apply Service file is on the icinga server
  # add fqdn to make the resource unique, other hosts may use this service, too.
  @@icinga2::server::stdservices::apply_check_command_service { "${icinga_svc}_${::fqdn}":
    command       => $command,
    vars          => $parameter,
    display_name  => capitalize($name),
    object_servicename => capitalize($name), # use a common object for every target
    assign_where  => "host.vars.${icinga_svc} == true",
    tag           => "icinga2_check_${icinga2::target::magic_tag}",
  }

}
