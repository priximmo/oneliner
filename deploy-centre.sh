#!/bin/bash

###############################################################
#  TITRE: 
#
#  AUTEUR:   Xavier
#  VERSION: 
#  CREATION:  07/09/2018
#  MODIFIE: 	24/09/2018
#				
#  DESCRIPTION: 
#		- V2 : prise en compte du multi os (debian redhat)
#   mot de passe obtenu par :
#          perl -e 'print crypt("password", "salt"),"\n"'
###############################################################

USERNAME=$(id -nu)

if [ -z "$1" ];then
	echo "
Aide :
	--proxy : pour ajouter le proxycs dans la conf docker de manière à faire des push et des pull

	--create-debian : par défaut créé 2 conteneurs debian (sinon préciser le chiffre en arguement)

	--create-centos : par défaut créé 2 conteneur centos (idem préciser une valeur sinon)
			
	--drop : pour supprimer tous les conteneurs que vous avez créé (uniquement ceux commençant par votre nom de user)

	--start : démarre tous les conteneurs (start) et le service docker si celui-ci n'est pas démarré.

	"
fi
# si besoin de configuration du proxy centrale
if [ "$1" == "--proxy" ];then
        
        if [ -f "/etc/systemd/system/docker.service.d/http-proxy.conf" ];then
                echo "Vérifier avant /etc/systemd/system/docker.service.d/http-proxy.conf"
        
        else 
                mkdir /etc/systemd/system/docker.service.d/
                echo "[Service]" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
                echo "Environment=\"HTTP_PROXY=http://pcs.ritac.i2:3128\"" | sudo tee --append /etc/systemd/system/docker.service.d/http-proxy.conf
                sudo service docker restart
        fi 

fi



# création de debian seules
if [ "$1" == "--create-debian" ];then
	
	nbserv=$2
	[ "$nbserv" == "" ] && nbserv=2
	
	# rapatriement de l'image si elle n'exsiste pas
	echo "Installation de l'image "
	docker pull priximmo/stretch-systemd-ssh:v3.1

	# création des conteneurs
	echo "Création : ${nbserv} conteneurs..."

	# détermination de l'id mini
  id_first=$(docker ps -a --format "{{ .Names }}" |grep "oki.*-vmparc" | sed s/".*-vmparc"//g  | sort -nr | head -1)
	id_min=$(($id_first+1))

	#détermination de l'id max
	id_max=$(($nbserv + $id_min - 1))

	for i in $( seq $id_min $id_max );do
		echo ""
		echo "=> conteneur ${USERNAME}-deb-vmparc${i}"
    docker run -tid -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name ${USERNAME}-deb-vmparc${i} priximmo/stretch-systemd-ssh:v3.1
		echo "    => création de l'utilisateur ${USERNAME}"
		docker exec -ti ${USERNAME}-deb-vmparc${i} /bin/bash -c "useradd -m -p sa3tHJ3/KuYvI ${USERNAME}"
		echo "Installation de votre clé publique ${HOME}/.ssh/id_rsa.pub"
		docker exec -ti ${USERNAME}-deb-vmparc${i} /bin/bash -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown ${USERNAME}:${USERNAME} $HOME/.ssh"
		docker cp ${HOME}/.ssh/id_rsa.pub ${USERNAME}-deb-vmparc${i}:${HOME}/.ssh/authorized_keys
		docker exec -ti ${USERNAME}-deb-vmparc${i} /bin/bash -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown ${USERNAME}:${USERNAME} ${HOME}/.ssh/authorized_keys"
		docker exec -ti ${USERNAME}-deb-vmparc${i} /bin/bash -c "echo '${USERNAME}   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti ${USERNAME}-deb-vmparc${i} /bin/bash -c "service ssh start"
	done

fi


if [ "$1" == "--create-centos" ];then
	
	nbserv=$2
	[ "$nbserv" == "" ] && nbserv=2
	
	# rapatriement de l'image si elle n'exsiste pas
	echo "Installation de l'image "
	docker pull priximmo/centos7-systemctl-ssh:v1.1	

	# création des conteneurs
	echo "Création : ${nbserv} conteneurs..."

	# détermination de l'id mini
  id_first=$(docker ps -a --format "{{ .Names }}" |grep "oki.*-vmparc" | sed s/".*-vmparc"//g  | sort -nr | head -1)
	id_min=$(($id_first+1))

	#détermination de l'id max
	id_max=$(($nbserv + $id_min - 1))

	for i in $( seq $id_min $id_max );do
		echo ""
		echo "=> conteneur ${USERNAME}-centos-vmparc${i}"
    docker run -tid -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN --privileged --name ${USERNAME}-centos-vmparc${i} priximmo/centos7-systemctl-ssh:v1.1
		echo "    => création de l'utilisateur ${USERNAME}"
		docker exec -ti ${USERNAME}-centos-vmparc${i} /bin/bash -c "useradd -m -p sa3tHJ3/KuYvI ${USERNAME}"
		echo "Installation de votre clé publique ${HOME}/.ssh/id_rsa.pub"
		docker exec -ti ${USERNAME}-centos-vmparc${i} /bin/bash -c "mkdir  ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown ${USERNAME}:${USERNAME} $HOME/.ssh"
		docker cp ${HOME}/.ssh/id_rsa.pub ${USERNAME}-centos-vmparc${i}:${HOME}/.ssh/authorized_keys
		docker exec -ti ${USERNAME}-centos-vmparc${i} /bin/bash -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown ${USERNAME}:${USERNAME} ${HOME}/.ssh/authorized_keys"
		docker exec -ti ${USERNAME}-centos-vmparc${i} /bin/bash -c "echo '${USERNAME}   ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
	done

fi

# drop des conteneurs du user

if [ "$1" == "--drop" ];then

	for i in $(docker ps -a --format "{{ .Names }}" |grep "${USERNAME}.*-vmparc" );do
		echo "     --Arrêt de ${i}..."
		docker stop $i
		echo "     --Suppression de ${i}..."
		docker rm $i
		done

fi


# démarrage des conteneur (et de docker si nécessaire).

if [ "$1" == "--start" ];then
	
	sudo /etc/init.d/docker start

	
        for i in $(docker ps -a --format "{{ .Names }}" |grep "${USERNAME}.*-vmparc" );do
                echo "     --Démarrage de ${i}..."
                docker start $i
        done


fi

# récap des infos



echo ""
echo "#### Récap des conteneurs de tests ####"
echo ""

	for i in $(docker ps -a --format "{{ .Names }}" |grep "vmparc" );do
		infos_conteneur=$(docker inspect -f '   => {{.Name}} - {{.NetworkSettings.IPAddress }}' ${i})
		echo "${infos_conteneur} - Utilisteur : ${USERNAME} / mdp:password"
	done
