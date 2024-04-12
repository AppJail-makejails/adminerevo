# AdminerEvo

**AdminerEvo** is a web-based database management interface, with a focus on security, user experience, performance, functionality and size.

It is available for download as a single self-contained PHP file, making it easy to deploy anywhere. 

<img src="https://docs.adminerevo.org/assets/logo.svg" width="80%" height="auto">

docs.adminerevo.org

## How to use this Makejail

### Standalone

```sh
appjail makejail \
    -j adminerevo \
    -f gh+AppJail-makejails/adminerevo \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose=80
```

### Deploy using appjail-director

```sh
appjail-director up
```

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  adminerevo:
    makejail: gh+AppJail-makejails/adminerevo
    name: adminerevo
    options:
      - expose: '8080:80'

  db:
    makejail: gh+AppJail-makejails/mariadb
    name: mariadb
    arguments:
      - mariadb_user: adminerevo
      - mariadb_password: 123
      - mariadb_database: adminerevo
      - mariadb_root_password: 321
```

Remember that the root user cannot be used remotely by default in the MariaDB makejail. See [MariaDB arguments](https://github.com/AppJail-makejails/mariadb#arguments-1) for details.

### Loading plugins

This image bundles all official AdminerEvo plugins. You can find the list of plugins on GitHub: https://github.com/adminerevo/adminerevo/tree/main/plugins.

To load plugins you can pass a list of filenames in `adminerevo_plugins`:

```sh
appjail makejail \
    -j adminerevo \
    -f gh+AppJail-makejails/adminerevo \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="$PWD/plugins.php usr/local/www/apache24/data/plugins.php nullfs ro" -- \
        --adminerevo_plugins "login-password-less"
```

As you can see above, `plugins.php` is mounted inside the jail, so you can easily edit it from the host without logging in. Our `plugins.php` should look like this:

**plugins.php**:

```php
<?php

// See https://www.adminer.org/en/plugins/

$plugins = array(
    new AdminerLoginPasswordLess(password_hash("YOUR_PASSWORD_HERE", PASSWORD_DEFAULT)),
);
```

There are some custom stages that we can use to easily maintain our plugins.

**List plugins**:

```
# appjail run -s list_plugins adminerevo
[00:00:01] [ debug ] [adminerevo] Running initscript `/usr/local/appjail/jails/adminerevo/init` ...
frames
login-otp
dump-json
dump-bz2
enum-types
dump-xml
...
```

**List installed plugins**:

```
# appjail run -s list_installed_plugins adminerevo
[00:00:01] [ debug ] [adminerevo] Running initscript `/usr/local/appjail/jails/adminerevo/init` ...
login-password-less
[00:00:02] [ debug ] [adminerevo] custom:list_installed_plugins() exits with status code 0
[00:00:02] [ debug ] [adminerevo] `/usr/local/appjail/jails/adminerevo/init` exits with status code 0
```

**Note**: Although the `plugin.php` plugin is actually installed, it is not listed here and cannot be removed using the following custom stage.

**Remove a plugin**:

```
# appjail run -s remove_plugin -p plugin=login-password-less adminerevo
[00:00:01] [ debug ] [adminerevo] Running initscript `/usr/local/appjail/jails/adminerevo/init` ...
[00:00:01] [ debug ] [adminerevo] custom:remove_plugin() exits with status code 0
[00:00:01] [ debug ] [adminerevo] `/usr/local/appjail/jails/adminerevo/init` exits with status code 0
# appjail run -s remove_plugin -p plugin=login-password-less adminerevo
[00:00:01] [ debug ] [adminerevo] Running initscript `/usr/local/appjail/jails/adminerevo/init` ...
###> 'login-password-less' This plugin is not installed. <###
[00:00:01] [ debug ] [adminerevo] custom:remove_plugin() exits with status code 1
[00:00:01] [ debug ] [adminerevo] `/usr/local/appjail/jails/adminerevo/init` exits with status code 1
```

As you can see above, the command should complain only when the plugin is not installed.

**Add a plugin**:

```
appjail run -s add_plugin -p plugin=login-password-less adminerevo
```

### Choosing a design

The image bundles all the designs that are available in the source package of AdminerEvo. You can find the list of designs on GitHub: https://github.com/adminerevo/adminerevo/tree/main/designs.

To use a bundled design you can pass its name in `adminerevo_design`:

```sh
appjail makejail \
    -j adminerevo \
    -f gh+AppJail-makejails/adminerevo \
    -o virtualnet=":<random> default" \
    -o nat -- \
        --adminerevo_design "pepa-linha"
