# Install Kong API Gateway
A Linux bash shell script used to install Kong API gateway

### Configuration

Configure environment variables in `.env` file:

```shell
PROXY_SERVER_NAME=kong          # The server name of Kong proxy. For example, `kong-gateway.com www.kong-gateway.com`
PROXY_SSL_CERT=                 # The absolute path to the SSL certificate for Kong Proxy.
PROXY_SSL_CERT_KEY=             # The absolute path to the SSL certificate key for Kong Proxy.
ADMIN_SERVER_NAME=admin-kong    # The server name of Kong Admin. For example, `kong-admin.com www.kong-admin.com`
ADMIN_SSL_CERT=                 # The absolute path to the SSL certificate for Kong Admin.
ADMIN_SSL_CERT_KEY=             # The absolute path to the SSL certificate key for Kong Admin.
POSTGRESQL_HOST=127.0.0.1       # Host of the PostgresSQL server.
POSTGRESQL_PORT=5432            # Port of the PostgresSQL server.
POSTGRESQL_USER=kong            # Postgres user.
POSTGRESQL_PASSWORD=            # Postgres user's password.
POSTGRESQL_DATABASE=kong        # The database name to connect to.
```

### Install Kong

**Note**: Ensure the connection between Kong server and PostgresSQL server is success.

Run the following command to install Kong API gateway:

```shell
$ sudo make install
```

**Note**: You should reboot the server after installing Kong successfully.

### Install Decision-Maker plugin

Run the following command to install Decision-Maker plugin:

```shell
$ sudo make decision-maker
```

### Commands
```shell
# start Kong
$ sudo systemctl start kong

# stop Kong
$ sudo systemctl stop kong

# restart kong
$ sudo systemctl restart kong

# reload kong
$ sudo systemctl reload kong

# check kong's status
$ sudo systemctl status kong
```

**Note**: You must start/stop/reload/restart Kong via Linux systemctl.

