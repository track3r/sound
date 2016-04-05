/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#import <Foundation/Foundation.h>
#include <hx/CFFI.h>
#import "ObjectAL.h"
#import "OALAudioTrackNotifications.h"
#include "SoundAppDelegateResponder.h"

static SoundAppDelegateResponder *responder;

//====================================================================
//
// Utils
//====================================================================
///--------------------------------------------------------------------
void soundios_setDeviceConfig()
{
    /// Do we want to keep the ipod music running or not?
    [OALAudioSession sharedInstance].allowIpod = true;

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
    return [NSString stringWithUTF8String:val_get_string(aHaxeString)];
}
//----------------------------------------------------------------------
void unregisterNotification(OALAudioTrack* track)
{
    [[NSNotificationCenter defaultCenter] removeObserver:track];
}
void registerMusicNotification(OALAudioTrack* track, value onStopCallback)
{
    [[NSNotificationCenter defaultCenter]
            addObserverForName:OALAudioTrackFinishedPlayingNotification
                        object:track
                         queue:nil
                    usingBlock:^(NSNotification* notification)
                    {
                        if (!val_is_null(onStopCallback))
                        {
                          val_call0(onStopCallback);
                        }
                        unregisterNotification(track);
                    }];
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
     [s stop];
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

DEFINE_KIND(k_MusicChannelHandle);
static void musicChannelFinalizer(value abstract_object)
{
    OALAudioTrack* musicTrack = (OALAudioTrack*)val_data(abstract_object);
    [musicTrack stop];
    unregisterNotification(musicTrack);
    [musicTrack release];
}

static value createHaxePointerForMusicChannelHandle(OALAudioTrack* musicChannel)
{
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

static value soundios_initialize(value soundPath, value onComplete)
{
    val_check_function(onComplete, 2);

    soundios_setDeviceConfig();
    NSString *filePath = valueToNSString(soundPath);

    // This loads the sound effects into memory so that
    // there's no delay when we tell it to play them.
    ALBuffer* buffer = [[OALSimpleAudio sharedInstance] preloadEffect:filePath];

    value hxSoundHandle = createHaxePointerForSoundHandle(filePath);

    val_call2(onComplete, hxSoundHandle, alloc_float(buffer.duration * 1000));
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

//====================================================================
//
// Background Music
//====================================================================

static value musicios_initialize(value filePath, value onStopCallback)
{
    val_check_function(onStopCallback, 0);

    soundios_setDeviceConfig();
    /// convert to NSString
    NSString* musicPath = valueToNSString(filePath);

    OALAudioTrack* musicTrack = [[OALAudioTrack alloc] init];
    [musicTrack retain];

    value haxePointer = createHaxePointerForMusicChannelHandle(musicTrack);

    /// preload the music file
    [musicTrack preloadFile:musicPath];

    registerMusicNotification(musicTrack, onStopCallback);

    return haxePointer;
}
DEFINE_PRIM(musicios_initialize,2);

///--------------------------------------------------------------------
static value musicios_play(value musicSrc, value volume, value loop)
{
    OALAudioTrack* musicTrack = getMusicChannelFromHaxePointer(musicSrc);

    musicTrack.volume = val_float(volume);
    musicTrack.numberOfLoops = val_bool(loop) ? -1 : 0;
    [musicTrack play];

    return alloc_null();
}
DEFINE_PRIM (musicios_play, 3);

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
    getMusicChannelFromHaxePointer(musicSrc).paused = val_bool(pause);

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
    [OALAudioSession sharedInstance].allowIpod = val_bool(allowNativePlayer);

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

static value musicios_appdelegate_initialize () {

    if(!responder)
    {
        responder = [[SoundAppDelegateResponder alloc] init];
        [responder initialize];
    }
	return alloc_null();
}
DEFINE_PRIM (musicios_appdelegate_initialize, 0);

static value musicios_appdelegate_set_willEnterForegroundCallback (value inCallback) {

    [responder setWillEnterForegroundCallback:inCallback];
	return alloc_null();

}
DEFINE_PRIM (musicios_appdelegate_set_willEnterForegroundCallback, 1);

static value musicios_appdelegate_set_willEnterBackgroundCallback (value inCallback) {

    [responder setWillEnterBackgroundCallback:inCallback];
	return alloc_null();
}
DEFINE_PRIM (musicios_appdelegate_set_willEnterBackgroundCallback, 1);

extern "C" int soundios_register_prims () { return 0; }
