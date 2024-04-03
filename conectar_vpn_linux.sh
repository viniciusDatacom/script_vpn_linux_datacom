#/bin/bash


if [ "$EUID" -ne 0 ]; then
    echo "Este script necessita de permissão root. Logue com root ou utilize sudo"
    exit 1
fi

apt install strongswan -y

clear

echo "Digite seu usuario AD(fmcudi):"
read user_ad

echo "Digite a senha de seu usuario AD:"
read pass_ad

conf_file="/etc/ipsec.conf"
secret_file="/etc/ipsec.secrets"
RED='\033[0;31m'
RESET='\033[0m'

# Add the configuration to the file
cat << EOF | sudo tee -a "$conf_file" > /dev/null
conn "fortinet"
    left=%any
    leftauth=psk
    leftid=""
    leftauth2=xauth
    xauth_identity="$user_ad"
    leftsourceip=%config
    right=187.72.13.129
    rightsubnet=10.0.0.0/8
    rightauth=psk
    keyexchange=ikev1
    aggressive=yes
    ike=aes128-sha1-aes256-sha256-modp1536!
    esp=aes128-sha1-aes256-sha256-modp1536!
    auto=start
EOF

cat << EOF | sudo tee -a "$secret_file" > /dev/null
: PSK "6qs3#&eyrV#p"
: XAUTH "$pass_ad"
EOF

systemctl restart ipsec

ipsec reload

ipsec update

echo "##########################################################"
echo -e "#Para ativar a conexão à VPN, digite: ${RED}ipsec up \"fortinet\"${RESET}#"
echo -e "#Para desligar a conexão, digite: ${RED}ipsec down \"fortinet\"${RESET}  #"
echo "##########################################################"