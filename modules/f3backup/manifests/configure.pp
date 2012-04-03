class f3backup::configure (
    $backup_rdiff = true,
    $backup_mysql = false,
    $backup_command = false,
    $priority = '10',
    $rdiff_exclude = false,
    $rdiff_keep = '4W',
    $rdiff_global_exclude_file = false,
    $rdiff_user = false,
    $rdiff_path = false,
    $rdiff_extra_parameters = '',
    $mysql_backupdir = '/root/backup/MySQL',
    $mysql_daystokeep = 3,
    $mysql_monthstokeep = 2,
    $mysql_compress = 'gzip',
    $mysql_encrypt = 'none',
    $mysql_lock_tables = true,
    $mysql_extraparameters = '',
    $mysql_sshuser = 'root',
    $mysql_key = '/backup/.ssh/id_rsa-mysql-backup',
    $command_to_execute = '/bin/true',
    # New
    $backup_server = 'default',
    $myname = $::fqdn
) {

    @@file { "/backup/f3backup/${myname}/config.ini":
        content => template('f3backup/f3backup-host.ini.erb'),
        owner   => 'backup',
        group   => 'backup',
        tag     => "f3backup-${backup_server}",
    }

    if $rdiff_exclude {
        @@file { "/backup/f3backup/${myname}/exclude.txt":
            content => template("f3backup/exclude.txt.erb"),
            owner   => 'backup',
            group   => 'backup',
            tag     => "f3backup-${backup_server}",
        }
    } else {
        @@file { "/backup/f3backup/${myname}/exclude.txt":
            tag    => "f3backup-${backup_server}",
            ensure => absent,
        }
    }

    # TODO : Fix all this...
    if $backup_mysql {
        file { "/usr/local/sbin/mysql-backup.sh":
            content => template("f3backup/mysql-backup.sh.erb"),
            mode    => 0700,
        }
        file { $mysql_backupdir:
            ensure => directory,
            mode   => 0700,
        }
        # Ugly hack to also create the parent dir for the default
        if $mysql_backupdir == '/root/backup/MySQL' {
            file { '/root/backup':
                mode   => 0700,
                ensure => directory,
            }
        }
        if $mysql_encrypt != 'none' {
            include backup::gpg_backup_key
        }
    }

}

