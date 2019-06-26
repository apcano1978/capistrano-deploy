# 1.  CAPISTRANO

Todos los proyectos RoR desarrollados internamente incorporan Capistrano 3 como mecanismo de despliegue en los servidores de Staging y Producción. El funcionamiento general del proceso puede consultarse en la documentación de la gema <http://capistranorb.com/>

Para evitar realizar una configuración específica para cada proyecto, se ha creado un repositorio público en Github con la estructura de ficheros utilizada y customizaciones. Salvo raras excepciones, no es necesario realizar cambios sobre el repo y toda la configuración se realiza sobre un único fichero yml de configuración.

<https://github.com/LextrendIT/capistrano-recipe>

# 2.  CONFIGURACIÓN

El archivo de configuración se debe incluir en /config/deploy\_secrets.yml y no debe subirse al repositorio por seguridad. En el repositorio de los proyectos se incluirá un fichero deploy\_secrets.yml.example con la plantilla necesario pero no debería incluir en ningún caso datos reales

Ejemplo de estructura de archivo deploy\-secrets.yml

```yml
staging:
  application: "appname"
  repo_url: "git@bitbucket.org:lextrend/XXXXXX.git"
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

Los datos que debe contener cda una de las variables son los siguientes:

**application**: nombre asignado a la aplicación
**repo\_url**: ssh git donde esté versionado el proyecto.
**deploy\_to**: ruta física en el servidor donde está alojado el proyecto y donde van apareciendo los diferentes deploys
**ssh\_port**: numero de puerto de escucha ssh del servidor
**server**: IP física accesible desde internet del servidor que aloja la aplicación
**server\_name**: nombre asociado a esa IP por DNS
**db\_server**: ip donde esta alojada la base de datos mysql del proyecto
**user**: usuario que utilizamos para conectadnos por ssh, normalmente ‘web’
**db\_user**: usuario de conexión mysql
**db\_password**: contraseña del usuario de mysql 

# 3.  EJECUCIÓN

Una vez establecidos los valores correctos de configuración, desde una máquina de desarrollo, deberemos ejecutar, desde el directorio raíz de la aplicación el comando:

```yml
cap staging|production deploy:setup_config
```

Donde staging|production será el entorno que queramos desplegar (solo uno al mismo tiempo). LA ejecución de este comando lleva a cabo las siguientes acciones:

-   Crea la ubicación física en el servidor de destino de la estructura
    de ficheros necesario.

-   Crea un site de ngingx para servir el proyecto

-   Crea los ficheros de configuración de la aplicación necesarios
    (incluyendo el fichero database.yml con los parámetros de conexión a
    la base de datos.)

-   Crea el script de arranque del servidor de aplicaciones unicorn

Si la ejecución del comando se ha ha realizado correctamente, **no debe volver a ajecutarse durante el ciclo de vida del proyecto en dicha máquina.**

Una de las tareas que la versión 3 de Capistrano no ejecuta es la creación de la base de datos, por lo que debe crearse a mano sobre el servidor mysql y validar que los datos de conexión incluídos en el fichero database.yml son correctos.

En este punto ya podemos ejecutar el comando de despliegue como tal:

```yml
cap staging|production deploy
```

La primera ejecución realiza las migraciones de base de datos, bundle install y precompilado de assets por lo que puede tardar un rato en completarse. Una vez finalizada la ejecución sin errores el proyecto debería ser visible (siempre que haya resolución DNS) en la url asignada.

# 4.  OBSERVACIONES

Para evitar meter la contraseña cada vez que se hace un deploy usando al usuario "web", se recomienda, en la carpeta .ssh del usuario "user" del servidor en el archivo authorized\_keys meter la clave publica del equipo desde el que se hace el deploy.

En el servidor de git hay que incluir la clave publica del usuario "web" para que dicho servidor de git nos deje accede al repositorio.
