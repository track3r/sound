/**
 * @author kgar 
 * @date 06/10/14 
 * @company Gameduell GmbH
 */
package scenes;

import sound.Music;
import filesystem.FileSystem;
import game_engine.extra.AssetManager;
import game_engine.systems.RelationSystem;
import game_engine.systems.Camera2DSystem;
import game_engine.systems.Transform2DSystem;
import game_engine.systems.Sprite2DSystem;
import game_engine.systems.ui.SimpleButtonSystem;
import game_engine_extensions.dragging.components.DragComponent;
import game_engine_extensions.dragging.systems.DragSystem;
import game_engine.core.SimpleButton;
import renderer.texture.Texture2D;
import game_engine.core.Scene;
import game_engine.core.Sprite;

import sound.Sound;
import ash.core.Entity;
import game_engine_extensions.dragging.components.DragComponent;

class SoundScene extends Scene
{
    private static var ballTexture: Texture2D;
    private static var voleumeButtonTexture: Texture2D;

    ///playBtn Textures
    private static var playBtnUpTexture: Texture2D;
    private static var playBtnDownTexture: Texture2D;
    private static var playBtnOverTexture: Texture2D;

    ///stopBtn Textures
    private static var stopBtnUpTexture: Texture2D;
    private static var stopBtnDownTexture: Texture2D;
    private static var stopBtnOverTexture: Texture2D;

    ///pauseBtn Textures
    private static var pauseBtnUpTexture: Texture2D;
    private static var pauseBtnDownTexture: Texture2D;
    private static var pauseBtnOverTexture: Texture2D;

    ///buttons
    private static var playBtn: SimpleButton;
    private static var stopBtn: SimpleButton;
    private static var pauseBtn: SimpleButton;

    private static var playBtn2: SimpleButton;
    private static var stopBtn2: SimpleButton;
    private static var pauseBtn2: SimpleButton;

    private static var volumeBtn: SimpleButton;

    //sound
    private var soundTrack: Sound;
    private var music: Music;

    override public function initScene(): Void
    {
        createTextures();
        registerSystems();
    }

    private function createTextures(): Void
    {
        ///playBtn textures
        playBtnUpTexture = AssetManager.getTexture2D("playBtn_up.png");
        playBtnDownTexture = AssetManager.getTexture2D("playBtn_down.png");
        playBtnOverTexture = AssetManager.getTexture2D("playBtn_over.png");

        ///stopBtn textures
        stopBtnUpTexture = AssetManager.getTexture2D("stopBtn_up.png");
        stopBtnDownTexture = AssetManager.getTexture2D("stopBtn_down.png");
        stopBtnOverTexture = AssetManager.getTexture2D("stopBtn_over.png");


        ///pauseBtn textures
        pauseBtnUpTexture = AssetManager.getTexture2D("pauseBtn_up.png");
        pauseBtnDownTexture = AssetManager.getTexture2D("pauseBtn_down.png");
        pauseBtnOverTexture = AssetManager.getTexture2D("pauseBtn_over.png");

        voleumeButtonTexture = AssetManager.getTexture2D("volume.png");
    }

    private function createButtons(): Void
    {
        playBtn = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn.transform.x = 50;
        playBtn.transform.y = 50;

        stopBtn = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn.transform.x = 355;
        stopBtn.transform.y = 50;

        pauseBtn = new SimpleButton(pauseBtnUpTexture, pauseBtnOverTexture, pauseBtnDownTexture);
        pauseBtn.transform.x = 255;
        pauseBtn.transform.y = 40;

        root.addChild(playBtn);
        root.addChild(stopBtn);
        root.addChild(pauseBtn);

        playBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            if (soundTrack != null)
            {
                soundTrack.loop = true;
                soundTrack.play();
            }
        });

        stopBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            if (soundTrack != null)
            {
                soundTrack.stop();
            }
        });
        pauseBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            if (soundTrack != null)
            {
                soundTrack.pause();
            }
        });

        playBtn2 = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn2.transform.x = 50;
        playBtn2.transform.y = 200;

        stopBtn2 = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn2.transform.x = 355;
        stopBtn2.transform.y = 200;

        pauseBtn2 = new SimpleButton(pauseBtnUpTexture, pauseBtnOverTexture, pauseBtnDownTexture);
        pauseBtn2.transform.x = 255;
        pauseBtn2.transform.y = 190;

        root.addChild(playBtn2);
        root.addChild(stopBtn2);
        root.addChild(pauseBtn2);

        playBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            if (music != null)
            {
                music.loop = true;
                music.play();
            }
        });
        stopBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            if (music != null)
            {
                music.stop();
            }
        });
        pauseBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            if (music != null)
            {
                music.pause();
            }
        });


        volumeBtn = new SimpleButton(voleumeButtonTexture, voleumeButtonTexture, voleumeButtonTexture);
        volumeBtn.transform.x = 600;
        volumeBtn.transform.y = 150;
        root.addChild(volumeBtn);

        var dragComponent:DragComponent = new DragComponent();
        volumeBtn.add(dragComponent);

        dragComponent.onDrag.add(function(deltaX: Float, deltaY: Float)
        {
            var newY = Math.round(volumeBtn.transform.y + deltaY);
            if(newY>99 && newY<201 )
            {
                var volumeIncrement = deltaY/100;
                volumeBtn.transform.y = newY;
                music.volume = music.volume + volumeIncrement;
                trace("Volume is: " + music.volume);
            }
        });
    }

    private function registerSystems(): Void
    {
        // Object Creation Systems
        root.engine.addSystem(new SimpleButtonSystem(), 0);
        root.engine.addSystem(new Sprite2DSystem(), 1);

        // Processing Systems
        root.engine.addSystem(new DragSystem(), 3);
        root.engine.addSystem(new Transform2DSystem(), 4);
        root.engine.addSystem(new RelationSystem(), 5);
        root.engine.addSystem(new Camera2DSystem(), 6);
    }

    override public function sceneWillAppear(): Void
    {
        createButtons();
        loadSound("shotgun.mp3", "helicopter.mp3");
    }

    private function loadSound(filename: String, filename2: String): Void
    {
        var fileUrl: String = FileSystem.instance().urlToStaticData() + "/" + filename;
        var fileUrl2: String = FileSystem.instance().urlToStaticData() + "/" + filename2;
        
        Music.load(fileUrl2, function(m: Music)
        {
            trace("Music Loaded");
            music = m;
        });
        Sound.load(fileUrl, function(s: sound.Sound)
        {
            trace("Sound Loaded");
            soundTrack = s;
        });

    }

}
