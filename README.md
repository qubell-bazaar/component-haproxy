haproxy
=======

![](http://haproxy.1wt.eu/img/logo-med.png)

Installs and configures [HAProxy](http://haproxy.1wt.eu/), a TCP/HTTP load balancer.

Version 1.0-34p
-------------

[![Install](https://raw.github.com/qubell-bazaar/component-skeleton/master/img/install.png)](https://express.qubell.com/applications/upload?metadataUrl=https://raw.github.com/qubell-bazaar/component-haproxy/1.0-34p/meta.yml)

Features
--------

 - Install and configure HAProxy
 - Add or remove routing buckets

Configurations
--------------
[![Build Status](http://jenkins.dev.qubell.com:8080/buildStatus/icon?job=haproxy-component-upstream)](http://jenkins.dev.qubell.com:8080/view/Bazaar-Components/view/component-haproxy-dev/job/haproxy-component-upstream/)
 
 - HAProxy *** (latest), CentOS 6.3 (us-east-1/ami-eb6b0182), AWS EC2 m1.small, root
 - HAProxy *** (latest), CentOS 5.3 (us-east-1/ami-beda31d7), AWS EC2 m1.small, root
 - HAProxy *** (latest), Ubuntu 12.04 (us-east-1/ami-d0f89fb9), AWS EC2 m1.small, root
 - HAProxy *** (latest), Ubuntu 10.04 (us-east-1/ami-0fac7566), AWS EC2 m1.small, root

Pre-requisites
--------------
 - Configured Cloud Account a in chosen environment
 - Either installed Chef on target compute OR launch under root
 - Internet access from target compute:
  - HAproxy distibution: *** (CentOS), *** (Ubuntu)
  - S3 bucket with Chef recipes: ***
  - If Chef is not installed: ***

Implementation notes
--------------------
 - Installation is based on Chef recipes from ***

Example usage
-------------
***
