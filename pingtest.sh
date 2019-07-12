#!/bin/bash
perl /home/ubnt/pingtest.pl -c 10 -I eth4,tun0,tun1 -d ping.ubnt.com | logger -t tunnel-status
