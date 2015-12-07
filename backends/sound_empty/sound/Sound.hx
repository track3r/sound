/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package sound;

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

    private function new()
    {
        loop = false;
        volume = 1;
    }

    public static function load(fileUrl: String,loadCallback: sound.Sound -> Void): Void
    {
        var soundObj: sound.Sound = new sound.Sound();
        soundObj.loadCallback = loadCallback;
        soundObj.fileUrl = fileUrl;
        soundObj.loadSoundFile();
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
    * Set the current sound volume
    * @param value Float range 0..1
    */
    private function set_volume(value: Float): Float
    {
        volume = value;
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
        return 0.0;
    }

    /**
    * Get the current sound delayed time (in milliseconds)
    */
    private function get_position(): Float
    {
        return 0.0;
    }
}
