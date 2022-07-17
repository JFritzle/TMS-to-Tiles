# TMS-to-Tiles
Graphical user interface to download tiles from TMS tile servers  

Tiles are optionally composed to an image without installed map application. A limited number of color-postprossing may be applied to tiles. In addition, tiles can be overlayed with an alpha-transparent hillshading supplied by a local tile server. The corresponding tile server is available at this [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  

An amount of tile servers allow downloading tiles via TMS protocol. A non-exhaustive list can be found at https://wiki.openstreetmap.org/wiki/Tile_servers.
 
### Graphical user interface
This project’s intension is to let the user easily interactively specify the URL of a TMS tile server, manage an archive of TMS servers and to download tiles from selected server. In addition, option settings as well as position and font size of graphical user interface automatically get saved and restored. Tile server gets started/restarted using these options without need to manually set up any configuration files. 

Graphical user interface is a single script written in _Tcl/Tk_ scripting language and is executable on _Microsoft Windows_ and _Linux_ operating system. Language-neutral script file _TMS-to-Tiles.tcl_ requires an additional user settings file and at least one localized resource file. Additional files must follow _Tcl/Tk_ syntax rules too.

User settings file is named _TMS-to-Tiles.ini_. A template file is provided.

Resource files are named _TMS-to-Tiles.<locale\>_, where _<locale\>_ matches locale’s 2 lowercase letters ISO 639-1 code. English localized resource file _TMS-to-Tiles.en_ and German localized resource file _TMS-to-Tiles.de_ are provided. Script can be easily localized to any other system’s locale by providing a corresponding resource file using English resource file as a template. 

Downloaded tiles may optionally be composed to an image. Composition requires package _ImageMagick_ with package’s command line utility _convert_ to be installed. 

Screenshot of graphical user interface: 
![GUI](https://user-images.githubusercontent.com/62614244/179404122-7cfea5fb-8fe2-40bd-9426-7b31971db25d.png)


### Installation

1.	Java runtime environment version 8 or higher   
Windows: If not yet installed, download and install Java, e.g. from [Oracle](https://www.java.com).  
Linux: If not yet installed, install Java runtime package using Linux package manager. (Ubuntu: _apt install openjdk-<version\>-jre_ where _<version\>_ is 8 or higher)

2.	Mapsforge tile server  
Open [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  
For Java version 11 or higher, switch branch to _master_, navigate to folder _mapsforgesrv/bin/jars_ready2use_ and download jar file [_mapsforgesrv-fatjar.jar_](https://github.com/telemaxx/mapsforgesrv/raw/master/mapsforgesrv/bin/jars_ready2use/mapsforgesrv-fatjar.jar).  
For Java version 8 (or higher), switch branch to _Java8_, navigate to folder _mapsforgesrv/bin/jars_ready2use_ and download jar file [_mapsforgesrv4java8.jar_](https://github.com/telemaxx/mapsforgesrv/raw/Java8/mapsforgesrv/bin/jars_ready2use/mapsforgesrv4java8.jar).  
Windows: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Note:  
Currently Mapsforge tile server version 0.17.4 or higher is required. Previous server versions are no longer supported.  

3.	Alternative Marlin rendering engine (optional)  
[Marlin](https://github.com/bourgesl/marlin-renderer) is an open source Java2D rendering engine optimized for performance.  
For Java version 11 or higher, open [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository, switch branch to _master_, navigate to folder _mapsforgesrv/libs_ and download jar file(s) _marlin-*.jar_.  
For Java version 8, open [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository, switch branch to _Java8_, navigate to folder _mapsforgesrv/libs_ and download jar file(s) _marlin-*.jar_.  
Windows: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  

4.	Tcl/Tk scripting language version 8.6 or higher binaries  
Windows: Download and install latest stable version of Tcl/Tk. See https://wiki.tcl-lang.org/page/Binary+Distributions for available binary distributions. Recommended distribution is [teclab’s tcltk](https://github.com/teclab-at/tcltk/releases) repository. First select most recent installation file _tcltk86-8.6.x.y.tcl86.Win10.x86_64.tgz_, then press _Download_ button. Unpack gzipped tar archive (file extension _.tgz_) into your Tcl/Tk installation folder, e.g. _%programfiles%/Tcl_.  
Note 1: [7-Zip](https://www.7-zip.org) file archiver/extractor is able to unpack _.tgz_ archives.   
Note 2: Archives of latest releases for Windows at teclab’s tcltk repository may have file extension _.zip_ while they should have extension _.tgz_. Rename extension to _.tgz_ before unpacking archive.  
Linux: Install packages _tcl, tcllib, tk_, _tklib_ and _tcl-tls_ using Linux package manager. Package _tklib_ is required for tooltips and package _tcl-tls_ is required to connect to servers via HTTPS protocol (Ubuntu: _apt install tcl tcllib tk tklib tcl-tls_)

5. ImageMagick  
Windows: If not yet installed, download and install latest ImageMagick version from [download section](https://imagemagick.org/script/download.php). Enable option "Install legacy utilities" during installation.  
After installation, legacy utility _convert.exe_ is expected to be found in one of folders _C:\Program Files*\ImageMagick*_. An alternative installation path for _convert.exe_ can be specified in the ini file.  
Linux: If not yet installed, install ImageMagick package using Linux package manager. (Ubuntu: _apt install imagemagick_)

6. DEM data (optional, required for hillshading)  
Download and store HGT files with DEM (Digital Elevation Model) data for the regions to be rendered. HGT files with 3 arc seconds resolution are available for example at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm).

7. TMS-to-Tiles graphical user interface  
Download language-neutral script file _TMS-to-Tiles.tcl_, user settings file _TMS-to-Tiles.ini_  and at least one localized resource file.  
Windows: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded files into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Edit _user-defined script variables settings section_ of user settings file _TMS-to-Tiles.ini_ to match files and folders of your local installation of Java and Mapsforge tile server.  
Important:  
Always use slash character “/” as directory separator in script, for Microsoft Windows too!

### Script file execution

Windows:  
Associate file extension _.tcl_ to Tcl/Tk window shell’s binary _wish.exe_. Right-click script file and open file’s properties window. Change data type _.tcl_ to get opened by _Wish application_ e.g. by executable _%programfiles%/Tcl/bin/wish.exe_. Once file extension has been associated, double-click script file to run.

Linux:  
Either run script file from command line by
```
wish <path-to-script>/TMS-to-Tiles.tcl
```
or create a desktop starter file _TMS-to-Tiles.desktop_
```
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=TMS-to-Tiles
Exec=wish <path-to-script>/TMS-to-Tiles.tcl
```
or associate file extension _.tcl_ to Tcl/Tk window shell’s binary _/usr/bin/wish_ and run script file by double-click file in file manager.

                     
### Usage

* After selecting TMS tile server, hillshading and/or color-postprocessing in graphical user interface, hit _Start_ button to start downloading tiles from server and optionally render hillshading tiles. To restart downloading after changing any settings, hit _Start_ button again.
* Hit _Test URL_ button to test connection to TMS tile server using tile values given
* Use keyboard key Del to remove a marked server entry from server archive 
* Use keyboard keys Ctrl-plus to increase and keyboard keys Ctrl-minus to decrease font size of graphical user interface and/or output console.  
* See output console for tile server’s output, download/render statistics, process steps carried out, etc. 

### Example

Screenshot showing result of testing server URL _https://tile.openstreetmap.org/14/8584/5595.png_
![URL_Test](https://user-images.githubusercontent.com/62614244/179404346-69798f73-6165-4a47-913f-3e51a7209b24.png)  

Screenshot showing Heidelberg (Germany) and using
* server URL pattern _https://tile.openstreetmap.org/{z}/{x}/{y}.png_
* hillshading overlay rendered by local Mapsforge tile server
* tile numbers and zoom level as shown above

Upper left half of image was composed as downloaded from server with hillshading disabled,  
lower right half of image was composed with hillshading enabled and settings shown as above.   
 
![Heidelberg](https://user-images.githubusercontent.com/62614244/179404214-e0d64c06-d06e-4bbf-bbd7-1131ffc0a1b5.jpg)                         

### Hints

* Tiles range in x and y directions may be given as tile numbers or as coordinate values. Entered coordinate values are converted into tile numbers according to zoom level set, entered tile numbers are converted into coordinate values according to zoom level set. When changing the zoom level, the input values are retained, the converted values however are recalculated. For correlation between zoom level and corresponding tiles range and for conversion formulas used, see https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames.  
* When hillshading enabled, server tiles and rendered hillshading tiles are first stored separately. Post-processing hillshading, gray value of flat area gets mapped to full transparency, darker gray values get mapped to transparency levels of black, brighter gray values get mapped to transparency levels of white. Thus the flatter the area, the more the original colors of the map shine through. Finally, hillshading as alpha-transparent overlay gets composed with map downloaded from server.  
[OpenTopoMap](https://opentopomap.org) uses this same hillshading technique.  

### Contributors

* @txane: support with many improvements and extensive testing  