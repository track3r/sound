/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;

extern class Sound
{
    public var volume (default, set): Int;
    public var loop (default, set): Bool;
    public var loadCallback: Sound -> Void;
    public var fileUrl: String;

    private function new(fileUrl: String);
    public function play(): Void;
    public function stop(): Void;
    public function pause(): Void;
    public function mute(): Void;
    public static function load(loadCallback: Void -> Sound);
}
