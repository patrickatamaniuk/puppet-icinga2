# Use this to define icinga monitored processes
# This is an exported resource.
# It should be included on the nodes to be monitored but
# has effects on the icinga server
#
define icinga2::target::process(
  $ensure = true,
  $process,
) {

}