```

There are some custom stages that we can use to easily maintain our design.

**List designs**:

```
# appjail run -s list_designs adminerevo
[00:00:02] [ debug ] [adminerevo] Running initscript `/usr/local/appjail/jails/adminerevo/init` ...
brade
pilot
mancave
pepa-linha-dark
pokorny
jukin
...
```

**Change the current design**:

```sh
appjail run -s change_design -p design=nicu adminerevo
```

**Remove the current design**:

```sh
appjail run -s remove_design adminerevo
```

### Tree layout

This Makejail uses the PHP file from [adminer.org/plugins/#use](https://www.adminer.org/plugins/#use), but in chunks for ease of use.

```
# tree
.
├── adminer.php
├── customization.php
├── drivers.php
├── index.php
├── plugins
│   ├── drivers
│   │   └── index.php
│   ├── index.php
│   └── plugin.php
└── plugins.php

3 directories, 8 files
```

* `customization.php`: Combine customization and plugins.
* `drivers.php`: Enable extra drivers just by including them.
* `plugins.php`: Specify enabled plugins here after you add them in `plugins/`.

You can also easily put your `adminer.css` alongside `adminer.php`.

### Arguments

* `adminerevo_tag` (default: `13.3-php82-apache`): See [#tags](#tags).
* `adminerevo_plugins` (optional): A space-separated list of plugins to be added.
* `adminerevo_design` (optional): Design to be used.
* `adminerevo_php_type` (default: `production`) The PHP configuration file to link to `/usr/local/etc/php.ini`. Valid values: `development`, `production`. Only valid for apache, use the `php_type` argument when using php-fpm.
* `adminerevo_upload_limit` (default: `128M`): This option will change [upload_max_filesize](https://www.php.net/manual/en/ini.core.php#ini.upload-max-filesize) and [post_max_size](https://www.php.net/manual/en/ini.core.php#ini.post-max-size) values. Format: `[0-9]+[KMG]`.
* `adminerevo_memory_limit` (default: `1G`): This option will override the memory limit for PHP ([memory_limit](https://www.php.net/manual/en/ini.core.php#ini.memory-limit)). Format: `[0-9]+[KMG]`.
* `adminerevo_max_execution_time` (default: `600`): This option will override the maximum execution time in seconds for PHP ([max_execution_time](https://www.php.net/manual/en/info.configuration.php#ini.max-execution-time)).
* `adminerevo_session_save_path` (default: `/sessions`): See [session.save_path](https://www.php.net/manual/en/session.configuration.php#ini.session.save-path).
* `adminerevo_tz` (default: `UTC`): Change [date.timezone](https://www.php.net/manual/en/datetime.configuration.php#ini.date.timezone).

### Volumes

#### Apache

| Name                    | Owner | Group | Perm | Type | Mountpoint                                   |
| ----------------------- | ----- | ----- | ---- | ---- | -------------------------------------------- |
| adminerevo-plugins-file |   -   |   -   |  -   |  -   | usr/local/www/apache24/data/plugins.php      |
| adminerevo-plugins      |   -   |   -   |  -   |  -   | /usr/local/www/apache24/data/plugins         |
| adminerevo-drivers      |   -   |   -   |  -   |  -   | /usr/local/www/apache24/data/plugins/drivers |

#### FPM

| Name                      | Owner | Group | Perm | Type | Mountpoint                                |
| ------------------------- | ----- | ----- | ---- | ---- | ----------------------------------------- |
| adminerevo-plugins-file   |   -   |   -   |  -   |  -   | usr/local/www/adminerevo/plugins.php      |
| adminerevo-plugins        |   -   |   -   |  -   |  -   | /usr/local/www/adminerevo/plugins         |
| adminerevo-drivers        |   -   |   -   |  -   |  -   | /usr/local/www/adminerevo/plugins/drivers |

## Tags

| Tag                 | Arch    | Version        | Type   | `adminerevo_version` |
| ------------------- | ------- | -------------- | ------ | -------------------- |
| `13.3-php82-apache` | `amd64` | `13.3-RELEASE` | `thin` |        `4.8.4`       |
| `13.3-php82-fpm`    | `amd64` | `13.3-RELEASE` | `thin` |        `4.8.4`       |
| `14.0-php82-apache` | `amd64` | `14.0-RELEASE` | `thin` |        `4.8.4`       |
| `14.0-php82-fpm`    | `amd64` | `14.0-RELEASE` | `thin` |        `4.8.4`       |

## Notes

1. Only `mysqli`, `pgsql`, `sqlite3` and `pdo_dblib` are included in the images. 
