# README Dockerfile

El `Dockerfile` multi-stage en la etapa `builder` compila clip-itk y genera un instalador basado en archivos `.tgz`.
En la etapa `runtime` genera una imagen con el compilador de clip-itk, y el entorno de desarrollo necesario para
compilar programas `.prg`.

* Construir la imagen

```bash
# construye la imagen
time docker build -t cesarballardini/clip-itk:latest .

# ejecuta un contenedor desde esa imagen
docker run -it --name devtest --mount type=bind,source="$(pwd)",target=/root/app cesarballardini/clip-itk:latest /bin/bash
docker start devtest 
docker attach  devtest 

docker stop devtest 
docker rm devtest

```



Dentro del contenedor:

```bash
export LANG=es_ES.CP850

cd DIRECTORIO_APLICACION/
make clean
make
./run # el nombre del ejecutable generado para la aplicacion

```

Para limpiar los contenedores e imágenes creados: (¡CUIDADO! borra TODOS los contenedores y TODAS las imágenes)

```bash
docker rm --force $(docker ps -a| awk '/[a-z0-9]/ {print $1}')
docker image rm --force $(docker image ls | awk '/[a-z0-9]/ {print $3}' )

```


# Referencias

* https://hub.docker.com/r/debian/eol imagenes de Debian en End Of Life
* https://wiki.debian.org/es/DebianReleases 

## Bug en `libcurl3-gnutls`

Pase de Lenny a Squeeze para evitar un bug que no me deja clonar repos a través de HTTPS

* https://confluence.atlassian.com/bitbucketserverkb/error-gnutls_handshake-failed-a-tls-warning-alert-has-been-received-779171747.html
* https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=559371#59

FIXME: clonar el repo antes de hacer el `docker build` para no necesitar `git` dentro de la imagen.
