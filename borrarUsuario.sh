#!/bin/bash
#/*********************************************************************************/
#/*   Creacion de Operadores web con acceso sftp y Sitios para cada Operador Web  */
#/*   Script de ELIMINACION de Usuarios y sitios                                  */
#/*   Configuracion para Apache2 y corriendo en Ubuntu Server 16.04.1             */
#/*********************************************************************************/
#/*   Juan José Rubio Iglesias          05/10/2016      version:0.1               */
#/*********************************************************************************/

#Si encuentra errores no sale del script para forzar el borrado en caso de que quede algo

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

#Eliminamos el usuario
userdel "$USUARIO"
if [ $? -eq 0 ]
then
	echo "Usuario eliminado correctamente"
else
	echo "Error al eliminar el usuario"
#	exit 1
fi

#Eliminamos el home
sudo rm -R $DIR_APACHE$USUARIO
if [ $? -eq 0 ]
then
	echo "Home del usuario eliminado correctamente"
else
	echo "Error al eliminar el directorio del usuario"
#	exit 1
fi

#Deshabilitamos el sitio en apache
a2dissite "$USUARIO.conf"

#Eliminamos la configuracion del sitio 
rm /etc/apache2/sites-available/"$USUARIO".conf


echo "Usuario $USUARIO eliminado correctamente!"
