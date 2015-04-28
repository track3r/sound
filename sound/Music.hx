/**
 * @author kgar
 * @date  28/04/15 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import msignal.Signal.Signal1;
extern class Music
{
    public var volume (default, set): Int;
    public var loop (default, set): Bool;
    public var length (get, null): Float;
    public var position (get, null): Float;
    public var loadCallback: Sound -> Void;
    public var fileUrl: String;

    public var onPlaybackComplete (default, null): Signal1;
    private function new(fileUrl: String);
    public function play(): Void;
    public function stop(): Void;
    public function pause(): Void;
    public function mute(): Void;
    public static function load(loadCallback: Void -> Sound);
}
