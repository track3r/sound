/**
 * @author kgar
 * @date  23/12/14
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;

extern class Sound
{
    /** the sound volume goes from 0 to 1 */
    public var volume (default, set): Float;
    /** set it to true if you want the sound to loop */
    public var loop (default, set): Bool;
    /** the callback when the sound is fully loaded and decoded Hopefully :)*/
    public var loadCallback: Sound -> Void;
    /** the sound file URL*/
    public var fileUrl: String;

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

    /** load and decode a given sound*/
    public static function load(fileUrl: String, loadCallback: Sound -> Void): Void;
}
