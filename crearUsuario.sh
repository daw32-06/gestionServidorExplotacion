#!/bin/bash
#/*********************************************************************************/
#/*   Creacion de Operadores web con acceso sftp y Sitios para cada Operador Web  */
#/*   Script de Creacion de Usuarios y sitios                                     */
#/*   Configuracion para Apache2 y corriendo en Ubuntu Server 16.04.1             */
#/*********************************************************************************/
#/*   Juan José Rubio Iglesias          05/10/2016      version:0.1               */
#/*********************************************************************************/



#Comprobamos que se ejecuta con permisos de root
user=$(whoami)
if [ "$user" != "root" ]; then
    echo "Necesitas tener permisos de root :("
    exit 1
fi

#Creamos las variables
    #DIR_APACHE es el directorio donde estaran todos los home de los usuarios
    #GRUPO_SFTP sera el grupo deberemos tener creado
DIR_APACHE="/var/www/usuarios/"
GRUPO_SFTP="sftpusers"
DOMINIO="tallernt.local"

#Comprobamos que el grupo de usuarios existe

    #Con esta linea mostramos el fichero /etc/group si no muestra ninguna linea el codigo de error es 1
more /etc/group | grep "$GRUPO_SFTP" > /dev/null

if [ $? != 0 ]; then
    echo "Error!, el grupo $GRUPO_SFTP no existe"
    exit 0
fi 

#Comprobamos que el directorio de usuarios existe
if [ ! -d "$DIR_APACHE" ]; then
    echo "Error!, el directorio de usuarios no existe"
    exit 0
fi


#Pedimos el nombre de usuario hasta que se introduza un nombre
while  [ "$USUARIO" == "" ]
do
	echo "Introduzca el nombre de usuario: "
	read USUARIO
done


#Creamos el usuario 
useradd -g sftpusers -d "$DIR_APACHE$USUARIO" "$USUARIO"

if [ $? -eq 0 ]
then
	echo "Usuario creado correctamente"
else
	echo "Error al crear el usuario"
	exit 1
fi

#Creamos el home del usuario
mkdir "$DIR_APACHE$USUARIO"


#Le asignamos una contraseña
passwd "$USUARIO"


#Necesario para el chroot
chown root:root "$DIR_APACHE$USUARIO"

#Creamos el directorio de apache 
mkdir "$DIR_APACHE$USUARIO/www"


#Asignamos permisos al directorio www
chmod -c 775 "$DIR_APACHE$USUARIO/www"
chgrp "$GRUPO_SFTP" "$DIR_APACHE$USUARIO/www"


#Vamos con apache

#Creamos el sitio 
printf  "%s\n"\
        "<VirtualHost *:80>"\
        "       ServerName $USUARIO.$DOMINIO"\
        "       ServerAdmin webmaster@localhost"\
        "       DocumentRoot $DIR_APACHE$USUARIO/www/"\
        "       DirectoryIndex index.htm index.html index.php index.jsp"\
        "</VirtualHost>"\
 	>/etc/apache2/sites-available/"$USUARIO".conf

#Habilitamos el sitio
a2ensite "$USUARIO.conf"

#Reiniciamos apache
/etc/init.d/apache2 restart

echo "Sitio creado para el dominio http://$USUARIO.$DOMINIO"
