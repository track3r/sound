/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

    /** set it to true if you want the native player to be used instead of our music.
        default value is true.*/
    public static var allowNativePlayer(default, set): Bool;

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
    public static function load(fileUrl: String, loadCallback: Music -> Void): Void
}
