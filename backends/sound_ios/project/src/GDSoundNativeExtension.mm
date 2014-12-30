#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#import <Foundation/Foundation.h>
#include <hx/CFFI.h>
#import "ObjectAL.h"

value *__soundCompleteCallback = NULL;
NSString *filePath;
//convert value String coming from haxe to NSString
static NSString* valueToNSString(value aHaxeString)
{
    const char *aHaxeChars = val_get_string(aHaxeString);

    NSString *aNSString = [NSString stringWithUTF8String:aHaxeChars];
    return aNSString;
}
///------------------------------------------------------------------------------------------------
static value soundios_registerCallback(value callback)
{
    val_check_function(callback, 1); // Is Func ?

    if(__soundCompleteCallback == NULL)
    {
        __soundCompleteCallback = alloc_root();
    }
    *__soundCompleteCallback = callback;
    return alloc_null();
}
DEFINE_PRIM (soundios_registerCallback, 1);
///--------------------------------------------------------------------
static value soundios_intialize(value soundPath)
{
    NSLog(@"soundios_intialize");
    filePath = valueToNSString(soundPath);

    [OALSimpleAudio sharedInstance].allowIpod = NO;
    
    // Mute all audio if the silent switch is turned on.
    [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    
    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    [[OALSimpleAudio sharedInstance] preloadEffect:filePath];
    return alloc_null();
}
DEFINE_PRIM(soundios_intialize,1);
///--------------------------------------------------------------------
static value soundios_play()
{
    NSLog(@"soundios_play");
    [[OALSimpleAudio sharedInstance] playBg:filePath];
    return alloc_null();
}
DEFINE_PRIM(soundios_play,0);
///--------------------------------------------------------------------
static value soundios_stop()
{
    NSLog(@"soundios_stop");
    [[OALSimpleAudio sharedInstance] stopEverything];
    return alloc_null();
}
DEFINE_PRIM(soundios_stop,0);
///--------------------------------------------------------------------
static value soundios_pause()
{
    NSLog(@"soundios_pause");
    [OALSimpleAudio sharedInstance].paused = ![OALSimpleAudio sharedInstance].paused;
    return alloc_null();
}
DEFINE_PRIM(soundios_pause,0);
///--------------------------------------------------------------------
static value soundios_setLoop(value loop)
{
    NSLog(@"soundios_setLoop");
    return alloc_null();
}
DEFINE_PRIM(soundios_setLoop,1);
///--------------------------------------------------------------------
static value soundios_setVolume(value volume)
{
    NSLog(@"soundios_setVolume");
    return alloc_null();
}
DEFINE_PRIM(soundios_setVolume,1);
///--------------------------------------------------------------------
static value soundios_setMute(value mute)
{
    NSLog(@"soundios_setMute");
    return alloc_null();
}
DEFINE_PRIM(soundios_setMute,1);
///--------------------------------------------------------------------

extern "C" int soundios_register_prims () { return 0; }