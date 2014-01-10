# Installs MySQL Workbench
#
class mysql_workbench(
    $installDir  = '/opt/mysql-workbench',
    $version     = '6.0.8',
    $downloadUrl = 'http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-6.0.8-1ubu1204-amd64.deb',
    $useCache    = false,
)
{
    $installerFilename = inline_template('<%= File.basename(@downloadUrl) %>')
    $appHome           = "${$installDir}/${version}"

    # Alapertelmezett exec path beallitasa a modul szamara
    Exec {
        path => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin', '/sbin']
    }

    # Install konyvtar letrehozasa ha kell
    file { "${installDir}":
        ensure => "directory"
    }

    realize Package[wget]

    if ($useCache) {
        file { "${installDir}/${installerFilename}":
            source => "puppet:///modules/mysql_workbench/${installerFilename}",
        }
        exec { 'get_mysqlwb_installer':
            cwd     => $installDir,
            creates => "${installDir}/mysqlwb_from_cache",
            command => 'touch mysqlwb_from_cache',
            require => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_mysqlwb_installer':
            cwd     => $installDir,
            creates => "${installDir}/${installerFilename}",
            command => "wget \"${downloadUrl}\" -O ${installerFilename}",
            timeout => 600,
            require => [Package['wget'], File["${installDir}"]],
        }
        file { "${installDir}/${installerFilename}":
            mode    => '0755',
            require => Exec['get_mysqlwb_installer'],
        }
    }

    # TODO: Atrakni shell scriptbe, mert a dpkg hibat fog dobni a hianyzo lib-ek miatt, es ezert nem is fog lefutni a get_mysqlwb_missing_packages
    # Kitomorites
    exec { 'extract_mysqlwb':
        cwd     => "${installDir}/",
        command => "dpkg -i ${installerFilename}",
        creates => ['/usr/bin/mysql-workbench', '/usr/bin/mysql-workbench-bin'],
        require => Exec['get_mysqlwb_installer'],
    }
    ->
    exec { 'get_mysqlwb_missing_packages':
        command => "apt-get -f install",
    }
}
