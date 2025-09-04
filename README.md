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
`doc-linux-update latest with-s3` - update `doc-linux.teamlab.info` to
`latest` docker tag with S3 integration
`doc-linux-update 5.0.0.56 with-s3` - update `doc-linux.teamlab.info` to
specific docker tag with S3 integration

`kim-connect` - just connect to `kim.teamlab.info` via ssh
`kim-update` - update `kim.teamlab.info` to `latest` docker tag
`kim-update 5.0.0.56` - update `kim.teamlab.info` to specific docker tag (`5.0.0.56`)
`kim-update latest with-s3` - update `kim.teamlab.info` to `latest`
docker tag with S3 integration
`kim-update 5.0.0.56 with-s3` - update `kim.teamlab.info` to specific
docker tag with S3 integration

## S3 Integration

DocumentServer can be configured to use Amazon S3 for file storage.
When using the `with-s3` parameter, the system automatically:

- Configures S3 bucket connection for DocumentServer
- Copies S3 configuration to the container
- Restarts DocumentServer services to apply the configuration

Requirements for S3 integration:

For S3 integration, you need to create `~/.s3` directory with two files:

- `~/.s3/key` - contains your AWS Access Key ID
- `~/.s3/private_key` - contains your AWS Secret Access Key

## Update ./plugins/plugins-list-actual.json

> requirements: python3, json, requests

```bash
    python3 get_plugins_script.py
```

## Updating fonts

1. Add font files to repo [doc-linux-fonts](https://github.com/ONLYOFFICE-QA/doc-linux-fonts)
2. Connect to server and update repo

   ```bash
   cd /usr/share/fonts/custom/doc-linux-fonts/
   git pull
   ```

3. Update documentserver
