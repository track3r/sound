/**
 * @author kgar 
 * @date 06/10/14 
 * @company Gameduell GmbH
 */
package scenes;

import game_engine.extra.AssetManager;
import game_engine.systems.RelationSystem;
import game_engine.systems.Camera2DSystem;
import game_engine.systems.Transform2DSystem;
import game_engine.systems.Sprite2DSystem;
import game_engine.systems.ui.SimpleButtonSystem;
import game_engine.core.SimpleButton;
import renderer.texture.Texture2D;
import game_engine.core.Scene;

import sound.Sound;
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

    private static var playBtn2 : SimpleButton;
    private static var stopBtn2 : SimpleButton;

    //sound
    private var sound: Sound;
    private var sound2: Sound;

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
            if(sound != null)
            {
                sound.play();
            }
        });
        stopBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            if(sound != null)
            {
                sound.stop();
            }
        });

        playBtn2 = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn2.transform.x = 50;
        playBtn2.transform.y = 200;

        stopBtn2 = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn2.transform.x = 250;
        stopBtn2.transform.y = 200;

        root.addChild(playBtn2);
        root.addChild(stopBtn2);

        playBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            if(sound2 != null)
            {
                sound2.play();
            }
        });
        stopBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            if(sound2 != null)
            {
                sound2.stop();
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
        loadSound("shotgun.mp3", "healicopter.mp3");
    }

    private function loadSound(filename: String, filename2: String): Void
    {
        var fileUrl: String = "assets/" + filename;
        var fileUrl2: String = "assets/" + filename2;
        
        Sound.load(fileUrl, function(s:Sound){
            sound = s;
        });
        Sound.load(fileUrl2, function(s:Sound){
            sound2 = s;
        });
    }

}
