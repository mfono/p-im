# Installs Grails
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball instead of fetching it each time.
#
class grails(
    $installDir  = '/opt/grails',
    $version     = '2.3.4',
    $downloadUrl = 'http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.3.4.zip',
    $useCache    = false,
)
{
    $installerFilename = inline_template('<%= File.basename(@downloadUrl) %>')
    $appHome          = "${$installDir}/grails-${version}"

    # Alapertelmezett exec path beallitasa a modul szamara
    Exec {
        path => ['/usr/bin', '/usr/sbin', '/bin']
    }

    # Install konyvtar letrehozasa ha kell
    file { "${installDir}":
        ensure => "directory"
    }

    realize Package[wget]

    if ($useCache) {
        file { "${installDir}/${installerFilename}":
            source  => "puppet:///modules/grails/${installerFilename}",
        }
        exec { 'get_grails_installer':
            cwd       => $installDir,
            creates   => "${installDir}/grails_from_cache",
            command   => 'touch grails_from_cache',
            require   => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_grails_installer':
            cwd       => $installDir,
            creates   => "${installDir}/${installerFilename}",
            command   => "wget \"${downloadUrl}\" -O ${installerFilename}",
            timeout   => 600,
            require   => Package['wget'],
        }
#        file { "${installDir}/${installerFilename}":
#            mode    => '0755',
#            require => Exec['get_grails_installer'],
#        }
    }

    package { 'unzip':
        ensure => installed,
    }

    # Kitomorites
    exec { 'extract_grails':
        cwd       => "${installDir}/",
        command   => "unzip ${installerFilename}",
        creates   => $appHome,
        require   => [Package['unzip'], Exec['get_grails_installer']],
    }
    file { "${installDir}/set_env.sh":
        source => "puppet:///modules/grails/set_env.sh",
    }
    exec { 'run_grails_set_env':
        cwd     => "${installDir}/",
        command => "/bin/bash set_env.sh '${appHome}'",
        require => [Exec['extract_grails'], File["${installDir}/set_env.sh"]],
        #unless  => ,
    }
}
