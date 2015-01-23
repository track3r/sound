/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import flash.media.SoundTransform;
import flash.events.Event;
import filesystem.FileSystem;
import msignal.Signal;
import types.Data;
import flash.media.Sound;
import flash.media.SoundChannel;

import filesystem.FileSystem;

enum SoundState
{
    STOPPED;
    PLAYING;
    PAUSED;
}
///=================///
/// Sound flash     ///
///                 ///
///=================///
class Sound
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var onPlaybackComplete(default,null): Signal1<sound.Sound>;
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
        volume = 0.5;

        onPlaybackComplete = new Signal1<sound.Sound>();
    }

    @:access(filesystem.FileSystem)
    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var fileData = FileSystem.instance().getData(fileUrl);

        if (fileData == null)
            throw "sound does not exist: " + fileUrl;

        var sound: Sound = new sound.Sound();
        sound.loadCallback = loadCallback;
        sound.fileUrl = fileUrl;
        sound.fileData = fileData;
        sound.loadSoundFile();
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

        /*
        flashSound.addEventListener(flash.events.Event.COMPLETE, function(event: flash.events.Event)
        {
            if(this.loadCallback != null)
            {
                this.loadCallback(this);
            }
        });

        flashSound.load(new flash.net.URLRequest(fileUrl));
        */
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

    private function playSound():Void
    {
        removeSoundCompleteListener();

        flashSoundChannel = null;

        // if the sound has been paused, currentHead will be > 0
        // in that case the loops will be set to 0 for the first cycle
        // not to loop the cropped sound over and over
        // on SoundComplete will set the loop back if needed
        var loopsCount = 9999;
        if(currentHead>0)
        {
            loopsCount = 0;
        }

        flashSoundChannel = flashSound.play(currentHead, loopsCount);

        addSoundCompleteListener();

        updateVolume(volume);
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

    private function updateVolume(value:Float):Void
    {
        if(flashSoundChannel==null)
        {
            return;
        }

        flashSoundChannel.soundTransform.volume = value;
    }

    /**
    * Called when all requested loops are preformed
    * reset head, dispatch onPlaybackComplete signal, reset sound state
    */
    private function onSoundComplete(event:Event):Void
    {
        updateCurrentHead(0.0);

        onPlaybackComplete.dispatch(this);

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
    public function set_volume(value: Float): Float
    {
        updateVolume(value);
        volume = value;
        return volume;
    }

    /**
    * If set to true the sound will loop as long as
    * stop() or pause is called
    */
    public function set_loop(value: Bool): Bool
    {
        loop = value;
        return loop;
    }

    /**
    * Get the current sound length (in milliseconds)
    */
    public function get_length(): Float
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
    public function get_position(): Float
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
