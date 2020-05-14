# Project

scripts:

bettercap_setup.sh - script to setup bettercap, more info in Iteration I report

record_with_mitm.sh, record_without_mitm.sh - scripts to record actions passed through mitmproxy and analyze them with mitmengine (one emulate connection as if there is mitmproxy, another one as there is no mitmproxy), more info Iteration IV report

router_script.sh - script to set up one virtual machine as a router (if another machine is connected to the “router” it will have an automatic access to the internet), it is possible not to launch the router_script.sh after every reboot by iptables-persistent usage.

patches:

my_main.patch - nearly the same main as was in mitmengine/cmd/demo but with additional outputs

mitmengine.patch - my trials to fix existing mitmengine python scripts (not finished) + manually added signature

ova:

I had setup with two virtual machines (for more information see Iteration III report)

That is a link to the important ova (Attacker + Detector):

https://drive.google.com/file/d/1it9XutX5brvca6FAJa4zgMAfTiEu5Lxa/view?usp=sharing

Steps to recreate environment:

1)Download Attacker + Detector machine, launch it, make sure internet is OK.

2)Create a Victim machine (can be mostly anything), connect it to the Attacker + Detector machine, make sure that internet works on Victim machine too.

3)Run record_without_mitm.sh (it is in VM’s Downloads), start to do something on Victim machine in browser (better to use firefox). There can be warnings, because of the certificates, need to add mitmproxy certificates to avoid warnings or just ignore them.

4)You will see user agent and fingerprint, now you need to add them to mitmengine database (reference_fingerprints/mitmengine/browser.txt), example can be found in mitmengine.patch

Now it is possible to use set_up_transparent_mitm_with_pcap.sh script ( identical to record_with_mitm.sh in github) and play with mitm.
