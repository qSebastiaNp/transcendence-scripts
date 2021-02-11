# transcendence-scripts

## forkwatch.sh
Compares the blockhashes of explorer.teloscoin.org, telos.polispay.com and your local wallet.

### Configuration
* `SAFEMARGIN` - (default: 50) we don't compare the latest hashes, as they are subject to change due to consensus. We compare the hash of (blockheight - $SAFEMARGIN) to rule out orphan hashes.
* `TRANSCENDENCE` - (default: ./transcendence-cli) sets where the transcendence-cli binary is. The default refers to the directory where this script is run from.
* `IFTTTKEY` - (default: none) enter your key for IFTTT to get a push notification when you are forked.

### How to run
```
wget https://github.com/qSebastiaNp/transcendence-scripts/raw/main/forkwatch.sh
chmod u+x forkwatch.sh
./forkwatch.sh
```

### Cron with e-mail
This assumes you have a working mailing system (Exim, Postfix,...) on your server. If not, you cannot be alarmed by email and putting the script into cron would be pointless.
This will only email you in case of errors, and like this, would run every hour. Feel free to change the 0 to something else, to avoid the explorer being hammered at full hours.
```
MAILTO=your@email-address.com
0       *       *       *       *       /home/your-user/path-to-the-script/forkwatch.sh > /dev/null
```

### Cron with IFTTT
Put this into your crontab. Note the difference to the cron command above.
Feel free to change the 0 to something else, to avoid the explorer being hammered at full hours.
```
0       *       *       *       *       /home/your-user/path-to-the-script/forkwatch.sh > /dev/null 2>&1
```
You have to have a working IFTTT account. If you have none, create a free account on www.ifttt.com. Then follow these instructions:
1. Go to https://ifttt.com/maker_webhooks and click "Connect"
1. Click on "Documentation" in the upper right, copy the part after /key/ and put it in `IFTTTKEY` in the script
1. Click on "Create" in the upper menu and at "If This" click "Add"
1. Type "Webhooks", click on the Webhooks square and then on "Receive a web request"
1. Give it the event name "notify" and click "Create Trigger"
1. Under "Then That" click on "Add" and type "Notifications", click on the square
1. Click on "Send a notification from the IFTTT app"
1. Delete the sample message and write: `Notification: {{Value1}}`
1. Click "Create Action", "Continue", "Finish".
1. Install the IFTTT app on your iPhone or Android and log in with your account. You will now receive a push message when your watched wallet is forked.

### Caveats
This script cannot provide guidance if:
* a large chunk of the network has forked away. Check the discord then for reports and instructions.
* explorer.teloscoin.org *and* telos.polispay.com fork away, the script cannot determine what should be the right blockhash. This should not happen though.
* Don't use or trust the script around planned forks.

### ToDo / Known Problems
* there is no error checking for downtime or errors of the explorer or PolisPay
* there is no checking whether you have the current wallet version
* the script can't detect stuck wallets and `getblockhash` will return an error (well, there is your detection)
* the script can't handle overloaded/unresponsive wallets (transcendence-cli will never return anything and hang, leave with CTRL + C after some minutes, add `maxconnections=32` to your transcendence.conf and restart your wallet!)
