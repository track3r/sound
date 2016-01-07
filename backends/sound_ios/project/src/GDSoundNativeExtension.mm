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
#import "OALAudioTrackNotifications.h"

/// sound Effects
value *__soundLoadComplete = NULL;
value *__currentSound = NULL;
NSString *filePath;

/// Background Music
OALAudioTrack* musicTrack;
value *__musicLoadComplete = NULL;
value *__musicStoppedPlaying = NULL;

/// Native player
bool __allowNativePlayer = true;

//====================================================================
//
// Utils
//====================================================================
///--------------------------------------------------------------------
void soundios_setDeviceConfig()
{
    /// Do we want to keep the ipod music running or not?
    [OALAudioSession sharedInstance].allowIpod = __allowNativePlayer;

    /// If YES no other application will be able to start playing audio if it wasn't playing already.
    [OALAudioSession sharedInstance].useHardwareIfAvailable = NO;

    /// If true, mute when backgrounded, screen locked, or the ringer switch is turned off
    [OALAudioSession sharedInstance].honorSilentSwitch = YES;

    // Deal with interruptions for me!
    [OALAudioSession sharedInstance].handleInterruptions = YES;
}

/// convert value String coming from haxe to NSString
static NSString* valueToNSString(value aHaxeString)
{
    const char *aHaxeChars = val_get_string(aHaxeString);

    NSString *aNSString = [NSString stringWithUTF8String:aHaxeChars];
    return aNSString;
}
//----------------------------------------------------------------------
void registerMusicNotification(OALAudioTrack* track, NSString* name)
{
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserverForName:nil
                              object:track
                               queue:nil
                          usingBlock:^(NSNotification* notification){

                                if ([[notification name] isEqualToString:OALAudioTrackStoppedPlayingNotification])
                                {
                                        if(__musicStoppedPlaying != NULL)
                                        {
                                            /// notify the user
                                            val_call1(*__musicStoppedPlaying, alloc_string(name.UTF8String));
                                        }
                                }
                          }];

}
void unregisterNotification(OALAudioTrack* track)
{
    [[NSNotificationCenter defaultCenter] removeObserver:track];
}

/** Creating Sound Haxe Pointer*/
DEFINE_KIND(k_SoundFileHandle);
static void soundFinalizer(value abstract_object)
{
     NSString* s = (NSString *)val_data(abstract_object);
     [s release];
}
static value createHaxePointerForSoundHandle(NSString *soundFilePath)
{
    [soundFilePath retain];

    value v;
    v = alloc_abstract(k_SoundFileHandle, soundFilePath);
    val_gc(v, (hxFinalizer) &soundFinalizer);
    return v;
}

static NSString* getSoundFileHandleFromHaxePointer(value soundPath)
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

/** Creating Music Haxe Pointer*/

DEFINE_KIND(k_MusicFileHandle);
static void musicFinalizer(value abstract_object)
{
     NSString* s = (NSString *)val_data(abstract_object);
     [s release];
}
static value createHaxePointerForMusicHandle(NSString *musicFilePath)
{
    [musicFilePath retain];
    value v;
    v = alloc_abstract(k_MusicFileHandle, musicFilePath);
    val_gc(v, (hxFinalizer) &musicFinalizer);
    return v;
}


static NSString* getMusicFileHandleFromHaxePointer(value musicPath)
{
    return (NSString *)val_data(musicPath);
}
DEFINE_KIND(k_MusicChannelHandle);
static void musicChannelFinalizer(value abstract_object)
{
     OALAudioTrack* musicTrack = (OALAudioTrack*)val_data(abstract_object);
     unregisterNotification(musicTrack);
     [musicTrack release];
}

static value createHaxePointerForMusicChannelHandle(OALAudioTrack* musicChannel)
{
    [musicChannel retain];

    value v;
    v = alloc_abstract(k_MusicChannelHandle, musicChannel);
    val_gc(v, (hxFinalizer) &musicChannelFinalizer);
    return v;
}


static OALAudioTrack* getMusicChannelFromHaxePointer(value musicChannel)
{
    return (OALAudioTrack*)val_data(musicChannel);
}
//====================================================================
//
// Sound Effects
//====================================================================

///-------------------------------------------------------------------
static value soundios_registerCallback(value callback)
{
    val_check_function(callback, 2); // Is Func ?

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
    soundios_setDeviceConfig();
    filePath = valueToNSString(soundPath);

    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    ALBuffer* buffer = [[OALSimpleAudio sharedInstance] preloadEffect:filePath];

    value hxSoundHandle = createHaxePointerForSoundHandle(filePath);

    val_call2(*__soundLoadComplete, hxSoundHandle, alloc_float(buffer.duration * 1000));
    return alloc_null();
}
DEFINE_PRIM(soundios_initialize,2);

