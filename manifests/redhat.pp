/*

== Class: tomcat::redhat

Installs tomcat on Redhat using your systems package manager.

Requires:
- java to be previously installed

Tested on:
- Redhat 5.6 (Tikanga)
- Redhat 6.0 (Santiago)

Usage:
  include tomcat::redhat

*/
class tomcat::redhat inherits tomcat::package {

  # avoid partial configuration on untested-redhat-release
  if versioncmp($operatingsystemversion, 5.0) < 0 or versioncmp($operatingsystemversion, 7.0) >= 0 {
    fail "class ${name} not tested on ${operatingsystem}/${operatingsystemversion}"
  }

  package { [
    "log4j", 
    "jakarta-commons-logging"
    ]: ensure => present 
  }

  if versioncmp($operatingsystemversion, 6.0) >= 0 {
    $tomcat = "tomcat6"

    # replaced the /usr/sbin/tomcat6 included script with setclasspath.sh and catalina.sh
    file {"/usr/share/${tomcat}/bin/setclasspath.sh":
      ensure => present,
      owner  => root,
      group  => root,
      mode   => 755,
      source => "puppet:///modules/tomcat/setclasspath.sh-6.0.24" ,
      require => [ Package["tomcat"], File["/usr/share/${tomcat}"] ],
    }

    file {"/usr/share/${tomcat}/bin/catalina.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 755,
      source  => "puppet:///modules/tomcat/catalina.sh-6.0.24",
      require => File["/usr/share/${tomcat}/bin/setclasspath.sh"],
    }

    Package["tomcat"] { name => $tomcat }


  }
  else {
    $tomcat = "tomcat5"
    $tomcat_home = "/var/lib/tomcat5"

    # link logging libraries from java
    include tomcat::logging

    file {"/usr/share/tomcat5/bin/catalina.sh":
      ensure  => link,
      target  => "/usr/bin/dtomcat5",
      require => Package["tomcat"],
    }

    Package["tomcat"] { 
      name   => $tomcat,
      before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],  
    }
  }

  User["tomcat"] { 
    require => Package[$tomcat],
  }

  File["/usr/share/tomcat"] {
    path => "/usr/share/${tomcat}",
  }

  Service["tomcat"] {
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => "-Dcatalina.base=/usr/share/${tomcat}",
  } 

  File["/etc/init.d/tomcat"] {
    path => "/etc/init.d/${tomcat}",
  }

}
