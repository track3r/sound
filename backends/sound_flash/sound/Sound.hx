/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;
import flash.media.SoundTransform;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

import filesystem.FileSystem;

import types.Data;

enum SoundState
{
    STOPPED;
    PLAYING;
    PAUSED;
}
/**
 * @author kgar
 */
class Sound
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var loadCallback: sound.Sound -> Void;
    public var fileUrl: String;

    private var currentHead: Float;
    private var currentState: SoundState;

    private var fileData: Data;
    private var flashSound: flash.media.Sound;
    private var flashSoundChannel: SoundChannel;

    private function new()
    {
        currentHead = 0.0;
        currentState = SoundState.STOPPED;

        loop = false;
        volume = 1;
    }

    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var fileData = FileSystem.instance().getData(fileUrl);

        if (fileData == null)
            throw "sound does not exist: " + fileUrl;

        var soundObj: sound.Sound = new sound.Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;
        soundObj.fileData = fileData;
        soundObj.loadSoundFile();
    }

    public function loadSoundFile(): Void
    {
        dispose();

        flashSound = new flash.media.Sound();
        flashSound.loadCompressedDataFromByteArray(fileData.byteArray, fileData.byteArray.length);

        if (this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }

    public function play(): Void
    {
        updateState(SoundState.PLAYING);
    }

    public function stop(): Void
    {
        updateState(SoundState.STOPPED);
    }

    public function pause(): Void
    {
        updateState(SoundState.PAUSED);
    }

    private function updateState(state:SoundState):Void
    {
        if(currentState == state)
        {
            return;
        }

        currentState = state;

        switch(state)
        {
            case SoundState.PAUSED :
                pauseSound();
            case SoundState.PLAYING :
                playSound();
            case SoundState.STOPPED :
                stopSound();
        }
    }

    private function playSound(): Void
    {
        removeSoundCompleteListener();

        flashSoundChannel = null;

        // if the sound has been paused, currentHead will be > 0
        // in that case the loops will be set to 0 for the first cycle
        // not to loop the cropped sound over and over
        // on SoundComplete will set the loop back if needed
        var loopsCount = 9999;
        if(currentHead > 0 || !loop)
        {
            loopsCount = 0;
        }
        addSoundCompleteListener();
        flashSoundChannel = flashSound.play(currentHead, loopsCount);
        updateVolume();
    }

    private function stopSound():Void
    {
        if(flashSoundChannel == null)
        {
            return;
        }
        updateCurrentHead(0.0);
        flashSoundChannel.stop();
    }

    private function pauseSound():Void
    {
        if(flashSoundChannel == null)
        {
            return;
        }

        updateCurrentHead(position);
        flashSoundChannel.stop();
    }

    private function updateCurrentHead(value:Float):Void
    {
        currentHead = value;
    }

    private function updateVolume():Void
    {
        if(flashSoundChannel==null)
        {
            return;
        }

        var soundTransform: SoundTransform = flashSoundChannel.soundTransform;
        soundTransform.volume = volume;
        flashSoundChannel.soundTransform = soundTransform;
    }

    /**
    * Called when all requested loops are preformed
    * reset head, dispatch onPlaybackComplete signal, reset sound state
    */
    private function onSoundComplete(event:Event):Void
    {
        updateCurrentHead(0.0);

        if(loop)
        {
            // if the sound should loop and it triggered the complete event
            // restart the loop
            playSound();
        }
        else
        {
            // the sound should not loop
            //set the state to STOPPED
            stop();
        }
    }

    /**
    * Mute sound
    */
    public function mute(): Void
    {
        volume = 0;
        updateVolume();
    }

    /**
    * Disposes the current sound and sound channel
    */
    public function dispose():Void
    {
        removeSoundCompleteListener();
        flashSoundChannel = null;
        flashSound = null;
    }

    /**
    * Set the current sound volume
    * @param value Float range 0..1
    */
    private function set_volume(value: Float): Float
    {
        volume = value;
        updateVolume();
        return volume;
    }

    /**
    * If set to true the sound will loop as long as
    * stop() or pause is called
    */
    private function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }

    /**
    * Get the current sound length (in milliseconds)
    */
    private function get_length(): Float
    {
        if(flashSound == null)
        {
            return 0.0;
        }

        return flashSound.length;
    }

    /**
    * Get the current sound delayed time (in milliseconds)
    */
    private function get_position(): Float
    {
        if(flashSoundChannel == null)
        {
            return 0.0;
        }

        return flashSoundChannel.position;
    }

    private function addSoundCompleteListener():Void
    {
        if(flashSoundChannel == null)
        {
            return;
        }

        if(!flashSoundChannel.hasEventListener(Event.SOUND_COMPLETE))
        {
            flashSoundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }
    }

    private function removeSoundCompleteListener():Void
    {
        if(flashSoundChannel == null)
        {
            return;
        }

        if(flashSoundChannel.hasEventListener(Event.SOUND_COMPLETE))
        {
            flashSound.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
        }
    }
}
