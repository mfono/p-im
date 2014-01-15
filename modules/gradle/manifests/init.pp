# Gradle telepito osztaly
#
class gradle(
    $installDir  = '/opt/gradle',
    $version     = '1.10',
    $downloadUrl = 'http://services.gradle.org/distributions/gradle-1.10-all.zip',
    $useCache    = false,
)
{
    $installerFilename = inline_template('<%= File.basename(@downloadUrl) %>')
    $appHome          = "${$installDir}/gradle-${version}"

    # Alapertelmezett exec path beallitasa a modul szamara
    Exec {
        path => ['/usr/bin', '/usr/sbin', '/bin']
    }

    # Install konyvtar letrehozasa ha kell
    file { "${installDir}":
        ensure => "directory"
    }

    realize Package[wget]
    realize Package[unzip]

    if ($useCache) {
        file { "${installDir}/${installerFilename}":
            source  => "puppet:///modules/gradle/${installerFilename}",
        }
        exec { 'get_gradle_installer':
            cwd       => $installDir,
            creates   => "${installDir}/gradle_from_cache",
            command   => 'touch gradle_from_cache',
            require   => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_gradle_installer':
            cwd       => $installDir,
            creates   => "${installDir}/${installerFilename}",
            command   => "wget \"${downloadUrl}\" -O ${installerFilename}",
            timeout   => 600,
            require   => Package['wget'],
        }
    }

    # Kitomorites
    exec { 'extract_gradle':
        cwd       => "${installDir}/",
        command   => "unzip ${installerFilename}",
        creates   => $appHome,
        require   => [Package['unzip'], Exec['get_gradle_installer']],
    }
    file { "${installDir}/set_env.sh":
        source => "puppet:///modules/gradle/set_env.sh",
    }
    exec { 'run_gradle_set_env':
        cwd     => "${installDir}/",
        command => "/bin/bash set_env.sh '${appHome}'",
        require => [Exec['extract_gradle'], File["${installDir}/set_env.sh"]],
        # TODO
        #unless  => ,
    }
}
