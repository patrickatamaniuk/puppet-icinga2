#
# define standard apply rules for services
#
# a host can subscribe by setting a custom var corresponding to the service
#
#
class icinga2::server::stdservices(
  $template_to_apply = 'generic-service',
  $target_dir = "/etc/icinga2/objects/applys",

  $nrpe_checks = [ 'disk', 'load', 'swap', 'zombie_procs', 'users', 'ntp' ],
  $port_checks = [ 'tcp_22', 'tcp_80', 'tcp_443', 'udp_53', 'tcp_53' ],
) {

    define apply_nrpe_service(
      $check_command     = 'nrpe',
      $nrpe_command      = "check_${name}",
      $template_to_apply = 'generic-service',
      $target_dir        = "/etc/icinga2/objects/applys",
      $assign_where      = "host.vars.check_nrpe_stdservices == true",
    ) {
      $cap_name = capitalize($name)
      icinga2::object::apply_service_to_host { $name:
        name               => $cap_name,
        display_name       => "Remote nrpe check for ${cap_name}",
        check_command      => $check_command,
        template_to_import => $template_to_apply,
        target_dir => $target_dir,
        assign_where => $assign_where,
        vars => {
          nrpe_command => $nrpe_command,
        },
      }
    }

    define apply_port_service(
      $template_to_apply = 'generic-service',
      $target_dir        = "/etc/icinga2/objects/applys",
    ) {
      $args = split($name, '_')
      $proto = $args[0]
      $port = $args[1]
      $check_command = $proto
      $cap_name = capitalize($name)
      case $proto {
        'udp': {
          $vars = { udp_port => $port }
        }
        default: {
          $vars = { tcp_port => $port }
        }
      }
      $assign_where = "host.vars.check_${proto}_${port} == true"
      icinga2::object::apply_service_to_host { $name:
        name               => $cap_name,
        display_name       => "Tcp check ${cap_name}",
        check_command      => $check_command,
        template_to_import => $template_to_apply,
        target_dir => $target_dir,
        assign_where => $assign_where,
        vars => $vars,
      }
    }

    apply_port_service { $port_checks:
      template_to_apply => $template_to_apply,
      target_dir        => $target_dir,
    }

    apply_nrpe_service { $nrpe_checks:
      template_to_apply => $template_to_apply,
      target_dir        => $target_dir,
    }

}
