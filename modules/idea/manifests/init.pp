# intelliJ IDEA telepito osztaly
#
class idea(
    # A telepites helye
    $installDir  = '/opt/idea',
    # A telepitendo verzio szama. A telepites helyen ezzel a verzioszammal letrejon egy konyvtar, ebbe telepitodik az alkalmazas
    $version     = '13.0.1',
    # Az URL, amelyrol letoltheto a telepito csomag
    $downloadUrl = 'http://download.jetbrains.com/idea/ideaIC-13.0.1.tar.gz',
    # A $downloadUrl-en elerheto file-ban talalhato konyvtar neve
    $archiveDir  = 'idea-IC-133.331',
    # TRUE eseten nem tolti le a telepitot, hanem a mar korabban letoltott valtozatot hasznalja
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
        ensure => "directory",
    }

    realize Package[wget]

    if ($useCache) {
        file { "${installDir}/${installerFilename}":
            source => "puppet:///modules/idea/${installerFilename}",
        }
        exec { 'get_idea_installer':
            cwd     => $installDir,
            creates => "${installDir}/idea_from_cache",
            command => 'touch idea_from_cache',
            require => File["${installDir}/${installerFilename}"],
        }
    } else {
        exec { 'get_idea_installer':
            cwd     => $installDir,
            creates => "${installDir}/${installerFilename}",
            command => "wget \"${downloadUrl}\" -O ${installerFilename}",
            require => [Package['wget'], File["${installDir}"]],
        }
        file { "${installDir}/${installerFilename}":
            mode    => '0755',
            require => Exec['get_idea_installer'],
        }
    }

    # Kitomorites
    exec { 'extract_idea':
        cwd     => "${installDir}/",
        command => "tar xvf ${installerFilename} -C ${installDir}",
        require => Exec['get_idea_installer'],
        # Csak akkor kell kitomoriteni, ha meg nem csomgaoltuk ki (creates parameter nem jo, mert amit ez az utasitas letrehoz, azt kesobb ki fogjuk torolni)
        onlyif  => "[ ! -f ${appHome}/bin/idea.sh ] >/dev/null 2>&1"
    }
    ->
    file { "${$appHome}":
        ensure => "directory",
    }
    ->
    exec { 'rename_idea_dir':
        command => "mv ${installDir}/${archiveDir}/* ${appHome}",
        creates => "${appHome}/bin/idea.sh",
    }
    ->
    file { "${appHome}/bin/idea.sh":
        mode => '0755',
    }
    ->
    file { "${installDir}/${archiveDir}":
        ensure => "absent",
        force  => true
    }
}
