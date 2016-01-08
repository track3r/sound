/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */

package;

import unittest.TestRunner;
import unittest.implementations.TestHTTPLogger;
import unittest.implementations.TestJUnitLogger;
import unittest.implementations.TestSimpleLogger;

import duellkit.DuellKit;

import test.SoundTest;
/**
 * @author kgar
 */
class MainTest
{

    private var r: TestRunner;

    public function new()
    {
        DuellKit.initialize(startAfterDuellIsInitialized);
    }

    private function startAfterDuellIsInitialized(): Void
    {
        r = new TestRunner(testComplete, DuellKit.instance().onError);
        r.add(new SoundTest());

        #if jenkins
            r.addLogger(new TestHTTPLogger(new TestJUnitLogger()));
        #else
            r.addLogger(new TestHTTPLogger(new TestSimpleLogger()));
        #end

        //if you want to run your unittests on devices with android version < 5.0 use Logger without HTTP
        //r.addLogger(new TestSimpleLogger());

        r.run();
    }

    private function testComplete(): Void
    {
        trace(r.result);
    }

    /// MAIN
    static var _main: MainTest;

    static function main(): Void
    {
        _main = new MainTest();
    }
}
