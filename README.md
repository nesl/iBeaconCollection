The whole system consists two parts: client side and server side. The client side is this iBeaconCollection app for iPhone/iPod, after collecting iBeacon data, they try to upload back to server easily run by Node.js. Before you start launch the iBeaconCollect app, create a configuration file for the device.

1. The whole web server is in the folder called web. Simply type command <b>"node index.js"</b> should work.
2. Under folder web, there are two important folders: upload and config. I put a sample configuration file in the folder config, but the format is below:
&lt;metadata&gt;
Txuuid
Txmajor
Txminor
Rxuuid Rxmajor Rxminor1
Rxuuid Rxmajor Rxminor2
...
Rxuuid Rxmajor RxminorN

Metadata is presettings. All the metadata flag begin with an underscope. Currently supported metadata flags are:
_txdisable: begin the app with TX disabled. (default is enabled)
_rxdisable: begin the app with RX disabled. (default is enabled)
_autoupload: begin the app with auto upload option enabled (default is disabled)
_manuallyflip: the statistics of beacons are fixed unless you touch the screen (default is changing the screen every 3 seconds)

Rxmajor and Rxminor can be -1, which means don't care.

3. The configuration file name is linked to the device name, and thus should be numbers only.
4. The collected data will be uploaded to folder upload, packed by device nane.
5. Launch the app and have fun!
