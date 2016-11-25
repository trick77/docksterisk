# docksterisk
## What is it?
It's is a **starting point** to a containerized Asterisk SIP server.  It includes mimimalistic extensions and dialplan configurations. It's using Asterisk 14 and PJSIP instead of CHAN_SIP. 

I primarily created docksterisk for my own use but feel free to use it, or part of it, for your own SIP server.

## What is it not?
* No UI
* Not Asterisk-noob-friendly
* No documentation
* No support

## What is it based on?
Generally this is based on:
* phusion/baseimage
* Asterisk 14

## What does it include?
* A docker-compose to build/run the image/container
* Shows how to use the PJSIP wizard for easier extension and trunk configuration
* A minimalistic dialplan
* Multilingual GoogleTTS (Text To Speech) AGI, dial extension 300 for a demo
* Shows how to use a telemarketers blacklist to ban calls
* Shows how to use iptables on the host against script kiddie scans
* Asterisk log messages forwarded to Docker-logs

## Additional information
* Since large port ranges in Docker (in combination with iptables) are problematic, I'm exposing the host network to the Docksterisk container
* Ports used: 5060/udp (SIP), 8088/tcp (HTTP), 16384-17000/udp
* The configuration samples assume that the SIP phones are behind NAT and the SIP server is on a public, static IP (i.e. on a VPS)
* If you want to use the built-in webserver for uptime monitoring, you can use this URL: http://mysipserver:8088/docksterisk/httpstatus/

