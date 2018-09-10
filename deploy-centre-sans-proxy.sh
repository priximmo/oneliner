#!/bin/bash

###############################################################
#  TITRE: 
#
#  AUTEUR:   Xavier
#  VERSION: 
#  CREATION:  12:14:04 07/09/2018
#  MODIFIE: 
#
#  DESCRIPTION: 
#   mot de passe obtenu par :
#          perl -e 'print crypt("password", "salt"),"\n"'
###############################################################

USERNAME=$(id -nu)

if [ "$1" == "--proxy" ];then
	
	if [ -f /etc/systemd/system/docker.service.d/http-proxy.conf ];then
		sudo rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
		sudo service docker restart
	fi 

fi


if [ "$1" == "--create" ];then

	echo "Installation de l'image "
	docker pull priximmo/debian-sshd:first

	nbserv=$2
	[ "$nbserv" == "" ] && nbserv=2
	echo "Création : ${nbserv} conteneurs..."

	for i in $( seq 1 $nbserv );do
		echo "=> conteneur servparc${i}"
		docker run -tid --name servparc${i} priximmo/debian-sshd:first
		echo "    => création de l'utilisateur USERNAME"
		docker exec -ti servparc${i} /bin/bash -c "useradd -m -p sa3tHJ3/KuYvI ${USERNAME}"
		echo "Installation de votre clé publique ${HOME}/.ssh/id_rsa.pub"
		docker exec -ti servparc${i} /bin/bash -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown ${USERNAME}:${USERNAME} $HOME/.ssh"
		docker cp ${HOME}/.ssh/id_rsa.pub servparc${i}:${HOME}/.ssh/authorized_keys
		docker exec -ti servparc${i} /bin/bash -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown ${USERNAME}:${USERNAME} ${HOME}/.ssh/authorized_keys"
		docker exec -ti servparc${i} /bin/bash -c "apt-get update && apt-get install -y python-minimal && apt-get install -y sudo"
		docker exec -ti servparc${i} /bin/bash -c "echo '${USERNAME}   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti servparc${i} /bin/bash -c "service ssh start"
	done
	echo ""
	echo "Liste des ip  attribuées :"
	for i in $( seq 1 $nbserv );do

	infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' servparc${i})
	echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"

	
	
	done

fi

if [ "$1" == "--drop" ];then

	for i in $(docker ps -a --format "{{ .Names }}" |grep "servparc" );do
		echo "     --Arrêt de ${i}..."
		docker stop $i
		echo "     --Suppression de ${i}..."
		docker rm $i
		done

fi

if [ "$1" == "--infos" ]; then

	for i in $(docker ps -a --format "{{ .Names }}" |grep "servparc" );do
		infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' ${i})
		echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"
	done

fi
