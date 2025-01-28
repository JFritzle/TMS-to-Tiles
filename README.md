# TMS-to-Tiles
Graphical user interface to download tiles from TMS tile servers  

Tiles are optionally composed to an image without installed map application. A limited number of color-postprossing may be applied to tiles. In addition, tiles can be overlayed with an alpha-transparent hillshading supplied by a local tile server. The corresponding tile server is available at this [mapsforgesrv](https://github.com/telemaxx/mapsforgesrv) repository.  

While old *single task* server type was capable of rendering only one single set of parameters at a time, the new *multiple tasks* server type is capable of rendering multiple sets of parameters concurrently. Thus, one single *multiple tasks* server instance can replace multiple *single task* server instances.  
**This Graphical user interface only supports the *multiple tasks* server type.**  
Latest GUI supporting *single task* server type is still available in GitHub's [*legacy*](https://github.com/JFritzle/TMS-to-Tiles/tree/legacy) branch.

An amount of tile servers allow downloading tiles via TMS protocol. A non-exhaustive list can be found at https://wiki.openstreetmap.org/wiki/Tile_servers.
 
### Graphical user interface
This project’s intension is to let the user easily interactively specify the URL of a TMS tile server, manage an archive of TMS servers and to download tiles from selected server. In addition, option settings as well as position and font size of graphical user interface automatically get saved and restored. Tile server gets started/restarted using these options without need to manually set up any configuration files. 

Graphical user interface is a single script written in _Tcl/Tk_ scripting language and is executable on _Microsoft Windows_ and _Linux_ operating system. Language-neutral script file _TMS-to-Tiles.tcl_ requires an additional user settings file and at least one localized resource file. Additional files must follow _Tcl/Tk_ syntax rules too.

User settings file is named _TMS-to-Tiles.ini_. A template file is provided.

Resource files are named _TMS-to-Tiles.<locale\>_, where _<locale\>_ matches locale’s 2 lowercase letters ISO 639-1 code. English localized resource file _TMS-to-Tiles.en_ and German localized resource file _TMS-to-Tiles.de_ are provided. Script can be easily localized to any other system’s locale by providing a corresponding resource file using English resource file as a template. 

Downloaded tiles may optionally be composed to an image.  

Screenshot of graphical user interface: 
![GUI_Windows](https://github.com/user-attachments/assets/3b066361-58ac-42d5-9ce8-170d8bca1eb5)


### Installation

1.	Java runtime environment (JRE) or Java development kit (JDK)  
JRE version 11 or higher is required. Each JDK contains JRE as subset.  
Windows: If not yet installed, download and install JRE or JDK, e.g. from [Oracle](https://www.java.com) or [Adoptium](https://adoptium.net/de/temurin/releases).  
Linux: If not yet installed, install JRE or JDK using Linux package manager. (Ubuntu: _apt install openjdk-<version\>-jre_ or _apt install openjdk-<version\>-jdk_ with required or newer _<version\>_)

2.	Mapsforge tile server  
Open [mapsforgesrv releases](https://github.com/telemaxx/mapsforgesrv/releases).  
Download most recently released jar file _mapsforgesrv-fatjar.jar_ from _<release\>\_for\_java11_tasks_ assets.  
Windows: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  
Note:  
New *multiple tasks* server type and server version 0.21.0.0 or higher is required.  
Old *single task* server type and previous server versions are no longer supported.  

3. Alternative Marlin rendering engine (optional, recommended)  
[Marlin](https://github.com/bourgesl/marlin-renderer) is an open source Java2D rendering engine optimized for performance, replacing the standard built into Java. Download is available at [Marlin-renderer releases](https://github.com/bourgesl/marlin-renderer/releases).  
For JRE version 11 or higher, download jar file _marlin-\*.jar_ from latest _Marlin-renderer \<latest version> for JDK11+_ section's assets.  
Windows: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _%programfiles%/MapsforgeSrv_.  
Linux: Copy downloaded jar file(s) into Mapsforge tile server’s installation folder, e.g. into folder _~/MapsforgeSrv_.  

4.	Tcl/Tk scripting language version 8.6 or higher binaries  
Windows: Download and install latest stable version of Tcl/Tk, currently 9.0.1. See https://wiki.tcl-lang.org/page/Binary+Distributions for available binary distributions. Recommended Windows binary distribution is from [teclab’s tcltk](https://gitlab.com/teclabat/tcltk/-/packages) Windows repository. Select most recent installation file _tcltk90-9.0.1.\<number>.Win10.nightly.\<date>.tgz_. Unpack zipped tar archive (file extension _.tgz_) into your Tcl/Tk installation folder, e.g. _%programfiles%/Tcl_.  
Note: [7-Zip](https://www.7-zip.org) file archiver/extractor is able to unpack _.tgz_ archives.  
Linux: Install packages _tcl, tcllib, tcl-thread, tk_ and _tklib_ using Linux package manager. Since Tcl script now uses threads, package _tcl-thread_ is required. In addition, package _tklib_ is required for using tooltips.  (Ubuntu: _apt install tcl tcllib tcl-thread tk tklib_)

5. GraphicsMagick and/or ImageMagick  
At least one installation of either GraphicsMagick or ImageMagick is required!  
Usually GraphicsMagick is faster than ImageMagick, especially with a large number of tiles.  
For performance reasons, Q8 variants of both graphics tools are strongly preferable over Q16 variants. Since Q16 variants internally work with 16-bit color values per pixel, each input file with 8-bit color values per pixel must be internally converted to 16-bit color values before processing, which consumes time, twice as much memory and disk space.  
<br/>GraphicsMagick:  
Windows: If not yet installed, download and install latest GraphicsMagick version from [download section](https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick-binaries).  
After installation, program _gm.exe_ is expected to be found in one of folders _C:\Program Files*\GraphicsMagick*_. An alternative installation path for _gm.exe_ can be specified in the ini file.  
Linux: If not yet installed, install GraphicsMagick package using Linux package manager. (Ubuntu: _apt install graphicsmagick_)  
Note: GraphicsMagick resource limits are hard-coded in Tcl script file, but can be adjusted in section _Set resource limits of GraphicsMagick_ if needed.  
<br/>ImageMagick:  
ImageMagick version 7 or newer is required! Versions older than version 7 do not include program _magick_ required for scripting.  
Windows: If not yet installed, download and install latest ImageMagick version from [download section](https://imagemagick.org/script/download.php).  
After installation, program _magick.exe_ is expected to be found in one of folders _C:\Program Files*\ImageMagick*_. An alternative installation path for _magick.exe_ can be specified in the ini file.  
Linux: If not yet installed, install ImageMagick package using Linux package manager. (Ubuntu: _apt install imagemagick_)  
When Linux package managers do only install versions older than version 7 by default, then [installation from source](https://imagemagick.org/script/install-source.php) may be required. Default is to build Q16 variant. Use _./configure \-\-with-quantum-depth=8_ to build Q8 variant.  
Note: ImageMagick resource limits are hard-coded in Tcl script file, but can be adjusted in section _Set resource limits of ImageMagick_ if needed.  

6. curl   
If not yet available, installation of curl is required!  
Windows: Starting with version 10, a suitable _curl_ is part of Windows and is to be found as _C:\Windows\System32\curl.exe_. If however desired, latest curl version is available at curl's [download section](https://curl.se/download.html). An alternative installation path for _curl.exe_ can be specified in the ini file.  
Linux: If not yet installed, install curl package using Linux package manager. (Ubuntu: _apt install curl_)  

7. DEM data (optional, required for hillshading)  
Download and store DEM (Digital Elevation Model) data for the regions to be rendered.
Notes:  
Either HGT files or ZIP archives containing 1 single equally named HGT file may be supplied.  
Example: ZIP archive N49E008.zip containing 1 single HGT file N49E008.hgt.  
While 1\" (arc second) resolution DEM data have a significantly higher accuracy than 3\" resolution, hillshading assumes significantly much more time. Therefore 3\" resolution usually is better choice.  
    
   \- HGT files with 3\" resolution SRTM (Shuttle Radar Topography Mission) data are available for whole world at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm). Unzip downloaded ZIP files to DEM folder.  
\- HGT files with 1\" resolution DEM data are available for selected regions at [viewfinderpanoramas.org](http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org1.htm). Unzip downloaded ZIP files to DEM folder.  
\- ZIP archives with 3\" and 1\" resolution compiled and resampled by Sonny are available for selected regions at [Sonny's Digital LiDAR Terrain Models of European Countries](https://sonny.4lima.de). LiDAR data where available are more precise than SRTM data. Store downloaded ZIP files to DEM folder.

8. TMS-to-Tiles graphical user interface  
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

* Output console  
While console output of tile server can be informative and helpful to verify what is happening as well as to analyze errors, writing to console costs some performance. Therefore the console should be hidden if not needed. 
* Tiles range in x and y directions may be given as tile numbers or as coordinate values. Entered coordinate values are converted into tile numbers according to zoom level set, entered tile numbers are converted into coordinate values according to zoom level set. When changing the zoom level, the input values are retained, the converted values however are recalculated. For correlation between zoom level and corresponding tiles range and for conversion formulas used, see https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames.  
* When hillshading enabled, server tiles and rendered hillshading tiles are first stored separately. Post-processing hillshading, gray value of flat area gets mapped to full transparency. Thus the flatter the area, the more the original colors of the map shine through. Finally, hillshading as alpha-transparent overlay gets composed with map downloaded from server.  
[OpenTopoMap](https://opentopomap.org) uses same hillshading technique as hillshading algorithm "diffuselight".  

### Contributors

* @txane: support with many improvements and extensive testing  