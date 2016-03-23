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
 
package createjs.soundjs;

@:native("createjs.FlashAudioPlugin")
extern class FlashAudioPlugin {

	public function new():Void;
	public function create(src:String):SoundInstance;
	public function flashLog(data:String):Void;
	public function getVolume():Float;
	public function handleEvent(method:String):Void;
	public function handlePreloadEvent(flashId:String, method:String):Void;
	public function handleSoundEvent(flashId:String, method:String):Void;
	public function isPreloadStarted(src:String):Bool;
	public static function isSupported():Bool;
	public function preload(src:String, instance:Dynamic):Void;
	public function register(src:String, instances:Float):Dynamic;
	public function registerPreloadInstance(flashId:String, instance:Dynamic):Void;
	public function registerSoundInstance(flashId:String, instance:Dynamic):Void;
	public function removeAllSounds():Void;
	public function removeSound(src:String):Void;
	public function setMute(value:Bool):Bool;
	public function setVolume(value:Float):Bool;
	public function unregisterPreloadInstance(flashId:String):Void;
	public function unregisterSoundInstance(flashId:String, instance:Dynamic):Void;

	public static var BASE_PATH:String;
	public static var buildDate:String;
	public static var capabilities:Dynamic;
	public var flashReady:Bool;
	public var showOutput:Bool;
	public static var version:String;
}
