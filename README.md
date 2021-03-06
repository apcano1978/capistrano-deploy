# 1.  CONFIGURACIÓN / CONFIGURATION

El archivo de configuración debería permanecer solo en las máquinas de desarrollo, es mejor no subirlo al repositorio dado que incluye información sensible. Este archivo `deploy-secrets.yml` debe ubicarse en `/config`

*Config file should stay only in development machines, it is better not uploading it to server due to the sentitive information inside it. This file `deploy-secrets.yml` should be placed in `/config`*

Ejemplo de estructura de archivo deploy\-secrets.yml / *Structure sample for config file deploy\-secrets.yml*

```yml
staging:
  application: "appname"
  repo_url: "git@github.com:my-github-account/my-project-name.git"
  deploy_to: "/home/web/apps/appname"
  ssh_port: 22
  server: "94.23.6.32"
  server_name: "mydomain.com"
  db_server: "localhost"
  user: "web"
  db_user: "database_name"
  db_user: "mysql_user"
  db_password: "mysql_password"
```

Los datos que debe contener cada una de las variables son los siguientes: / *Data associated to each variable:*

* `application`: nombre asignado a la aplicación / *Application name*
* `repo_url`: ssh git donde esté versionado el proyecto / *ssh to git project repo*
* `deploy_to`: ruta física en el servidor donde está alojado el proyecto y donde van apareciendo los diferentes deploys / *path in server where project is going to be stored and deploys with place it*
* `ssh_port`: numero de puerto de escucha ssh del servidor / *ssh port in the server*
* `server`: IP física accesible desde internet del servidor que aloja la aplicación / *server IP*
* `server_name`: nombre asociado a esa IP por DNS / *server DNS*
* `db_server`: ip donde esta alojada la base de datos mysql del proyecto / *database server ip*
* `user`: usuario que utilizamos para conectadnos por ssh, normalmente **web** / *user we use to connect via ssh, usually* **web** 
* `db_user`: usuario de conexión mysql / *mysql user*
* `db_password`: contraseña del usuario de mysql / *mysql password*

# 2.  DESPLIEGUE / DEPLOYMENT

Una vez establecidos los valores correctos de configuración, desde una máquina de desarrollo, deberemos ejecutar, desde el directorio raíz de la aplicación el comando:

*Once configured this file, from a development machine, we must run from from proyect path:*

```yml
cap staging|production deploy:setup_config
```

Donde staging|production será el entorno que queramos desplegar (solo uno al mismo tiempo). LA ejecución de este comando lleva a cabo las siguientes acciones:

* Crea la ubicación física en el servidor de destino de la estructura de ficheros necesario.

* Crea un site de nginx para servir el proyecto

* Crea los ficheros de configuración de la aplicación necesarios (incluyendo el fichero database.yml con los parámetros de conexión a la base de datos.)

* Crea el script de arranque del servidor de aplicaciones unicorn

*staging|production is the environment we want to deploy to. This command perform the following actions:*

* *Creates path to the project in the server with necessary files and folders*

* *Creates a Nginx server to serve the project*

* *Creates app needed config files (including database.yml with connection to database, you must make sure that the connection parameters in the server are ok)*

* *Creates unicorn start script in the server for the app* 

Si la ejecución del comando se ha ha realizado correctamente, **no debe volver a ajecutarse durante el ciclo de vida del proyecto en dicha máquina.**

*If the command runs correctly* **you should not run it again during project lifetime on that server**

Una de las tareas que la versión 3 de Capistrano no ejecuta es la creación de la base de datos, por lo que debe crearse a mano sobre el servidor mysql y validar que los datos de conexión incluídos en el fichero database.yml son correctos.

*Database creation is not made by capistrano, you should create it and make sure that connection data in database.yml file is correct*

En este punto ya podemos ejecutar el comando de despliegue como tal:

*Now you can run the deployment command*

```yml
cap staging|production deploy
```

La primera ejecución realiza las migraciones de base de datos, bundle install y precompilado de assets por lo que puede tardar un rato en completarse. Una vez finalizada la ejecución sin errores el proyecto debería ser visible (siempre que haya resolución DNS) en la url asignada.

*First run performs databae migrations, bundle install for the gems and assets precompile so it can take some time to complete. Once finished without errors the project should be visible*

# 3.  OBSERVACIONES / NOTES

Para evitar meter la contraseña cada vez que se hace un deploy usando al usuario "web", se recomienda, en la carpeta .ssh del usuario "user" del servidor en el archivo authorized\_keys meter la clave publica del equipo desde el que se hace el deploy.

*To avoid entering the password every time we make a deployment using **web** user it is recommended including rsa public key into .ssh folder in authorized\_keys file*

En el servidor de git hay que incluir la clave publica del usuario "web" para que dicho servidor de git nos deje accede al repositorio.

*In the git service we are using we must include rsa public key for **web** user in order the service allows the deployment accessing the repository*
