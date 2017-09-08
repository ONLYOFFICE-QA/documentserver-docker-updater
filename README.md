# doc-linux-docker-updater
Bash scripts for updating doc-linux.teamlab.info

# Installation

```
ssh-copy-id root@doc-linux.teamlab.info
git clone https://github.com/onlyoffice-testing-robot/doc-linux-docker-updater.git
mkdir -pv ~/bin
cp doc-linux-docker-updater/doc-linux-connect ~/bin
cp doc-linux-docker-updater/doc-linux-update ~/bin
```
Start new terminal window - and commands should be available. 

# Usage

`doc-linux-connect` - just connect to doc-linux.teamlab.info via ssh  
`doc-linux-update` - update doc-linux to `latest` docker tag  
`doc-linux-update 5.0.0.56` - update to specific docker tag (`5.0.0.56`)
