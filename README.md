# transcendence-scripts

## forkwatch.sh
Compares the blockhashes of explorer.teloscoin.org, telos.polispay.com and your local wallet.

### Configuration
* `FORKTHRESHOLD` - (default: 60) sets how much Master Nodes the explorer should know, else we think it is forked and exit.
* `SAFEMARGIN` - (default: 50) we don't compare the latest hashes, as they are subject to change due to consensus. We compare the hash of (blockheight - $SAFEMARGIN) to rule out orphan hashes.
* `TRANSCENDENCE` - (default: ./transcendence-cli) sets where the transcendence-cli binary is. The default refers to the directory where this script is run from.

### How to run
```
wget https://github.com/qSebastiaNp/transcendence-scripts/raw/main/forkwatch.sh
chmod u+x forkwatch.sh
./forkwatch.sh
```
