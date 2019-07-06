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
1. Add plugin to your Kong config

```shell
Add `decision-maker` under the `plugins` property in your Kong config file.
plugins = decision-maker
```

2. Restart Kong

```shell
Issue the following command to restart Kong. This allows Kong to load the plugin.
$ kong restart
```