///--------------------------------------------------------------------
static value soundios_play(value filePath, value volume, value loop)
{
    id<ALSoundSource> soundSrc = [[OALSimpleAudio sharedInstance]
                                   playEffect:(NSString*)val_data(filePath)
                                   volume:val_float(volume) pitch:1.0f pan:0.0f loop:val_bool(loop)];

    return createHaxePointerForSoundChannelHandle(soundSrc);
}
DEFINE_PRIM(soundios_play,3);

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

///--------------------------------------------------------------------
static value soundios_getPosition(value soundSrc)
{
    return alloc_float(getSoundChannelFromHaxePointer(soundSrc).position.x) ;
}
DEFINE_PRIM(soundios_getPosition,1);
//====================================================================
//
// Background Music
//====================================================================

static value musicios_initialize(value filePath, value currentMusic)
{
    soundios_setDeviceConfig();
    /// convert to NSString
    NSString* musicPath = valueToNSString(filePath);

    musicTrack = [[OALAudioTrack alloc] init];

    /// preload the music file
    [musicTrack preloadFile:musicPath];
    registerMusicNotification(musicTrack, musicPath);

    value hxMusicHandle = createHaxePointerForSoundHandle(musicPath);

    val_call1(*__musicLoadComplete, hxMusicHandle);
    return alloc_null();
}
DEFINE_PRIM(musicios_initialize,1);

///--------------------------------------------------------------------

static value musicios_registerCallback(value loadFinishCallback, value musicFinishPlayingCallback)
{
    val_check_function(loadFinishCallback, 1); // Is Func ?
    val_check_function(musicFinishPlayingCallback, 1); // Is Func ?

    if(__musicLoadComplete == NULL)
    {
        __musicLoadComplete = alloc_root();
    }
    *__musicLoadComplete = loadFinishCallback;

    if(__musicStoppedPlaying == NULL)
    {
        __musicStoppedPlaying = alloc_root();
    }
    *__musicStoppedPlaying = musicFinishPlayingCallback;

    return alloc_null();
}
DEFINE_PRIM (musicios_registerCallback, 2);
///--------------------------------------------------------------------

///--------------------------------------------------------------------
static value musicios_play(value filePath, value volume, value loop)
{
    /// convert to NSString
    NSString* musicPath = valueToNSString(filePath);

    [musicTrack playFile:musicPath loops:val_bool(loop) ? -1 : 0];
    musicTrack.volume = val_float(volume);

    return createHaxePointerForMusicChannelHandle(musicTrack);
}
DEFINE_PRIM(musicios_play,3);

///--------------------------------------------------------------------
static value musicios_stop(value musicSrc)
{
    [getMusicChannelFromHaxePointer(musicSrc) stop];
    return alloc_null();
}
DEFINE_PRIM(musicios_stop,1);

///--------------------------------------------------------------------
static value musicios_pause(value musicSrc, value pause)
{
    getMusicChannelFromHaxePointer(musicSrc).paused = (bool)val_bool(pause);

    return alloc_null();
}
DEFINE_PRIM(musicios_pause,2);

///--------------------------------------------------------------------
static value musicios_setVolume(value musicSrc, value volume)
{
    getMusicChannelFromHaxePointer(musicSrc).volume = val_float(volume);
    return alloc_null();
}
DEFINE_PRIM(musicios_setVolume,2);

///--------------------------------------------------------------------
static value musicios_setMute(value musicSrc, value mute)
{
    getMusicChannelFromHaxePointer(musicSrc).muted = val_bool(mute);
    return alloc_null();
}
DEFINE_PRIM(musicios_setMute,2);

///--------------------------------------------------------------------
static value musicios_setAllowNativePlayer(value allowNativePlayer)
{
    __allowNativePlayer = val_bool(allowNativePlayer);

    [OALAudioSession sharedInstance].allowIpod = __allowNativePlayer;

    return alloc_null();
}
DEFINE_PRIM(musicios_setAllowNativePlayer,1);

///--------------------------------------------------------------------
static value musicios_isOtherAudioPlaying()
{
    return alloc_bool([AVAudioSession sharedInstance].otherAudioPlaying);
}
DEFINE_PRIM(musicios_isOtherAudioPlaying,0);

///--------------------------------------------------------------------
static value musicios_getPosition(value musicSrc)
{
    return alloc_float(getMusicChannelFromHaxePointer(musicSrc).currentTime);
}
DEFINE_PRIM(musicios_getPosition,1);

///--------------------------------------------------------------------
static value musicios_getLength(value musicSrc)
{
    return alloc_float(getMusicChannelFromHaxePointer(musicSrc).duration * 1000);/// in millisecond
}
DEFINE_PRIM(musicios_getLength,1);

extern "C" int soundios_register_prims () { return 0; }
