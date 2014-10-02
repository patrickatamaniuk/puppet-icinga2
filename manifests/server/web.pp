# == Class: icinga2::server::web
#
# This class installs icinga-web for the Icinga 2 monitoring system.
#
# === Parameters
#
# Coming soon...
#
# === Examples
#
# Coming soon...
#
class icinga2::server::web inherits icinga2::server {

  include icinga2::server

  class {'icinga2::server::web::repos': }  ~>
  class {'icinga2::server::web::db': }     ~>
  package { 'icinga-web':
    ensure  => installed,
  }
  ->
  class {'icinga2::server::web::config': }


  $php_database_package = $server_db_type ? {
    'mysql' => 'php5-mysql',
    default => 'php5-pgsql',
  }
  package { ['php5', 'php5-cli', 'php-pear', 'php5-xmlrpc', 'php5-xsl', 'php5-gd', 'php5-ldap', $php_database_package]:
    ensure => installed
  }

}


class icinga2::server::web::repos inherits icinga2::server {

  include icinga2::server

  if $manage_repos == true {
    case $::operatingsystem {
      #Ubuntu systems:
      'Ubuntu': {
        apt::source { "icinga-web":
          location          => 'http://ppa.launchpad.net/formorer/icinga-web/ubuntu',
          release           => $lsbdistcodename,
          repos             => 'main',
          key               => '36862847',
          include_src       => false,
        }
      }
      #Fail if we're on any other OS:
      default: { fail("${::operatingsystem} is not supported!") }
    }
  }

}
class icinga2::server::web::db inherits icinga2::server {

  include icinga2::server

  case $server_db_type {
    'pgsql': {
        $web_pwhash0 = md5("${web_db_password}${web_db_user}")
        postgresql::role{ $web_db_user:
          rolename => $web_db_user,
          password => "md5${web_pwhash0}",
        }
        postgresql::hba{ 'icinga_web_psql_hba_unix':
          type     => 'local',
          database => $web_db_name,
          user     => $web_db_user,
          method   => 'md5'
        }
        postgresql::hba{ 'icinga_web_psql_hba_ip4':
          type     => 'host',
          database => $web_db_name,
          user     => $web_db_user,
          address  => '127.0.0.1/32',
          method   => 'md5'
        }
        postgresql::hba{ 'icinga_web_psql_hba_ip6':
          type     => 'host',
          database => $web_db_name,
          user     => $web_db_user,
          address  => '::1/128',
          method   => 'md5'
        }

        postgresql::db{ $web_db_name:
          db_name => $web_db_name,
          owner   => $web_db_user,
        }
    } #pgsql

    default: { fail("${server_db_type} is not supported!") }

  } #case

}

class icinga2::server::web::config inherits icinga2::server {

  include icinga2::server

  icinga2::server::features::enable { 'command': }
  icinga2::server::features::enable { 'livestatus': }
  icinga2::server::features::enable { 'icingastatus': }
  icinga2::server::features::enable { 'perfdata': }
  #icinga2::server::features::enable { 'graphite': }

  $protocol = $server_db_type ? {
    'mysql' => 'mysql',
    default => 'pgsql',
  }
  file{'/etc/icinga-web/conf.d/database-web.xml':
    content => template('icinga2/web/database-web.xml.erb'),
    notify  => Exec['icinga-web-clearcaches'],
  }
  file{'/etc/icinga-web/conf.d/database-ido.xml':
    content => template('icinga2/web/database-ido.xml.erb'),
    notify  => Exec['icinga-web-clearcaches'],
  }
  file{'/etc/icinga-web/conf.d/access.xml':
    content => template('icinga2/web/access.xml.erb'),
    notify  => Exec['icinga-web-clearcaches'],
  }

  exec{ 'icinga-web-clearcaches':
    refreshonly => true,
    command     => '/usr/lib/icinga-web/bin/clearcache.sh'
  }
}
