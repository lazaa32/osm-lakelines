#Imposm
read -p "Install Imposm? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	wget https://github.com/omniscale/imposm3/releases/download/v0.11.1/imposm-0.11.1-linux-x86-64.tar.gz
	tar -xvf imposm-0.11.1-linux-x86-64.tar.gz
	mv imposm-0.11.1-linux-x86-64/ imposm/
fi
