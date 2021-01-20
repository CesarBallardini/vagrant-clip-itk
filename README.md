# Clip ITK

Compilador de lenguaje Clip, basado en Clipper y de la familia de xBase.


## Instrucciones para compilar y correr clip en VM


```bash
time vagrant up
time vagrant provision --provision-with compila_clip
```

Con `vagrant ssh` se puede ingresar a la VM y trabajar en el entorno clip.



## Instrucciones para instalar clip, desde distro tgz

```bash
# compila clip y genera el tgz
time vagrant up
time vagrant provision --provision-with compila_clip

# obtiene una nueva VM, y le instala los binarios desde el tgz
vagrant destroy -f
time vagrant up
time vagrant provision --provision-with instala_clip
```

La VM tiene ahora solamente clip binarios, stos paara compilar los `.prg`, pero no todo el entorno de desarrollo para compilarel propio  clip.



## Instrucciones de compilación manual

```bash
# Requisitos de clip en Debian 10
sudo apt-get install -y flex bison libc6-dev libncurses5-dev libpth-dev libmariadbclient-dev gcc-multilib libc6-i386 build-essential git 
sudo apt-get install -y libgpm-dev debhelper # para el make deb


git clone https://github.com/CesarBallardini/clip-itk

cd clip-itk
sudo make system
sudo make deb
```


Para verificar que funciona:

```bash
clip -V
```

# Referencias

* https://github.com/estiloinfo/clip-itk el código original utilizado aquí
* https://github.com/CesarBallardini/clip-itk el fork para corregir la creación de .deb
