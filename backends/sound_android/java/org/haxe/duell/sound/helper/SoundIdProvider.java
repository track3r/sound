package org.haxe.duell.sound.helper;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author jxav
 */
public final class SoundIdProvider
{
    private static final AtomicInteger ID_GENERATOR = new AtomicInteger(0);

    private SoundIdProvider()
    {
        // can't be instantiated
    }

    public static synchronized int getId()
    {
        return ID_GENERATOR.getAndIncrement();
    }
}
