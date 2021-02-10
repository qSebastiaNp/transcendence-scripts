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

### Cron
This assumes you have a working mailing system (Exim, Postfix,...) on your server. If not, you cannot be alarmed by email and putting the script into cron would be pointless.
This will only email you in case of errors, and like this, would run every hour. Feel free to change the 0 to something else, to avoid the server being hammered at full hours.
```
MAILTO=your@email-address.com
0       *       *       *       *       /home/your-user/path-to-the-script/forkwatch.sh  > /dev/null
```

### Caveats
This script cannot provide guidance if:
* a large chunk of the network has forked away. Check the discord then for reports and instructions.
* explorer.teloscoin.org *and* telos.polispay.com fork away, the script cannot determine what should be the right blockhash. This should not happen though.
* Don't use or trust the script around planned forks.

### ToDo / Known Problems
* there is no error checking for downtime or errors of the explorer or PolisPay
* there is no checking whether you have the current wallet version
* when explorer forks away, the script will report that *you* are forked, because explorer is always right. Isn't it?
* the script can't detect stuck wallets and `getblockhash` will return an error (well, there is your detection)
* the script should compare the count of masternodes your local wallet can see against the explorer's count, not use an arbitrary value
* the script itself can't send emails. To not require a mailserver to be installed, we should use a lightweight smtp mailer
