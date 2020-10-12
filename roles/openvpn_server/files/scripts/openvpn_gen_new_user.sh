#!/usr/bin/env bash

set -e #dont remove it =)

#cfg
corpMail="soft-machine.ru"
secretFile="/etc/openvpn/easy-rsa/pki/index.txt"
senderAddress="officespb@soft-machine.ru"
senderName="soft-machine Tech Department"
tempDir="openvpn_generator/config"
newUserName="$1"
#action
echo "используйте @"$corpMail" email пользвателя (только логин)"
echo "например george, если email george@"$corpMail""


#check isExists
newLogin="$newUserName"

if [[ -z `grep CN="$newLogin" "$secretFile"` && ! -z "$newUserName" ]]
then
	#create new user cert
	cd /etc/openvpn/easy-rsa/
	./easyrsa --batch --req-cn="$newLogin" gen-req "$newLogin" nopass &&\
	./easyrsa --batch sign-req client "$newLogin"

	mkdir -p /tmp/"$tempDir"/
	rm -f /tmp/openvpn_generator/*.zip
	rm -f /tmp/"$tempDir"/*

	#copy server files
	cp ta.key /tmp/"$tempDir"/
	cp ./pki/ca.crt /tmp/"$tempDir"/

	#copy Key Pair
	cp `
	`./pki/private/"$newLogin".key `
	`./pki/issued/"$newLogin".crt  `
	`/tmp/"$tempDir"

	#generate config
	cp -f template_client_config soft-machine.ovpn
	sed -i 's/XXX/'$newLogin'/g' soft-machine.ovpn
	mv soft-machine.ovpn /tmp/"$tempDir"/

	#generate arch
	cd /tmp/openvpn_generator/
	zip `
	`"$newLogin"_keys.zip `
	`config/ca.crt `
	`config/"$newLogin".crt `
	`config/"$newLogin".key `
	`config/ta.key `
	`config/soft-machine.ovpn

	#send email
	userEmail=""$newUserName"@"$corpMail""
	mailSubject="Новый доступ OpenVPN для "$newUserName""
	generatedArch="/tmp/openvpn_generator/"$newLogin"_keys.zip"
	mailText="Ключи в архиве, прикреплённом к этому письму. Инструкция: https://soft-machine.atlassian.net/wiki/spaces/OF/pages/22446100/OpenVpn+client"
	export EMAIL=""$senderName" <"$senderAddress">" && echo -e "$mailText" | mutt -a "$generatedArch" -s "$mailSubject" -- "$userEmail"

	#report
	echo "Новый доступ для "$newLogin" отправлен на "$userEmail"" 
	echo "Он уже работает, ничего перезапускать не нужно"

	exit 0
else
	echo "Пользователь "$newLogin" уже существует (либо ничего не введено), аварийное завершение!"
	exit 1
fi
