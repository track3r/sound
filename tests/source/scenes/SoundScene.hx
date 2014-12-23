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


    override public function initScene() : Void
    {
        createTextures();
        createButtons();
        registerSystems();
    }

    private function configureGraphics() : Void
    {
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
        playBtn = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture, "playButton");
        playBtn.transform.x = 50;
        playBtn.transform.y = 50;

        stopBtn = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture, "stopButton");
        stopBtn.transform.x = 250;
        stopBtn.transform.y = 50;

        root.addChild(playBtn);
        root.addChild(stopBtn);
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
        createAndAddSpritesEntities();
        createAndAddButtonsEntities();
    }

    private function createAndAddSpritesEntities()
    {

    }

    private function createAndAddButtonsEntities() : Void
    {

    }
}
