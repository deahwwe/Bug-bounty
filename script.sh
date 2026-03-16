#!/bin/bash

domain=$1

echo "============================="
echo " IIS Bug Bounty Automation "
echo " Target: $domain"
echo "============================="

mkdir -p $domain
cd $domain

echo "[1] Subdomain Enumeration"
subfinder -d $domain -silent > subs.txt

echo "[2] Checking Live Hosts"
httpx -l subs.txt -title -tech-detect -server -status-code -silent > live.txt

echo "[3] Port Scanning"
naabu -l live.txt -top-ports 1000 -silent > ports.txt

echo "[4] Crawling URLs"
katana -list live.txt -silent > urls.txt

echo "[5] Extracting Parameters"
cat urls.txt | grep "=" > params.txt

echo "[6] Directory Fuzzing"
ffuf -u https://FUZZ.$domain -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -mc 200

echo "[7] Running Nuclei"
nuclei -l live.txt -severity critical,high,medium -o vulns.txt

echo "[8] IIS Specific Scan"
nuclei -l live.txt -tags iis,asp,aspx -o iis_vulns.txt

echo "============================="
echo " Scan Complete"
echo " Results saved in $domain folder"
echo "============================="
