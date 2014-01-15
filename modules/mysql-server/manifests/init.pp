# MySQL Server telepito osztaly
#
class mysql-server(
    $installDir  = '/opt/mysql',
    $version     = '5.5',
    $downloadUrl = 'http://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.35-debian6.0-x86_64.deb',
    $useCache    = false,
)
{
    $installerFilename = inline_template('<%= File.basename(@downloadUrl) %>')
    $appHome           = "${$installDir}/server-${version}"

    # Alapertelmezett exec path beallitasa a modul szamara
    Exec {
        path => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin', '/sbin']
    }

    # Install konyvtar letrehozasa ha kell
    file { "${installDir}":
        ensure => "directory"
    }

    # wget csomag behuzasa
    realize Package[wget]

    if ($useCache) {
        file { "${installDir}/${installerFilename}":
            source => "puppet:///modules/mysql-server/${installerFilename}",
        }
        exec { 'get_mysql_installer':
            cwd     => $installDir,
            creates => "${installDir}/mysql_from_cache",
            command => 'touch mysql_from_cache',
            require => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_mysql_installer':
            cwd     => $installDir,
            creates => "${installDir}/${installerFilename}",
            command => "wget \"${downloadUrl}\" -O ${installerFilename}",
            require => [Package['wget'], File["${installDir}"]],
        }
        file { "${installDir}/${installerFilename}":
            mode    => '0755',
            require => Exec['get_mysql_installer'],
        }
    }

    # a szerver file-jait mysql user ala telepitjuk
    user { 'mysql':
        ensure  => present,
    }

    # a MySQL Server 5.5.10 verzio ota igenyli a libaio csomagot
    package { 'libaio1':
        ensure => installed,
    }

    # telepito script futtatasa
    file { "${installDir}/install.sh":
        source => "puppet:///modules/mysql-server/install.sh",
    }
    exec { 'run_mysql_installer':
        cwd     => "${installDir}/",
        command => "/bin/bash install.sh \"${installerFilename}\" \"${appHome}\"",
        creates => ["${appHome}", '/usr/bin/mysql', '/usr/bin/mysqld_safe'],
        require => [
            File["${installDir}/install.sh"],
            Exec['get_mysql_installer'],
            Package['libaio1'],
            User['mysql'],
        ],
    }
}
