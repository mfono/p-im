# Installs GIT from source
#
# The puppet cache flag is for faster local vagrant development, to
# locally host the tarball instead of fetching it each time.
#
class git(
    $installDir  = '/opt/git',
    $version     = '1.8.5.2',
    $downloadUrl = 'https://git-core.googlecode.com/files/git-1.8.5.2.tar.gz',
    $useCache    = false,
)
{
    $installerFilename = inline_template('<%= File.basename(@downloadUrl) %>')
    $appHome          = "${$installDir}/git-${version}"

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
            source  => "puppet:///modules/git/${installerFilename}",
        }
        exec { 'get_git_installer':
            cwd       => $installDir,
            creates   => "${installDir}/git_from_cache",
            command   => 'touch git_from_cache',
            require   => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_git_installer':
            cwd       => $installDir,
            creates   => "${installDir}/${installerFilename}",
            command   => "wget \"${downloadUrl}\" -O ${installerFilename}",
            timeout   => 600,
            require   => Package['wget'],
        }
        file { "${installDir}/${installerFilename}":
            mode    => '0755',
            require => Exec['get_git_installer'],
        }
    }

    # Kitomorites
    exec { 'extract_git':
        cwd       => "${installDir}/",
        command   => "tar -zxf ${installerFilename}",
        creates   => $appHome,
        require   => Exec['get_git_installer'],
    }

    # Fuggosegek telepitese
    package { 'libcurl4-gnutls-dev':
        ensure => installed,
    }
    package { 'libexpat1-dev':
        ensure => installed,
    }
    package { 'gettext':
        ensure => installed,
    }
    package { 'libz-dev':
        ensure => installed,
    }
    package { 'libssl-dev':
        ensure => installed,
    }
    package { 'build-essential':
        ensure => installed,
    }

    exec { 'git_make':
        cwd     => $appHome,
        command => 'make prefix=/usr/local install',
        require => [
            Package['libcurl4-gnutls-dev'],
            Package['libexpat1-dev'],
            Package['gettext'],
            Package['libz-dev'],
            Package['libssl-dev'],
            Package['build-essential'],
        ],
        creates => '/usr/local/bin/git'
    }
}
