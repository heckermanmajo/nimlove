# NimLove(2d) WIP!!

## Step 1 Install sdl2 on your system

### Windows
-TODO

### Mac
-TODO

### Linux

#### Install SDL2-Development libraries
Install sdl2 on your system via package manager.

    #install sdl2
    sudo apt install libsdl2-dev libsdl2-2.0-0 -y;

    #install sdl image  - if you want to display images
    sudo apt install libjpeg-dev libwebp-dev libtiff5-dev libsdl2-image-dev libsdl2-image-2.0-0 -y;

    #install sdl mixer  - if you want sound
    sudo apt install libmikmod-dev libfishsound1-dev libsmpeg-dev liboggz2-dev libflac-dev libfluidsynth-dev libsdl2-mixer-dev libsdl2-mixer-2.0-0 -y;

    #install sdl true type fonts - if you want to use text
    sudo apt install libfreetype6-dev libsdl2-ttf-dev libsdl2-ttf-2.0-0 -y;


#### Install nim (simplest: via choosenim)

#### Intstall the sd2 nim wrapper

    nimble install  # install dependencies (sdl2)

Executing this for the first time can take a while.

## Step2: Clone this repo

    git clone https://github.com/heckermanmajo/nimlove

## Step3: Run the examples via nimble

Navigate to the root folder of the project amd run:

    nimble compall

    nimble rall

    nimble r game
    nimble r animation
    nimble r tiles
    nimble r mouse
    nimble r performance    # tells you how what to performance to expect from your system via demo

## Step4: Read and run the meta or proto-Examples and choose your game to work with

NOTE: No PROTO-GAMES ARE THERE YET
- meta-sidescroller with blocks and stuff
- meta-topdown with tiles and stuff
- meta-shooter
- meta-rts
- meta-roundbased
- meta-combination of round and rts based

PROTO:
- more cossachs like 
- side scroller minecraft 
- c&c like
- ee like 
- warband like
- cS-like
- zomboid like

## Core Functionality
- draw
- sound
- input (mouse, keyboard)
- animation

## Modules 

You can use mutiple modules to make your live easier.
- logging 
- tilemap
- ui
- camera
- math/physics

# THIS FILE IS BRAINSTORMING AND NOT REPRESENTATIVE OF THE CURRENT STATE OF THE PROJECT

A super simple 2d framework for beginners and connoisseurs of love2d.


Since this project is especially for beginners, 
the comments also explain the basics of nim-syntax and inner workings
to get started.

With nimlove you get collection of simple game-prototypes to learn from
and mold in the image of your own game.

https://sanderfrenken.github.io/Universal-LPC-Spritesheet-Character-Generator/#?body=Body_color_light&head=Human_male_light

## Examples 
Look into the "examples" folder.
The programms there are greatly documented and show all kinds of interesting use-cases.

## The nimlove code itself should be documented for learning

## nimlove functionality 
draw images
play sounds 
capture input events
ensure 60 fps
print on the screen
add zoom factor
texture-atlas
animations
tiles
pathfinding and chunking

## Modules
-> commands/strategies
-> snapshot module/orm
-> GameObject, with camera
-> Different Views
-> view-port functions
-> Global Game state module
-> simple logger into tmp files
-> resource loaded/utils/manager
-> A gui module that works like imgui
-> a tile module 
-> a animation module 
-> collision utils
-> camera utils 
-> menu utils 
    -> should work with background images and text for the menu