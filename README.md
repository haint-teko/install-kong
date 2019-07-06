### Decision Maker 
A Kong plugin used to integrate with ORY-Oauthkeeper

### Source Install
```shell
$ git clone https://github.com/haint-teko/decision-maker
$ cd decision-maker

# install the Lua source
$ luarocks make

# pack the installed rock
$ luarocks pack kong-plugin-decision-maker-{version}.rockspec
```

### Configuration
This plugin is compatible with requests with the following methods:
- `http`
- `https`

**1. Add plugin to your Kong config**

```shell
Add `decision-maker` under the `plugins` property in your Kong config file.
plugins = decision-maker
```

**2. Restart Kong**

```shell
Issue the following command to restart Kong. This allows Kong to load the plugin.
$ kong restart
```

**3. Enable the plugin**
- **Enable the plugin on the global** 

Configure this plugin on the global by making the following request:

```shell
$ curl -i -X POST http://kong:8001/plugins \
    --data "name=decision-maker"
```

- **Enable the plugin on a Service**

Configure this plugin on a Service by making the following request:

```shell
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=decision-maker"  \
    --data "config.timeout=60000" \                      # default: 60000
    --data "config.keepalive=60000" \                    # default: 60000
    --data "config.decision_maker.id={decision-maker}"   # default: null
```

- **Enable the plugin on a Route**

Configure this plugin on a Route by making the following request:

```shell
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=decision-maker"  \
    --data "config.timeout=60000" \                      # default: 60000
    --data "config.keepalive=60000" \                    # default: 60000
    --data "config.decision_maker.id={decision-maker}"   # default: null
```

- **Enable the plugin on a Consumer**

Configure this plugin on a Consumer by making the following request:

```shell
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=decision-maker"  \
    --data "config.timeout=60000" \                      # default: 60000
    --data "config.keepalive=60000" \                    # default: 60000
    --data "config.decision_maker.id={decision-maker}"   # default: null
```

### Parameters
Here's a list of all the parameters which can be used in this plugin's configuration:

| FORM PARAMETER           | DEFAULT | DESCRIPTION                                                                                                   |
| ------------------------ | ------- | ------------------------------------------------------------------------------------------------------------- |
| name                     |         | The name of the plugin to use, in this case `decision-maker`                                                  |
| service_id               |         | The id of the Service which this plugin will target.                                                          |
| route_id                 |         | The id of the Route which this plugin will target.                                                            |
| enabled                  | `true`  | Whether this plugin will be applied.                                                                          |
| consumer_id              |         | The id of the Consumer which this plugin will target.                                                         |
| config.timeout           | `60000` | Timeout in milliseconds before aborting a connection to the Decision-Maker server.                            |  
| config.keepalive         | `60000` | Time in milliseconds for which an idle connection to the Decision-Maker server will live before being closed. |
| config.decision_maker.id | `null`  | The id of the Decision-Maker server which this plugin will ask for request's authorization                    |