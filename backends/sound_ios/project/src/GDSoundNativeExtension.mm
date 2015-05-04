//
//  Created by Khaled Garbaya a long time ago.
//  Copyright (c) 2014 GameDuell GmbH. All rights reserved.
//
#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#import <Foundation/Foundation.h>
#include <hx/CFFI.h>
#import "ObjectAL.h"
#import "GDSoundNativeExtension.h"

/// sound Effects
value *__soundLoadComplete = NULL;
value *__currentSound = NULL;
NSString *filePath;

/// Background Music
OALAudioTrack* musicTrack;
value *__musicLoadComplete = NULL;

/// AVAudioPlayer Delegate
@implementation GDSoundNativeExtension

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
}

/// Deprecated in IOS8
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{

}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{

}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{

}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{

}

@end
//====================================================================
//
// Utils
//====================================================================

/// convert value String coming from haxe to NSString
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

//====================================================================
//
// Sound Effects
//====================================================================

///-------------------------------------------------------------------
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
static value soundios_initialize(value soundPath, value currentSound)
{
    filePath = valueToNSString(soundPath);

    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    [[OALSimpleAudio sharedInstance] preloadEffect:filePath];

    value hxSoundHandle = createHaxePointerForSoundHandle(filePath);
    
    val_call1(*__soundLoadComplete, hxSoundHandle);
    return alloc_null();
}
DEFINE_PRIM(soundios_intialize,2);
///--------------------------------------------------------------------
static value soundios_setDeviceConfig(value allowIpod, value honorSilentSwitch)
{
    bool _allowIpod = val_bool(allowIpod);
    bool _honorSilentSwitch = val_bool(honorSilentSwitch);

    /// Do we want to keep the ipod music running or not?
    if(_allowIpod)
    {
        [OALAudioSession sharedInstance].allowIpod = YES;
    }
    else
    {
         [OALAudioSession sharedInstance].allowIpod = NO;
    }

     /// Mute all audio if the silent switch is turned on.
    if(_honorSilentSwitch)
    {
        [OALAudioSession sharedInstance].honorSilentSwitch = YES;
    }
    else
    {
        [OALAudioSession sharedInstance].honorSilentSwitch = NO;
    }

    // Deal with interruptions for me!
    [OALAudioSession sharedInstance].handleInterruptions = YES;

}
DEFINE_PRIM(soundios_setDeviceConfig,2);

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
static value soundios_setVolume(value soundSrc, value volume)
{
    getSoundChannelFromHaxePointer(soundSrc).volume = val_float(volume);
    return alloc_null();
}
DEFINE_PRIM(soundios_setVolume,2);

///--------------------------------------------------------------------
static value soundios_setMute(value soundSrc, value mute)
{
    getSoundChannelFromHaxePointer(soundSrc).muted = val_bool(mute);
    return alloc_null();
}
DEFINE_PRIM(soundios_setMute,2);

//====================================================================
//
// Background Music
//====================================================================

static value musicios_initialize(value filePath)
{
    /// convert to NSString
    NSString* musicPath = valueToNSString(filePath);

    /// preload the music file
    [musicTrack preloadFile:musicPath];

    /// music is preloaded and initialized
    val_call0(*__musicLoadComplete);

    return alloc_null();
}
DEFINE_PRIM(musicios_initialize,1);

///--------------------------------------------------------------------

static value musicios_registerCallback(value callback)
{
    val_check_function(callback, 0); // Is Func ?

    if(__musicLoadComplete == NULL)
    {
        __musicLoadComplete = alloc_root();
    }
    *__musicLoadComplete = callback;
    return alloc_null();
}
DEFINE_PRIM (musicios_registerCallback, 1);
///--------------------------------------------------------------------

///--------------------------------------------------------------------
static value musicios_play(value filePath, value loopsCount)
{
    /// convert to NString
    NSString* musicPath = valueToNSString(filePath);
    int loops = (int)val_int(loopsCount);
    musicTrack.delegate = [[GDSoundNativeExtension alloc] init];

    [musicTrack playFile:musicPath loops:loops];
}
DEFINE_PRIM(musicios_play,2);

///--------------------------------------------------------------------
static value musicios_stop()
{
    [musicTrack stop];
    return alloc_null();
}
DEFINE_PRIM(musicios_stop,0);

///--------------------------------------------------------------------
static value musicios_pause(value pause)
{
    musicTrack.paused = (bool)val_bool(pause);
    return alloc_null();
}
DEFINE_PRIM(musicios_pause,1);

///--------------------------------------------------------------------
static value musicios_setLoop(value loop)
{
    return alloc_null();
}
DEFINE_PRIM(musicios_setLoop,1);

///--------------------------------------------------------------------
static value musicios_setVolume(value volume)
{
    musicTrack.volume = val_float(volume);
    return alloc_null();
}
DEFINE_PRIM(musicios_setVolume,1);

///--------------------------------------------------------------------
static value musicios_setMute(value mute)
{
    musicTrack.muted = val_bool(mute);
    return alloc_null();
}
DEFINE_PRIM(musicios_setMute,1);

extern "C" int soundios_register_prims () { return 0; }