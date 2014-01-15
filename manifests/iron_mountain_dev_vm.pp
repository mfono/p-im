# Az Iron Mountain projekthez szukseges alkalmazasokat biztosito puppet

# Tesztelesi celokra: egyes moduloknal lehetoseg van ra, hogy ne toltessuk le minden futaskor a telepitot, hanem egy helyileg tarolt valtozatot hasznaljunk
$useCache = false

# Alapertelmezett exec path beallitasa a modul szamara
Exec {
    path => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin']
}

# package-ek hozzadasa virtualiskent, amelyekre tobb osztaly is hivatkozhat
@package { 'wget':
    ensure => installed
}
@package { 'unzip':
    ensure => installed
}

# frissitesek
exec { 'apt_get_update':
    command => "apt-get update",
}
Exec['apt_get_update'] -> Package <| |>

# MySQL 5.5
class { 'mysql-server':
    useCache => $useCache,
}

# Java 1.7.0_45
class { 'jdk_oracle':
    useCache => $useCache,
}

# GUI
package { "ubuntu-desktop":
    ensure => installed,
}

# IDEA 13
class { "idea":
    require  => Package['ubuntu-desktop'],
    useCache => $useCache,
}

# Grails 2.3.4
class { 'grails':
    useCache => $useCache,
    require  => Class['jdk_oracle'],
}

# Gradle 1.10
class { 'gradle':
    useCache => $useCache,
    require  => Class['jdk_oracle'],
}

# Git 1.8.5.2
class { 'git':
    useCache => $useCache
}

# MySQL Workbench 6.0
class { "mysql_workbench":
    require  => [Package['ubuntu-desktop'], Package['mysql-server']],
    useCache => $useCache,
}

# Midnight Commander
package { "mc":
    ensure => installed
}

# frissitesek
# TODO
