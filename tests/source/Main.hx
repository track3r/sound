/*
 * Created by IntelliJ IDEA.
 * User: sott
 * Date: 24/09/14
 * Time: 10:23
 */
package;

import haxe.CallStack;
import scenes.SoundScene;
import duell.DuellKit;

import game_engine.core.GameEngine;

class Main
{
    private var gameEngine:GameEngine;

    public function new()
    {
        DuellKit.initialize(startApp);

        DuellKit.instance().onError.add(function(data:Dynamic) : Void{
            trace("Error : " + data);
            trace(CallStack.toString(CallStack.exceptionStack()));
        });
    }

    private function startApp() : Void
    {
        gameEngine = new GameEngine();
        gameEngine.presentScene(new SoundScene());
    }

    /// MAIN
    static var _main : Main;
    static function main() : Void
    {
        _main = new Main();
    }
}