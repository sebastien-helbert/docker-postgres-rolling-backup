# PostgreSQL database rolling backup

Docker image for PostgreSQL database rolling backup

# Supported tags and respective `Dockerfile` links

-	[`10.3`, `latest` (*10.3/Dockerfile*)](https://github.com/sebastien-helbert/postgres-rolling-backup/blob/10.3/Dockerfile)
-	[`10.1`, `latest` (*10.1/Dockerfile*)](https://github.com/sebastien-helbert/postgres-rolling-backup/blob/10.1/Dockerfile)
-	[`9.6`, (*9.6/Dockerfile*)](https://github.com/sebastien-helbert/postgres-rolling-backup/blob/9.6/Dockerfile)

# How to use this image

## Make a postgres database backup

```console
$ docker run -e POSTGRES_HOST=my_db_host -e POSTGRES_USER=my_db_user -e POSTGRES_PASSWORD=my_secret-password shelbert/postgres-rolling-backup
```

This image produces database backups into `/var/lib/postgresql/backup` folder. Use docker volume mapping to make dumps available to other containers or somewhere on the docker host.

> This image is based on the [postgres:10.3 official docker image](https://hub.docker.com/_/postgres/) and use postgre tools provided by this image.  

## Using a docker volume

```console
$ docker run -v /path_to_backup_folder_on_docker_host:/var/lib/postgresql/backup -e POSTGRES_HOST=my_db_host -e POSTGRES_USER=my_db_user -e POSTGRES_PASSWORD=my_secret-password shelbert/postgres-rolling-backup
```

## Environment Variables

### `POSTGRES_HOST`

Optional hostname to adhere to pg_hba policies. Will default to "localhost" if none specified.

### `POSTGRES_USER`

Optional username to connect to database as. Will default to "postgres" if none specified.

### `POSTGRES_PASSWORD`

Optional password to connect to database as. Will default to empty if none specified.

### `BACKUP_DIR`

Optional backup path. Will default to "/var/lib/postgresql/backup" if none specified.

### `BACKUP_GLOBALS`

If set to "yes" (default value), will produce gzipped sql file containing the cluster globals, like users and passwords

### `BACKUP_RETENTION_DAY_OF_WEEK_TO_KEEP`

Which day to take the weekly backup from (1-7 = Monday-Sunday). Will default to 5 if none specified.

### `BACKUP_RETENTION_DAY_OF_MONTH_TO_KEEP`

Which day to take the monthly backup from. Will default to 1 if none specified.

