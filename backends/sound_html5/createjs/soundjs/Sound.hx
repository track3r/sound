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

@:native("createjs.Sound")
extern class Sound
{
	public static function addEventListener(type:String, listener:Dynamic, ?useCapture:Bool):Dynamic;
	public static function dispatchEvent(eventObj:Dynamic, ?target:Dynamic):Bool;
	public static function hasEventListener(type:String):Bool;
	public static function removeAllEventListeners(?type:String):Void;
	public static function removeEventListener(type:String, listener:Dynamic, ?useCapture:Bool):Void;
	
	public static function createInstance(src:String):SoundInstance;
	public static function getCapabilities():Dynamic;
	public static function getCapability(key:String):Dynamic;
	public static function getMute():Bool;
	public static function getVolume():Float;
	public static function initializeDefaultPlugins():Bool;
	public static function isReady():Bool;
	public static function loadComplete(src:String):Bool;
	//public static function mute(value:Bool):Void;
	public static function play(src:String, ?interrupt:String = INTERRUPT_NONE, ?delay:Int = 0, ?offset:Int = 0, ?loop:Int = 0, ?volume:Float = 1, ?pan:Float = 0):SoundInstance;
	public static function registerManifest(manifest:Array<Dynamic>, basepath:String):Dynamic;
	public static function registerPlugin(plugin:Dynamic):Bool;
	public static function registerPlugins(plugins:Array<Dynamic>):Bool;
	public static function registerSound(src:String, ?id:String, ?data:Float, ?preload:Bool = true):Dynamic;

	public static function removeAllSounds():Void;
	public static function removeManifest(manifest:Array<Dynamic>):Dynamic;
	public static function removeSound(src:String):Void;

	public static function setMute(value:Bool):Bool;
	public static function setVolume(value:Float):Void;
	public static function stop():Void;

	public static var activePlugin:Dynamic;
	public static var alternateExtensions:Array<String>;
	//public static var AUDIO_TIMEOUT:Float;
	public static var defaultInterruptBehavior:String;
	public static var DELIMITER:String;
	//public static var EXTENSION_MAP:Dynamic;
	public static inline var INTERRUPT_ANY:String = "any";
	public static inline var INTERRUPT_EARLY:String = "early";
	public static inline var INTERRUPT_LATE:String = "late";
	public static inline var INTERRUPT_NONE:String = "none";
	//public var onLoadComplete:Dynamic->Void;
	public static var PLAY_FAILED:String;
	public static var PLAY_FINISHED:String;
	public static var PLAY_INITED:String;
	public static var PLAY_INTERRUPTED:String;
	public static var PLAY_SUCCEEDED:String;
	public static var SUPPORTED_EXTENSIONS:Array<String>;
}
