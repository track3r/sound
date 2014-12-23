/**
 * @author kgar 
 * @date 06/10/14 
 * @company Gameduell GmbH
 */
package scenes;

import types.haxeinterop.HaxeOutputInteropStream;
import haxe.io.Bytes;
import types.haxeinterop.HaxeInputInteropStream;
import types.DataOutputStream;
import types.OutputStream;
import flash.media.Sound;
import types.DataInputStream;
import filesystem.FileSystem;
import game_engine.extra.AssetManager;
import game_engine.systems.RelationSystem;
import game_engine.systems.Camera2DSystem;
import game_engine.systems.Transform2DSystem;
import game_engine.systems.Sprite2DSystem;
import game_engine.systems.ui.SimpleButtonSystem;
import game_engine.core.SimpleButton;
import renderer.texture.Texture2D;
import game_engine.core.Scene;

import types.Data;
import format.mp3.Data;
import format.mp3.Tools;
import format.mp3.Reader;
import sound.Sound;
import types.InputStream;
import ash.core.Entity;
class SoundScene extends Scene
{
    private static var ballTexture : Texture2D;

    ///playBtn Textures
    private static var playBtnUpTexture : Texture2D;
    private static var playBtnDownTexture : Texture2D;
    private static var playBtnOverTexture : Texture2D;

    ///stopBtn Textures
    private static var stopBtnUpTexture : Texture2D;
    private static var stopBtnDownTexture : Texture2D;
    private static var stopBtnOverTexture : Texture2D;

    ///buttons
    private static var playBtn : SimpleButton;
    private static var stopBtn : SimpleButton;

    //sound
    private var sound: Sound;

    override public function initScene() : Void
    {
        createTextures();
        createButtons();
        registerSystems();
    }

    private function createTextures() : Void
    {
        ///playBtn textures
        playBtnUpTexture = AssetManager.getTexture2D("playBtn_up.png");
        playBtnDownTexture = AssetManager.getTexture2D("playBtn_down.png");
        playBtnOverTexture = AssetManager.getTexture2D("playBtn_over.png");

        ///playBtn textures
        stopBtnUpTexture = AssetManager.getTexture2D("stopBtn_up.png");
        stopBtnDownTexture = AssetManager.getTexture2D("stopBtn_down.png");
        stopBtnOverTexture = AssetManager.getTexture2D("stopBtn_over.png");
    }

    private function createButtons():Void
    {
        playBtn = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn.transform.x = 50;
        playBtn.transform.y = 50;

        stopBtn = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn.transform.x = 250;
        stopBtn.transform.y = 50;

        root.addChild(playBtn);
        root.addChild(stopBtn);

        playBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            loadSound("shotgun.mp3");
        });
        stopBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            if(sound != null)
            {
                sound.stop();
            }
        });
    }

    private function registerSystems () : Void
    {
        // Object Creation Systems
        root.engine.addSystem(new SimpleButtonSystem(), 0);
        root.engine.addSystem(new Sprite2DSystem(), 1);

        // Processing Systems
        root.engine.addSystem(new Transform2DSystem(), 3);
        root.engine.addSystem(new RelationSystem(), 4);
        root.engine.addSystem(new Camera2DSystem(), 5);
    }

    override public function sceneWillAppear() : Void
    {
        createButtons();
    }

    private function loadSound(filename: String): Void
    {
        var fileUrl: String = FileSystem.instance().urlToStaticData() + "/" + filename;
        var fileExtension: String = fileUrl.split(".").pop().toLowerCase();

        if(fileExtension != "mp3")
        {
            throw "other formats are suported for now";
        }

        var reader: filesystem.FileReader = FileSystem.instance().getFileReader(fileUrl);
        if (reader == null)
        {
            throw "Couldnt find file for fileUrl" + fileUrl;
        }

        var fileSize = FileSystem.instance().getFileSize(fileUrl);
        var data = new Data(fileSize);
        reader.readIntoData(data);
//        var inputStream = new DataInputStream(data);
//
//        var haxeInput: HaxeInputInteropStream = new HaxeInputInteropStream(inputStream);
//        var mp3Reader = new format.mp3.Reader(haxeInput);
//        var mp3 = mp3Reader.read();
//        var dataStream  = new DataOutputStream(data);
//        var bytesStream = new HaxeOutputInteropStream(dataStream);
//
//        var mp3Writer: format.mp3.Writer =  new format.mp3.Writer(bytesStream);
//        mp3Writer.write(mp3,true);

        sound = new Sound(data);
        sound.play();
    }

}
