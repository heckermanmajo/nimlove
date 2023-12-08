dont execute the game logic for all game objects all frames.
-> split them up into chunks of game-object / 10 or gameObjets /60

Prefer frame time over FPS

You want to measure and judge your performance based on the frame time not FPS. Because the relation between the two is
not linear. Going from 20 FPS to 30 FPS needs about 16.7 ms worth of optimization. That is the same amount of performance
 gain in optimization it takes to get from 30 FPS to 60 FPS. So if you judge performance based on FPS you would come to
 conclusion that a particular "optimization" that increased the FPS from 30 to 60 is better that the one that made a 20
 FPS scene run 31 FPS. while the latter is actually a better optimization.

Batch your draws

If you pack all your textures into one and store each individual image's coordinates, you can use the same texture to
draw many of your objects. This is limited by the size and number of your textures and also the maximum texture size
 supported in your environment. In my experiences 4096x4096 is safe but I prefer to use 2048x2048 "texture atlases".
 There are many utility programs to make such textures. You can easily find a suitable one by doing a Google search.

In this setup in addition to a SDL texture, each sprite also has the x, y, width and height of the region in the "big"
 texture containing the particular image needed. You can make a TextureRegion class. Each sprite then has a TextureRegion.
  This whole process is often referred to as batching. Look it up. The whole idea is to minimize state changes. I am not
  sure if it applies to software rendering or to all of SDL2 backends.

Cache your transformations

Batching your sprites will increase the performance in the GPU side. The CPU bound code is another optimization opportunity.
 Instead of calculating the parameters of SDL_RenderCopy in each frame, calculate them once and cache them. Then when the
 position/rotation of the camera or object changes, recalculate the cache. You can do this in "accessors" of your entity
 class (like setPosition, setRotaion, etc..). Note that instead of directly recalculating transform as soon as a position
  or rotation changes your want to flag the object as "dirty" and check for the dirty flag in the your render function.
  if this->isDirty Then recalculate and cache the transform. This prevents redundant calculations when you do this:

//if dirty flag is not used each of the following function calls
//would have resulted in a recalculation of transforms. However by
//using the dirty flag they will be calculated only once before
//the rendering of next frame in the render() function.
player->setPostion(start_x,start_y);
player->setRotation(0);
camera->reset();




SDL2 includes built in mechanisms for render batching with how it handles SDL_RenderCopy and SDL_RenderPresent. 
Rendercopy commands are basically "stored" until they're forced or flushed. Flushing generally only occurs when the
renderer is being asked to show its work, such as drawing to the screen or readying pixel access.

So SDL2 is smart enough to handle the hard stuff on the GPU end.

Your focus on the CPU end then is to minimize how many pointer dereferences you make for those SDL_RenderCopy calls.
This means dereferencing the sprite object pointer ONCE and then calling SDL_RenderCopy for every instance that uses that sprite texture.

What I do is store an ID for the texture atlas' that I use. Every texture atlas has a unique ID. My whole list of 
game object render components are stored in linear access in a vector for speed. I sort that vector first by the 
texture ID and THEN by layer. This ensures that I'm rendering everything on the right layer first and foremost and 
then batches together all of the objects that use the same texture on the same layer.

From here, you can RenderCopy as normal using the pointers. This is because your CPU cache is smart enough to know when
it's dealing with a pointer. So your computer dereferences the pointer from the heap, which is slow, and stores it in
the CPU cache. If immediately afterwards it is asked to dereference the same pointer, it knows to just use what's already 
cached, so no slow RAM access operation.


So if you have 10 objects in a row using the same texture, it slowly access' the first one, but uses the cached for the
other 9. Which is a massive improvement.

Alternatively, you can grab an SDL_Texture as a &reference at the beginning of a block of similar objects and RenderCopy
this way without overly relying on the cache to be smart for you, but the benefits of this are likely dubious at best and
you're unlikely to see much performance change at all. But it's here as an option.

Hope this helps understand SDL2's built-in render pipeline somewhat.