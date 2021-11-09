#!/bin/bash
##This acquires the IPs on all Eth interfaces, formats them down to 4 octets##

##tmp files used for vars##
rm ip.txt
rm dns.txt

##Assumes max of 5ints##
i=0
until [ $i -gt 5 ]
do
ints=`ifconfig | grep -A 1 eth[0-$i] | sed -e 's/[A-Za-z]//g' -e's/255./	/g' | tail -n 1 | cut -c 10-24 >> ip.txt`
let "i+=1" ;
done;
##Repeats action; action greps each int, elimates alphabetical chars, replaces subnetmask w/ whitespace, extracts the last line and cuts relevant chars##
##It then outputs the extracted content to ip.txt##

##Elimates duplicate entries in ip.txt & re-writes to file##
value2=`sort ip.txt | uniq -d`
value=`sort ip.txt | uniq -u`
echo "$value" > ip.txt
echo "$value2" >>ip.txt
ipval=`cat ip.txt`
cat ip.txt
echo "All Ints IPs on Device"
echo ""
echo "All Int ranges on device"
##The value of addresses is cached in ipval for recalling later#

##$range takes the ip.txt file, uses . as a delimiter and subs in the 4th octet with .0 for subnet address##
range=`cat ip.txt | awk -F. '{print $1,$2,$3}' | sed 's/ /./g'| sed 's/$/.0/g'`
echo "$range" > ip.txt
cat ip.txt
echo "Above is the full range of Interface IPs on this device."
sleep 1;
##Above code formats down to ranges of IPs, the var to recall the IPs is ipval##
##Ipval is retained as it's stored prior to the manipulation##
echo "$ipval"


##If Statements begin here to choose nmap action##
echo "Type the corresponding number for the action you wish to take"

## \ in front of grep is to stop escape##
file=ip.txt
while read line; do
nmap "$line"-254 -sL
done < $file >> dns.txt  
dns=`grep \(  dns.txt`
echo "$dns" > dns.txt

echo ""
echo "4 for OS detection sweep, 3 for open VNC port, 2 for SSH scan, 1 for all hosts"
read num
##This is the beginning of loops using ip.txt for ranges##
##The files written here are only invoked if the correct number is selected##
if [[ $num = 1 ]]
then
echo "$dns"

elif [[ $num = 2 ]]
then
file2=ip.txt
while read line; do
nmap -p 22 --open "$line"/24
done < $file2 >> ssh.txt
ssh=`cat ssh.txt`
echo "$ssh"


elif [[ $num = 3 ]] 
then
file3=ip.txt
while read line; do
nmap -p 5900 --open "$line"/24 
done < $file3 >> vnc.txt
vnc=`cat vnc.txt`
echo "$vnc"

elif [[ $num = 4 ]]
then
file4=ip.txt
while read line; do
nmap -Os "$line"/24
done < $file4 >> OS.txt
OS=`cat OS.txt`
echo "$vnc"


else
echo "Not done"
fi

##Note this only works on a proper VM, no WSL## 




