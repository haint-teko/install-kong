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

