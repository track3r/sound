/**
 * @author kgar
 * @date  28/04/15 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import flash.events.Event;
import filesystem.FileSystem;
import flash.media.SoundTransform;
import types.Data;
import flash.media.SoundChannel;
import msignal.Signal.Signal1;
enum MusicState
{
    STOPPED;
    PLAYING;
    PAUSED;
}
class Music
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var onPlaybackComplete(default,null): Signal1<sound.Music>;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;

    private var currentHead: Float;
    private var currentState: MusicState;

    private var fileData: Data;
    private var flashSound: flash.media.Sound;
    private var flashSoundChannel: SoundChannel;
    private function new()
    {
        currentHead = 0.0;
        currentState = MusicState.STOPPED;

        loop = false;
        volume = 0.5;

        onPlaybackComplete = new Signal1();
    }

    @:access(filesystem.FileSystem)
    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
    {
        var fileData = FileSystem.instance().getData(fileUrl);

        if (fileData == null)
            throw "sound does not exist: " + fileUrl;

        var music: Music = new Music();
        music.loadCallback = loadCallback;
        music.fileUrl = fileUrl;
        music.fileData = fileData;
        music.loadSoundFile();
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
        updateState(MusicState.PLAYING);
    }

    public function stop(): Void
    {
        updateState(MusicState.STOPPED);
    }

    public function pause(): Void
    {
        updateState(MusicState.PAUSED);
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
        removeMusicCompleteListener();
        flashSoundChannel = null;
        flashSound = null;
    }
    private function updateState(state:MusicState):Void
    {
        if(currentState == state)
        {
            return;
        }

        currentState = state;

        switch(state)
        {
            case MusicState.PAUSED :
                pauseSound();
            case MusicState.PLAYING :
                playSound();
            case MusicState.STOPPED :
                stopSound();
        }
    }

    private function playSound():Void
    {
        removeMusicCompleteListener();

        flashSoundChannel = null;

        // if the sound has been paused, currentHead will be > 0
        // in that case the loops will be set to 0 for the first cycle
        // not to loop the cropped sound over and over
        // on SoundComplete will set the loop back if needed
        var loopsCount = 9999;
        if(currentHead>0 || !loop)
        {
            loopsCount = 0;
        }

        flashSoundChannel = flashSound.play(currentHead, loopsCount);

        addMusicCompleteListener();

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

        var soundTransform:SoundTransform = flashSoundChannel.soundTransform;
        soundTransform.volume = volume;
        flashSoundChannel.soundTransform = soundTransform;
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
    /**
    * Set the current sound volume
    * @param value Float range 0..1
    */
    public function set_volume(value: Float): Float
    {
        volume = value;
        updateVolume();
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
    private function addMusicCompleteListener():Void
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
    private function removeMusicCompleteListener():Void
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
