# Az Iron Mountain projekthez szukseges alkalmazasokat biztosito puppet

# Alapertelmezett exec path beallitasa a modul szamara
Exec {
    path => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin']
}

# wget package hozzadasa virtualiskent, mert tobb osztaly is hivatkozik ra
@package { 'wget':
    ensure => installed
}

# frissitesek
exec { "apt_get_update":
    command => "apt-get update",
}
Exec['apt_get_update'] -> Package <| |>

# Java 1.7.0_45
class { "jdk_oracle":
    require => Exec['apt_get_update'],
}

# GUI
package { "ubuntu-desktop":
    ensure => installed,
}

# IDEA 13
class { "idea":
    require => Package['ubuntu-desktop'],
}

# Grails 2.3.4
$grailsPpa = 'groovy-dev/grails'
exec { "add_grails_repo":
    command => "add-apt-repository -y ppa:${grailsPpa} && apt-get update",
    require => Package['ubuntu-desktop'],
    onlyif  => "grep -h \"^deb.*${grailsPpa}\" /etc/apt/sources.list.d/* > /dev/null 2>&1; [ $? -ne 0 ] >/dev/null 2>&1",
}
package { "grails-ppa":
    ensure => installed,
}

# Git 1.8.5.2
package { "git":
    ensure => installed,
}

# MySQL 5.5
package { "mysql-server":
    ensure => installed,
}

# MySQL Workbench 6.0
class { "mysql_workbench":
    require => [Package['ubuntu-desktop'], Package['mysql-server']],
}

# Gradle 1.10
$gradlePpa = 'cwchien/gradle'
exec { "add_gradle_repo":
    command => "add-apt-repository -y ppa:${gradlePpa} && apt-get update",
    require => Package['ubuntu-desktop'],
    onlyif  => "grep -h \"^deb.*${gradlePpa}\" /etc/apt/sources.list.d/* > /dev/null 2>&1; [ $? -ne 0 ] >/dev/null 2>&1"
}
->
package { "gradle":
    ensure => installed,
}

# Midnight Commander
package { "mc":
    ensure => installed
}

# Kornyezeti valtozok beallitasa
# TODO

# frissitesek
# TODO
