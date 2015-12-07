/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;
import filesystem.FileSystem;
import types.Data;
import msignal.Signal.Signal1;
enum MusicState
{
    STOPPED;
    PLAYING;
    PAUSED;
}
/**
 * @author kgar
 */
class Music
{
    public var volume(default,set_volume): Float;
    public var loop(default,set_loop): Bool;
    public var length(get_length,null): Float;
    public var position(get_position,null): Float;
    public var onPlaybackComplete(default,null): Signal1<sound.Music>;
    public var loadCallback: sound.Music -> Void;
    public var fileUrl: String;

    private function new()
    {
        loop = false;
        volume = 1.0;

        onPlaybackComplete = new Signal1();
    }

    public static function load(fileUrl: String,loadCallback: sound.Music -> Void): Void
    {
        var music: Music = new Music();
        music.loadCallback = loadCallback;
        music.fileUrl = fileUrl;
        music.loadSoundFile();
    }

    public function loadSoundFile(): Void
    {
        if (this.loadCallback != null)
        {
            this.loadCallback(this);
        }
    }

    public function play(): Void
    {
    }

    public function stop(): Void
    {
    }

    public function pause(): Void
    {
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
    }

    /**
    * Get the current sound length (in milliseconds)
    */
    public function get_length(): Float
    {
        return 0.0;
    }

    /**
    * Get the current sound delayed time (in milliseconds)
    */
    public function get_position(): Float
    {
        return 0.0;
    }
    /**
    * Set the current sound volume
    * @param value Float range 0..1
    */
    public function set_volume(value: Float): Float
    {
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
}
