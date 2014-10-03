# Define icinga2::target::baseservices
#
# Use this to define Nagios basic service objects that will be
# used for to all nodes
# All local disks, memory, cpu, local users...
# It's automatically loaded in icinga::target::host
#
# This is an exported resource.
#
define icinga2::target::baseservices (
  $host_name           = $fqdn,
  $service_description = '',
  $use                 = 'generic-service',
  $template            = 'icinga2/target/baseservices.erb',
  $ensure              = 'present'
  ) {

  include icinga2::target
  include icinga2::params

  @@file { "${icinga2::target::customconfigdir}/services/${host_name}-00-baseservices.conf":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Service[$icinga2::params::icinga2_server_service_name],
    content => template( $template ),
    tag     => "icinga2_check_${icinga2::target::magic_tag}",
  }

}
