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

Gracias Gustavo Courault por mantener la pasión clippera!

# Referencias

* http://itkold.km.pp.ru/english/index.shtml 
  * https://web.archive.org/web/20081221130513/http://www.itk.ru/english/index.shtml gracias Wayback machine
* https://github.com/estiloinfo/clip-itk el código original utilizado aquí
* https://github.com/CesarBallardini/clip-itk el fork para corregir la creación de .deb

* https://es.wikipedia.org/wiki/Compilador_Clip
* https://sourceforge.net/projects/clip-itk/files/
  * clip-itk 2006-11-05
  * clip-prg.32-64 2013-05-21

* http://www.thocp.net/software/languages/clipper.htm
* https://en.wikibooks.org/wiki/Clipper_Tutorial:_a_Guide_to_Open_Source_Clipper(s)

## Otros proyectos similares a Clip

* http://www.harbour-project.org/ Harbour is a cross-platform compiler and is known to compile and run on MS-DOS, Windows (32 & 64), Windows CE, Pocket PC, OS/2, GNU/Linux and Mac OSX. https://en.wikipedia.org/wiki/Harbour_(programming_language) 

* http://www.xharbour.org/ xHarbour is a 100% practically backward compatible Clipper Language compiler and Pre-Processor. xHarbour can be compiled with the most popular C compilers and is available for Windows, Linux, DOS, OS/2, Mac OS X, FreeBSD and including the full source code. If you are not interested in xHarbour's source code or don't want to compile xHarbour by yourself, get the pre-compiled binaries from the download page.

* http://www.fship.com/ FlagShip (privative software)
