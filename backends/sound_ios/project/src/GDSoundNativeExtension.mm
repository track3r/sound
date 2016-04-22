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
#include "SoundAppDelegateResponder.h"

DEFINE_KIND(k_SoundSource);

static SoundAppDelegateResponder *responder;

static NSString* valueToNSString(value aHaxeString)
{
    return [NSString stringWithUTF8String:val_get_string(aHaxeString)];
}

//====================================================================
// Sound Effects
//====================================================================

static value soundios_fx_initialize(value soundPath)
{
    [[OALSimpleAudio sharedInstance] preloadEffect:valueToNSString(soundPath)];
    return alloc_null();
}
DEFINE_PRIM(soundios_fx_initialize, 1);


static value soundios_fx_play(value soundPath, value volume, value loop)
{
    id<ALSoundSource> soundsSource = [[OALSimpleAudio sharedInstance]
            playEffect: valueToNSString(soundPath)
                volume: val_float(volume)
                 pitch: 1.0f
                   pan: 0.0f
                  loop: val_bool(loop)];

    return alloc_abstract(k_SoundSource, soundsSource);
}
DEFINE_PRIM(soundios_fx_play, 3);


static value soundios_fx_stop(value sound)
{
    [(id<ALSoundSource>) val_data(sound) stop];
    return alloc_null();
}
DEFINE_PRIM(soundios_fx_stop, 1);


static value soundios_fx_pause(value sound, value paused)
{
    ((id<ALSoundSource>) val_data(sound)).paused = val_bool(paused);
    return alloc_null();
}
DEFINE_PRIM(soundios_fx_pause, 2);


static value soundios_fx_setVolume(value sound, value volume)
{
    ((id<ALSoundSource>) val_data(sound)).gain = val_float(volume);
    return alloc_null();
}
DEFINE_PRIM(soundios_fx_setVolume, 2);


static value soundios_fx_setMute(value sound, value mute)
{
    ((id<ALSoundSource>) val_data(sound)).muted = val_float(mute);
    return alloc_null();
}
DEFINE_PRIM(soundios_fx_setMute, 2);


//====================================================================
// Background Music
//====================================================================

static value soundios_bgmusic_initialize(value filePath)
{
    [[OALSimpleAudio sharedInstance] preloadBg:valueToNSString(filePath)];
    return alloc_null();
}
DEFINE_PRIM(soundios_bgmusic_initialize, 1);


static value soundios_bgmusic_play(value filePath, value volume, value loop)
{
    [[OALSimpleAudio sharedInstance] playBg: valueToNSString(filePath)
                                     volume: val_float(volume)
                                        pan: 0.0f
                                       loop: val_bool(loop)];

    return alloc_null();
}
DEFINE_PRIM (soundios_bgmusic_play, 3);


static value soundios_bgmusic_stop()
{
    [[OALSimpleAudio sharedInstance] stopBg];
    return alloc_null();
}
DEFINE_PRIM(soundios_bgmusic_stop, 0);


static value soundios_bgmusic_pause(value pause)
{
    [[OALSimpleAudio sharedInstance] setBgPaused:val_bool(pause)];
    return alloc_null();
}
DEFINE_PRIM(soundios_bgmusic_pause, 1);


static value soundios_bgmusic_setVolume(value volume)
{
    [[OALSimpleAudio sharedInstance] setBgVolume:val_float(volume)];
    return alloc_null();
}
DEFINE_PRIM(soundios_bgmusic_setVolume, 1);


static value soundios_bgmusic_setMute(value mute)
{
    [[OALSimpleAudio sharedInstance] setBgMuted:val_bool(mute)];
    return alloc_null();
}
DEFINE_PRIM(soundios_bgmusic_setMute, 1);


static value soundios_bgmusic_getPosition()
{
    return alloc_float([OALSimpleAudio sharedInstance].backgroundTrack.currentTime);
}
DEFINE_PRIM(soundios_bgmusic_getPosition, 0);


static value soundios_bgmusic_getLength()
{
    return alloc_float([OALSimpleAudio sharedInstance].backgroundTrack.duration * 1000);
}
DEFINE_PRIM(soundios_bgmusic_getLength, 0);


//====================================================================
// Setup
//====================================================================

static value soundios_setAllowNativePlayer(value allowNativePlayer)
{
    [OALSimpleAudio sharedInstance].allowIpod = val_bool(allowNativePlayer);
    return alloc_null();
}
DEFINE_PRIM(soundios_setAllowNativePlayer, 1);


static value soundios_isOtherAudioPlaying()
{
    return alloc_bool(((AVAudioSession*)[AVAudioSession sharedInstance]).otherAudioPlaying);
}
DEFINE_PRIM(soundios_isOtherAudioPlaying, 0);


static value soundios_initialize(value onBackground, value onForeground)
{
    [OALSimpleAudio sharedInstance].allowIpod = YES;
    [OALSimpleAudio sharedInstance].useHardwareIfAvailable = NO;
    [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    [OALAudioSession sharedInstance].handleInterruptions = YES;

    if (!responder)
    {
        responder = [[SoundAppDelegateResponder alloc] init];
        [responder initialize];

        [responder setWillEnterBackgroundCallback:onBackground];
        [responder setWillEnterForegroundCallback:onForeground];
    }

	return alloc_null();
}
DEFINE_PRIM (soundios_initialize, 2);

extern "C" int soundios_register_prims () { return 0; }
