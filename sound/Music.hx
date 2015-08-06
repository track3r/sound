/**
 * @author kgar
 * @date  28/04/15 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal.Signal1;
extern class Music
{
    /** the sound volume goes from 0 to 1 */
    public var volume (default, set): Float;
    /** set it to true if you want the sound to loop */
    public var loop (default, set): Bool;
    /** get the length of the sound file in millisecond*/
    public var length (get, null): Float;
    /** get the current position of the curent playing sound*/
    public var position (get, null): Float;
    /** the callback when the sound is fully loaded and decoded Hopefully :)*/
    public var loadCallback: Sound -> Void;
    /** the sound file URL*/
    public var fileUrl: String;

    /** dispatches when the music finishes playing or stopped*/
    public var onPlaybackComplete (default, null): Signal1<Music>;

    /** constructor nothing fancy */
    private function new(fileUrl: String);

    /** play the loaded sound and resume if it was paused*/
    public function play(): Void;

    /** stop the sound from playing*/
    public function stop(): Void;
    /** pause the sound*/
    public function pause(): Void;

    /** mute the sound, means volume is 0*/
    public function mute(): Void;

    public static function load(loadCallback: Void -> Sound): Void;
}
