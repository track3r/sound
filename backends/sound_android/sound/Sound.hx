/**
 * @author kgar
 * @date  23/12/14 
 * Copyright (c) 2014 GameDuell GmbH
 */
package sound;
import hxjni.JNI;
import msignal.Signal;

///=================///
/// Sound android   ///
///                 ///
///=================///
class Sound
{
    private static var createNative = JNI.createStaticMethod("org/haxe/duell/sound/Sound", "create",
    "(Lorg/haxe/duell/hxjni/HaxeObject;Ljava/lang/String;)Lorg/haxe/duell/sound/Sound;");
    private static var preloadSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "preloadSound","(Z)V");
    private static var playSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "playSound","()V");
    private static var stopSoundNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "stopSound","()V");
    private static var setVolumeNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "setVolume","(F)V");
    private static var setLoopNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "setLoop","(Z)V");
    private static var getLengthNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "getLength","()F");
    private static var getPositionNative = JNI.createMemberMethod("org/haxe/duell/sound/Sound",
    "getPosition","()F");

    private var javaSound:Dynamic;

    public var volume(default, set): Float;
    public var loop(default, set): Bool;
    public var length(get, never): Float;
    public var position(get, never): Float;

    public var onPlaybackComplete(default, null): Signal1<Sound>;

    public function new(fileUrl: String)
    {
        javaSound = createNative(null, fileUrl);
    }

    public function play(): Void
    {
        playSoundNative(javaSound);
    }

    public function stop(): Void
    {
        stopSoundNative(javaSound);
    }

    public function pause(): Void
    {
        stop();
    }

    public function mute(): Void
    {
        this.volume = 0;
    }

    /// here you can do platform specific logic to set the sound volume
    public function set_volume(value: Float): Float
    {
        volume = Math.max(Math.min(value, 0.0), 1.0);
        setVolumeNative(javaSound, volume);
        return volume;
    }

    /// here you can do platform specific logic to make the sound loop
    public function set_loop(value: Bool): Bool
    {
        loop = value;
        setLoopNative(javaSound, loop);
        return loop;
    }

    /// get the length of the current sound
    public function get_length(): Float
    {
        return getLengthNative(javaSound);
    }

    /// get the current time of the current sound
    public function get_position(): Float
    {
        return getPositionNative(javaSound);
    }

    public function onPlaybackCompleted(): Void
    {
        if (onPlaybackComplete != null)
        {
            onPlaybackComplete.dispatch(this);
        }
    }
}
