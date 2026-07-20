#!/bin/bash

sudo nmap -sn 10.20.10.0/24 | grep -B 2 "Unknown"

