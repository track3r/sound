#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#import <Foundation/Foundation.h>
#include <hx/CFFI.h>
#import "ObjectAL.h"

value *__soundLoadComplete = NULL;
value *__currentSound = NULL;
NSString *filePath;
//convert value String coming from haxe to NSString
static NSString* valueToNSString(value aHaxeString)
{
    const char *aHaxeChars = val_get_string(aHaxeString);

    NSString *aNSString = [NSString stringWithUTF8String:aHaxeChars];
    return aNSString;
}

DEFINE_KIND(k_SoundFileHadle);
static void soundFinalizer(value abstract_object)
{ 
     NSString* s = (NSString *)val_data(abstract_object);
     [s release];
} 
static value createHaxePointerForSoundHandle(NSString *soundFilePath)
{
    [soundFilePath retain];

    value v;
    v = alloc_abstract(k_SoundFileHadle, soundFilePath);
    val_gc(v, (hxFinalizer) &soundFinalizer);
    return v;
}


static NSString* getSoundFileHandleFromHaxePiinter(value soundPath)
{
    return (NSString *)val_data(soundPath);
}
DEFINE_KIND(k_SoundChannelHandle);
static void soundChannelFinalizer(value abstract_object)
{ 
     id<ALSoundSource> s = (id<ALSoundSource>)val_data(abstract_object);
     [s release];
} 

static value createHaxePointerForSoundChannelHandle(id<ALSoundSource> soundChannel)
{
    [soundChannel retain];

    value v;
    v = alloc_abstract(k_SoundChannelHandle, soundChannel);
    val_gc(v, (hxFinalizer) &soundChannelFinalizer);
    return v;
}


static id<ALSoundSource> getSoundChannelFromHaxePointer(value soundChannel)
{
    return (id<ALSoundSource>)val_data(soundChannel);
}
///------------------------------------------------------------------------------------------------
static value soundios_registerCallback(value callback)
{
    val_check_function(callback, 1); // Is Func ?

    if(__soundLoadComplete == NULL)
    {
        __soundLoadComplete = alloc_root();
    }
    *__soundLoadComplete = callback;
    return alloc_null();
}
DEFINE_PRIM (soundios_registerCallback, 1);
///--------------------------------------------------------------------
static value soundios_intialize(value soundPath, value currentSound)
{
    filePath = valueToNSString(soundPath);

    [OALSimpleAudio sharedInstance].allowIpod = NO;
    
    // Mute all audio if the silent switch is turned on.
    [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    
    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    [[OALSimpleAudio sharedInstance] preloadEffect:filePath];

    value hxSoundHandle = createHaxePointerForSoundHandle(filePath);
    
    val_call1(*__soundLoadComplete, hxSoundHandle);
    return alloc_null();
}
DEFINE_PRIM(soundios_intialize,2);
///--------------------------------------------------------------------
static value soundios_play(value filePath)
{
    id<ALSoundSource> soundSrc = [[OALSimpleAudio sharedInstance] playEffect:(NSString*)val_data(filePath)];
    
    return createHaxePointerForSoundChannelHandle(soundSrc);
}
DEFINE_PRIM(soundios_play,1);
///--------------------------------------------------------------------
static value soundios_stop(value soundSrc)
{
    if (soundSrc != alloc_null())
    {
        [getSoundChannelFromHaxePointer(soundSrc) stop];
    }
    return alloc_null();
}
DEFINE_PRIM(soundios_stop,1);
///--------------------------------------------------------------------
static value soundios_pause(value soundSrc, value pause)
{
    [OALSimpleAudio sharedInstance].paused = ![OALSimpleAudio sharedInstance].paused;
    if (soundSrc != alloc_null())
    {
        getSoundChannelFromHaxePointer(soundSrc).paused = val_bool(pause);
    }

    return alloc_null();
}
DEFINE_PRIM(soundios_pause,2);
///--------------------------------------------------------------------
static value soundios_setLoop(value filePath, value loop)
{
    return alloc_null();
}
DEFINE_PRIM(soundios_setLoop,2);
///--------------------------------------------------------------------
static value soundios_setVolume(value filePath, value volume)
{
    return alloc_null();
}
DEFINE_PRIM(soundios_setVolume,2);
///--------------------------------------------------------------------
static value soundios_setMute(value filePath, value mute)
{
    return alloc_null();
}
DEFINE_PRIM(soundios_setMute,2);
///--------------------------------------------------------------------


extern "C" int soundios_register_prims () { return 0; }