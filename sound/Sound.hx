/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal;
import types.Data;
extern class Sound
{
    public var volume(set_volume,default): Int;
    public var loop(set_loop,default): Bool;
    public var length(null,get_length): Float;
    public var position(null,get_position): Float;

    public var onPlaybackComplete(default,null): Signal1;
    public function new(fileUrl: String);
    public function play(): Void;
    public function stop(): Void;
    public function pause(): Void;
    public function mute():Void;
    public static function load(loadCallback: Void -> sound.Sound);
}
