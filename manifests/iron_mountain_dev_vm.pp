# Az Iron Mountain projekthez szukseges alkalmazasokat biztosito puppet

# Tesztelesi celokra: egyes moduloknal lehetoseg van ra, hogy ne toltessuk le minden futaskor a telepitot, hanem egy helyileg tarolt valtozatot hasznaljunk
$useCache = false

# Alapertelmezett exec path beallitasa a modul szamara
Exec {
    path => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin']
}

# wget package hozzadasa virtualiskent, mert tobb osztaly is hivatkozik ra
@package { 'wget':
    ensure => installed
}

# frissitesek
exec { 'apt_get_update':
    command => "apt-get update",
}
Exec['apt_get_update'] -> Package <| |>

# MySQL 5.5
package { "mysql-server":
    ensure => installed,
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
->
exec { 'set_gradle_environment_var':
    command => "grep -Ev '^GRADLE_HOME\\w*=' /etc/environment > /tmp/new_environment && echo 'GRADLE_HOME=/usr/lib/gradle/1.10' >> /tmp/new_environment && mv /tmp/new_environment /etc/environment",
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

# Kornyezeti valtozok beallitasa
# TODO

# frissitesek
# TODO
