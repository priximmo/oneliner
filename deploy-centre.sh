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
	
	nbserv=$2
	[ "$nbserv" == "" ] && nbserv=2
	
	# rapatriement de l'image si elle n'exsiste pas
	echo "Installation de l'image "
	docker pull priximmo/stretch-systemd-ssh:v3.1

	# création des conteneurs
	echo "Création : ${nbserv} conteneurs..."

	# détermination de l'id mini
  id_first=$(docker ps -a --format "{{ .Names }}" |grep "oki-vmparc" | sed s/".*-vmparc"//g  | sort -nr | head -1)
	id_min=$(($id_first+1))

	#détermination de l'id max
	id_max=$(($nbserv + $id_min - 1))

	for i in $( seq $id_min $id_max );do
		echo ""
		echo "=> conteneur ${USERNAME}-vmparc${i}"
    docker run -tid -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name ${USERNAME}-vmparc${i} priximmo/stretch-systemd-ssh:v3.1
		echo "    => création de l'utilisateur ${USERNAME}"
		docker exec -ti ${USERNAME}-vmparc${i} /bin/bash -c "useradd -m -p sa3tHJ3/KuYvI ${USERNAME}"
		echo "Installation de votre clé publique ${HOME}/.ssh/id_rsa.pub"
		docker exec -ti ${USERNAME}-vmparc${i} /bin/bash -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown ${USERNAME}:${USERNAME} $HOME/.ssh"
		docker cp ${HOME}/.ssh/id_rsa.pub ${USERNAME}-vmparc${i}:${HOME}/.ssh/authorized_keys
		docker exec -ti ${USERNAME}-vmparc${i} /bin/bash -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown ${USERNAME}:${USERNAME} ${HOME}/.ssh/authorized_keys"
		docker exec -ti ${USERNAME}-vmparc${i} /bin/bash -c "echo '${USERNAME}   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti ${USERNAME}-vmparc${i} /bin/bash -c "service ssh start"
	done
	echo ""
	echo "Liste des ip  attribuées :"
	for i in $( seq $id_min $id_max );do

	infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' ${USERNAME}-vmparc${i})
	echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"
	
	done

fi

if [ "$1" == "--drop" ];then

	for i in $(docker ps -a --format "{{ .Names }}" |grep "${USERNAME}-vmparc" );do
		echo "     --Arrêt de ${i}..."
		docker stop $i
		echo "     --Suppression de ${i}..."
		docker rm $i
		done

fi

if [ "$1" == "--infos" ]; then

	for i in $(docker ps -a --format "{{ .Names }}" |grep "vmparc" );do
		infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' ${i})
		echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"
	done

fi

if [ "$1" == "--start" ];then
	
	sudo /etc/init.d/docker start

	
        for i in $(docker ps -a --format "{{ .Names }}" |grep "vmparc" );do
                echo "     --Démarrage de ${i}..."
                docker start $i
                #echo "     --Démarrage de sshd sur ${i}"
                #docker exec -ti ${i} /bin/bash -c "sudo service ssh start"
        done
echo ""
echo "#### Récap des infos ####"
echo ""


	for i in $(docker ps -a --format "{{ .Names }}" |grep "${USERNAME}-vmparc" );do
                infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' ${i})
                echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"
        done


fi
