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
 
package scenes;

import duellkit.DuellKit;
import sound.Music;
import filesystem.FileSystem;
import game_engine.extra.AssetManager;
import game_engine.components.text.BMFontTextGenerator;
import game_engine.systems.TextSystem;
import game_engine.systems.RelationSystem;
import game_engine.systems.Camera2DSystem;
import game_engine.systems.Transform2DSystem;
import game_engine.systems.Sprite2DSystem;
import game_engine.components.ui.CheckBoxStateConfig;
import game_engine.systems.ui.CheckBoxSystem;
import game_engine.systems.ui.SimpleButtonSystem;
import game_engine_extensions.dragging.components.DragComponent;
import game_engine_extensions.dragging.systems.DragSystem;
import game_engine.core.CheckBox;
import game_engine.core.Text;
import game_engine.core.SimpleButton;
import renderer.texture.Texture2D;
import game_engine.core.Scene;
import game_engine.core.Sprite;

import sound.Sound;
import game_engine.dust.Entity;
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

    ///nativePlayerBtn Textures
    private static var nativePlayerUpUnCheckedTexture: Texture2D;
    private static var nativePlayerUpCheckedTexture: Texture2D;
    private static var nativePlayerDownUnCheckedTexture: Texture2D;
    private static var nativePlayerDownCheckedTexture: Texture2D;
    private static var nativePlayerDisableUnCheckedTexture: Texture2D;
    private static var nativePlayerDisableCheckedTexture: Texture2D;

    ///buttons
    private static var playBtn: SimpleButton;
    private static var stopBtn: SimpleButton;
    private static var pauseBtn: SimpleButton;

    private static var playBtn2: SimpleButton;
    private static var stopBtn2: SimpleButton;
    private static var pauseBtn2: SimpleButton;

    private static var volumeBtn: SimpleButton;

    ///checkboxes
    private static var nativePlayerCheckBox: CheckBox;

    //sound
    private var soundTrack: Sound;
    private var music: Music;

    override public function initScene(): Void
    {
        createTextures();
        createCheckBox();
        registerSystems();

        DuellKit.instance().onApplicationWillEnterBackground.add(onApplicationWillEnterBackground);
        DuellKit.instance().onApplicationWillEnterForeground.add(onApplicationWillEnterForeground);
    }

    private function onApplicationWillEnterBackground(): Void
    {
        //music.pause();
    }

    private function onApplicationWillEnterForeground(): Void
    {
        //music.play();
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

        ///nativePlayerCheckBox textures
        nativePlayerUpUnCheckedTexture = AssetManager.getTexture2D("testCheckBoxUpUnChecked.png");
        nativePlayerUpCheckedTexture = AssetManager.getTexture2D("testCheckBoxUpChecked.png");
        nativePlayerDownUnCheckedTexture = AssetManager.getTexture2D("testCheckBoxDownUnChecked.png");
        nativePlayerDownCheckedTexture = AssetManager.getTexture2D("testCheckBoxDownChecked.png");
        nativePlayerDisableUnCheckedTexture = AssetManager.getTexture2D("testCheckBoxDisableUnChecked.png");
        nativePlayerDisableCheckedTexture = AssetManager.getTexture2D("testCheckBoxDisableChecked.png");

        voleumeButtonTexture = AssetManager.getTexture2D("volume.png");
    }

    private function createButtons(): Void
    {
        playBtn = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn.transform.x = -20;
        playBtn.transform.y = 25;

        stopBtn = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn.transform.x = 285;
        stopBtn.transform.y = 25;

        pauseBtn = new SimpleButton(pauseBtnUpTexture, pauseBtnOverTexture, pauseBtnDownTexture);
        pauseBtn.transform.x = 185;
        pauseBtn.transform.y = 15;

        root.addChild(playBtn);
        root.addChild(stopBtn);
        root.addChild(pauseBtn);

        playBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            soundTrack.loop = true;
            soundTrack.play();
        });

        stopBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            soundTrack.stop();
        });
        pauseBtn.settings.onButtonUp.add(function(btn: Entity)
        {
            soundTrack.pause();
        });

        playBtn2 = new SimpleButton(playBtnUpTexture,playBtnOverTexture, playBtnDownTexture);
        playBtn2.transform.x = -20;
        playBtn2.transform.y = 200;

        stopBtn2 = new SimpleButton(stopBtnUpTexture,stopBtnOverTexture, stopBtnDownTexture);
        stopBtn2.transform.x = 285;
        stopBtn2.transform.y = 200;

        pauseBtn2 = new SimpleButton(pauseBtnUpTexture, pauseBtnOverTexture, pauseBtnDownTexture);
        pauseBtn2.transform.x = 185;
        pauseBtn2.transform.y = 190;

        root.addChild(playBtn2);
        root.addChild(stopBtn2);
        root.addChild(pauseBtn2);

        playBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            music.loop = true;
            music.play();
        });
        stopBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            music.stop();
        });
        pauseBtn2.settings.onButtonUp.add(function(btn: Entity)
        {
            music.pause();
        });


        volumeBtn = new SimpleButton(voleumeButtonTexture, voleumeButtonTexture, voleumeButtonTexture);
        volumeBtn.transform.x = 450;
        volumeBtn.transform.y = 150;
        root.addChild(volumeBtn);

        var dragComponent:DragComponent = new DragComponent();
        volumeBtn.add(dragComponent);

        var dragMin = 100;
        var dragMax = 200;

        dragComponent.onDrag.add(function(deltaX: Float, deltaY: Float)
        {
            var newY = Math.round(volumeBtn.transform.y + deltaY);
            if(newY >= dragMin && newY <= dragMax )
            {
                volumeBtn.transform.y = newY;
                music.volume = (newY - dragMin) / (dragMax - dragMin);
                trace("Volume is: " + music.volume);
            }
        });
    }

    private function createCheckBox(): Void
    {
        nativePlayerCheckBox = new CheckBox(nativePlayerUpCheckedTexture, nativePlayerUpUnCheckedTexture,
        nativePlayerDownCheckedTexture, nativePlayerDownUnCheckedTexture,
        nativePlayerDisableCheckedTexture, nativePlayerDisableUnCheckedTexture);

        var checkBoxStateConfig: CheckBoxStateConfig = new CheckBoxStateConfig();
        checkBoxStateConfig.resize = false;
        nativePlayerCheckBox.settings.stateConfigAll = checkBoxStateConfig;

        nativePlayerCheckBox.size.width = 34;
        nativePlayerCheckBox.size.height = 34;
        nativePlayerCheckBox.transform.x = 350;
        nativePlayerCheckBox.transform.y = 180;
        nativePlayerCheckBox.transform.anchorPoint = 1.0;
        nativePlayerCheckBox.checkStatus.selected = Music.allowNativePlayer;

        nativePlayerCheckBox.settings.onCheckBoxChanged.add(function(entity: Entity, checked: Bool)
        {
            Music.allowNativePlayer = checked;
        });

        root.addChild(nativePlayerCheckBox);

        var bmFontTextGenerator: BMFontTextGenerator = AssetManager.createBMFontTextGenerator("Fonts/Arial_Black_Raw.fnt");
        var checkBoxLabel: Text = new Text(bmFontTextGenerator);
        checkBoxLabel.transform.anchorPoint = 0.5;
        checkBoxLabel.size.width = 64;
        checkBoxLabel.size.height = 64;
        checkBoxLabel.transform.scale = 0.5;
        checkBoxLabel.transform.x = 170;
        checkBoxLabel.transform.y = 160;
        checkBoxLabel.settings.text = "Native player:";

        root.addChild(checkBoxLabel);
    }

    private function registerSystems(): Void
    {
        // Object Creation Systems
        root.engine.addSystem(new SimpleButtonSystem(), 0);
        root.engine.addSystem(new CheckBoxSystem(), 1);
        root.engine.addSystem(new Sprite2DSystem(), 2);
        root.engine.addSystem(new TextSystem(), 3);

        // Processing Systems
        root.engine.addSystem(new DragSystem(), 4);
        root.engine.addSystem(new Transform2DSystem(), 5);
        root.engine.addSystem(new RelationSystem(), 6);
        root.engine.addSystem(new Camera2DSystem(), 7);
    }

    override public function sceneWillAppear(): Void
    {
        createButtons();
        loadSound("Loop_drums.mp3", "Loop_synth.mp3");
    }

    private function loadSound(filename: String, filename2: String): Void
    {
        var fileUrl: String = FileSystem.instance().getUrlToStaticData() + "/" + filename;
        var fileUrl2: String = FileSystem.instance().getUrlToStaticData() + "/" + filename2;

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
