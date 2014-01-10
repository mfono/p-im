# Installs the Oracle Java JDK
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball from oracle instead of fetching it each time.
#
class jdk_oracle(
    $installDir  = '/opt/java',
    $version     = '1.7.0_45',
    $downloadUrl = 'http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz',
    $useCache    = false,
)
{
    $installerFilename = "jdk-${version}-linux-x64.tar.gz"
    $javaHome          = "${$installDir}/jdk${version}"

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
            source  => "puppet:///modules/jdk_oracle/${installerFilename}",
        }
        exec { 'get_jdk_installer':
            cwd       => $installDir,
            creates   => "${installDir}/jdk_from_cache",
            command   => 'touch jdk_from_cache',
            require   => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_jdk_installer':
            cwd       => $installDir,
            creates   => "${installDir}/${installerFilename}",
            command   => "wget -c --no-cookies --no-check-certificate --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"${downloadUrl}\" -O ${installerFilename}",
            timeout   => 600,
            require   => Package['wget'],
        }
        file { "${installDir}/${installerFilename}":
            mode    => '0755',
            require => Exec['get_jdk_installer'],
        }
    }

    # Kitomorites
    exec { 'extract_jdk':
        cwd       => "${installDir}/",
        command   => "tar xvf ${installerFilename}",
        creates   => $javaHome,
        require   => Exec['get_jdk_installer'],
    }

    # Eleresek beallitasa
    ## java
    exec { 'update_alternative_java':
        creates   => "/usr/bin/java",
        command   => "update-alternatives --install \"/usr/bin/java\" \"java\" \"${javaHome}/bin/java\" 1",
        require   => Exec['extract_jdk'],
    }
    ->
    file { '/usr/bin/java':
        mode => 755
    }
    ->
    exec { 'update_alternative_config_java':
        command   => "update-alternatives --config java",
    }

    ## javac
    exec { 'update_alternative_javac':
        creates => "/usr/bin/javac",
        command => "update-alternatives --install \"/usr/bin/javac\" \"javac\" \"${javaHome}/bin/javac\" 1",
        require => Exec['extract_jdk'],
    }
    ->
    file { '/usr/bin/javac':
        mode => 755
    }
    ->
    exec { 'update_alternative_config_javac':
        command   => "update-alternatives --config javac",
    }

    #exec { 'set_environment_vars':
    #    command => "export JAVA_HOME = \"${javaHome}\"",
    #    require => File["${javaHome}"],
    #}
}
