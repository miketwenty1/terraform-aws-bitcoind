#!/bin/bash
# set -o errexit; set -o pipefail; set -o nounset;
echo "cloudinit ran" >> /tmp/cloudinit

echo "cloudinit started" >> /tmp/cloudinit

apt-get update
apt-get install awscli -y
apt-get install jq -y
apt-get install net-tools -y
apt-get install inotify-tools -y

################# setup cloudwatch monitoring ################
sleep 20
export EC2_INSTANCE=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`

# systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service >> /tmp/cloudinit
aws ssm send-command --document-name "AWS-ConfigureAWSPackage" --document-version "1" --targets '[{"Key":"InstanceIds","Values":["'"$EC2_INSTANCE"'"]}]' --parameters '{"action":["Install"],"installationType":["Uninstall and reinstall"],"version":[""],"additionalArguments":["{}"],"name":["AmazonCloudWatchAgent"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region ${REGION}
# sleeping 10 seconds to wait for the installation to complete
sleep 20
aws ssm send-command --document-name "AmazonCloudWatch-ManageAgent" --document-version "6" --targets '[{"Key":"InstanceIds","Values":["'"$EC2_INSTANCE"'"]}]' --parameters '{"action":["configure"],"mode":["ec2"],"optionalConfigurationSource":["default"],"optionalConfigurationLocation":[""],"optionalOpenTelemetryCollectorConfigurationSource":["default"],"optionalOpenTelemetryCollectorConfigurationLocation":[""],"optionalRestart":["yes"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --region ${REGION}
OK=$?
if [ "$OK" -ne "0" ]; then 
  echo "cloudwatch failed to install"  >> /tmp/cloudinit
  exit 1
else 
  echo "cloudwatch agent installed"  >> /tmp/cloudinit
fi
# these commands below are probably not needed
# systemctl enable amazon-cloudwatch-agent.service
# service amazon-cloudwatch-agent start
##############################################################

#################### EBS ##################################### 
mkdir -m 770 /bitcoind


echo "check ebs bitcoind disk device" >> /tmp/cloudinit
fdisk -l | grep /dev | tail -1 > /bitcoind/disk_info.txt
echo "grab disk specific" >> /tmp/cloudinit
cat /bitcoind/disk_info.txt | cut -d'/' -f3 | cut -d':' -f1 > /bitcoind/specific_disk.txt
export DISK=/dev/`cat /bitcoind/specific_disk.txt`
file -s $DISK > /bitcoind/starting_fs_ebs.txt

# format ebs if it isn't already xfs
if grep -q ": data$" "/bitcoind/starting_fs_ebs.txt"; then
  echo "found data device creating xfs fs on $DISK" >> /tmp/cloudinit
  mkfs -t xfs $DISK
fi

echo UUID=$(blkid -o value -s UUID $DISK)     /bitcoind   xfs    defaults,nofail   0   2 | tee -a /etc/fstab
mount -a
##############################################################

cd /bitcoind
wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz

tar -xvf bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz

gpg --keyserver hkp://keyserver.ubuntu.com --refresh-keys
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${GITIAN_PGP_KEY} # laanwj@gmail.com

echo "first bitcoin integrity check" >> /tmp/cloudinit
wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS
sha256sum --check SHA256SUMS | grep OK
if [ $? -eq 0 ]; then
    echo "hash checks out from bitcoincore.org." >> /tmp/cloudinit
else
    echo "hash doesn't match for bitcoin ${VERSION} linux 86x-64" >> /tmp/cloudinit
    exit 1
fi

echo "second bitcoin integrity check - our own hash check" >> /tmp/cloudinit
echo "${GITIAN_HASH} /bitcoind/bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz" | sha256sum -c -

if [ $? -eq 0 ]; then
    echo bitcoind checks out from hash. >> /tmp/cloudinit
else
    echo "Hash is incorrect for this version of bitcoin linux 86x-64" >> /tmp/cloudinit
    exit 1
fi

mkdir -p /bitcoind/bitcoin-${VERSION}/data
useradd -s /bin/bash -m bitcoiner 
groupadd bitcoin
usermod -a -G bitcoin bitcoiner

chown -R bitcoiner:bitcoin /bitcoind

export VERSION=${VERSION}
export BITCOIN_HOME=/bitcoind/bitcoin-${VERSION}
export BITCOIN_DATA=$BITCOIN_HOME/data/
export BITCOIN_BIN=$BITCOIN_HOME/bin

echo "export VERSION=${VERSION}" >> /home/bitcoiner/.bashrc
echo "export BITCOIN_HOME=$BITCOIN_HOME" >> /home/bitcoiner/.bashrc
echo "export BITCOIN_DATA=$BITCOIN_DATA" >> /home/bitcoiner/.bashrc
echo "export BITCOIN_BIN=$BITCOIN_BIN" >> /home/bitcoiner/.bashrc

echo "PATH=$PATH:$BITCOIN_BIN" >> /home/bitcoiner/.bashrc

mkdir -p /home/bitcoiner/.bitcoin
chown bitcoiner:bitcoiner /home/bitcoiner/.bitcoin
mv /tmp/bitcoin.conf /home/bitcoiner/.bitcoin/

# check for bitcoin.conf
FILE=/home/bitcoiner/.bitcoin/bitcoin.conf
if [ -f "$FILE" ]; then
    echo "$FILE exists." >> /tmp/cloudinit
    chown -R bitcoiner:bitcoin $FILE
else 
    echo "$FILE does not exist." >> /tmp/cloudinit
    exit 1
fi

echo "going to run bitcoind" >> /tmp/cloudinit
runuser -l  bitcoiner -c "$BITCOIN_BIN/bitcoind"
echo "Running bitcoind from $BITCOIN_BIN" >> /tmp/cloudinit
