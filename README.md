# documentserver-docker-updater

Bash scripts for updating doc-linux.teamlab.info

## Installation

```shell script
ssh-copy-id root@doc-linux.teamlab.info
ssh-copy-id root@kim.teamlab.info
git clone https://github.com/onlyoffice-testing-robot/documentserver-docker-updater.git
cd documentserver-docker-updater
mkdir -pv ~/bin
ln -s $PWD/doc-linux-connect $HOME/bin/doc-linux-connect
ln -s $PWD/doc-linux-update $HOME/bin/doc-linux-update
ln -s $PWD/kim-connect $HOME/bin/kim-connect
ln -s $PWD/kim-update $HOME/bin/kim-update
```

Start new terminal window - and commands should be available.

## Usage

`doc-linux-connect` - just connect to `doc-linux.teamlab.info` via ssh  
`doc-linux-update` - update `doc-linux.teamlab.info` to `latest` docker tag  
`doc-linux-update 5.0.0.56` - update `doc-linux.teamlab.info`
 to specific docker tag (`5.0.0.56`)

`kim-connect` - just connect to `kim.teamlab.info` via ssh  
`kim-update` - update `kim.teamlab.info` to `latest` docker tag  
`kim-update 5.0.0.56` - update `kim.teamlab.info` to specific docker tag (`5.0.0.56`)

## Update ./plugins/plugins-list-actual.json

>requirements: python3, json, requests

```bash
    python3 get_plugins_script.py
```
