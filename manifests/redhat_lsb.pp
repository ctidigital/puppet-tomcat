/*

== Class: tomcat::redhat-lsb

Installs redhat-lsb when using tomcat source installation. 

Requires:
- tomcat::source

Tested on:
- RHEL 5,6

Usage:
  require Class['tomcat::redhat-lsb']

*/
class tomcat::redhat_lsb {
  
  case $::operatingsystem {
    RedHat,CentOS: {
      package {'redhat-lsb':
        ensure => installed,
      }
    }
  }

}
