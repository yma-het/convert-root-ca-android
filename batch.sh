#! /bin/bash
ORIG_DIR=$(pwd)
DIR=$(mktemp -d)
pushd $DIR

CA_URL="https://www.geotrust.com/resources/root-certificates/index.html"
CA_REGEX="https\://www.geotrust.com/[^\"]**\.pem"
curl -s $CA_URL | grep -oh -e "$CA_REGEX" | sort -u | xargs wget

for f in $(find . -maxdepth 1 -not -type d | grep -v $0)
do
    DIDGEST=$(openssl x509 -inform PEM -subject_hash_old -in $f | head -1)
    cat $f > $DIDGEST.0
    openssl x509 -inform PEM -text -in $f -out /dev/null >> $DIDGEST.0
    # In case of executing this script in WSL console on win FSS
    sed -i "s/\r//" $DIDGEST.0
done
mkdir $ORIG_DIR/ca_certs
cp *.0 $ORIG_DIR/ca_certs
popd
