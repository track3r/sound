#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif
#import <Foundation/Foundation.h>
#include <hx/CFFI.h>

value *__soundCompleteCallback = NULL;


///------------------------------------------------------------------------------------------------
static value iossound_registerCallback(value callback)
{
    val_check_function(callback, 1); // Is Func ?

    if(__soundCompleteCallback == NULL)
    {
        __soundCompleteCallback = alloc_root();
    }
    *__soundCompleteCallback = callback;

    return alloc_null();
}
DEFINE_PRIM (iossound_registerCallback, 1);
///--------------------------------------------------------------------
static value iossound_intialize(value soundData)
{
    NSLog(@"iossound_intialize");
    return alloc_null();
}
DEFINE_PRIM(iossound_intialize,1);
///--------------------------------------------------------------------
static value iossound_play()
{
    NSLog(@"iossound_play");
    return alloc_null();
}
DEFINE_PRIM(iossound_play,0);
///--------------------------------------------------------------------
static value iossound_stop()
{
    NSLog(@"iossound_stop");
    return alloc_null();
}
DEFINE_PRIM(iossound_stop,0);
///--------------------------------------------------------------------
static value iossound_pause()
{
    NSLog(@"iossound_pause");
    return alloc_null();
}
DEFINE_PRIM(iossound_pause,0);
///--------------------------------------------------------------------
static value iossound_setLoop(value loop)
{
    NSLog(@"iossound_setLoop");
    return alloc_null();
}
DEFINE_PRIM(iossound_setLoop,1);
///--------------------------------------------------------------------
static value iossound_setVolume(value volume)
{
    NSLog(@"iossound_setVolume");
    return alloc_null();
}
DEFINE_PRIM(iossound_setVolume,1);
///--------------------------------------------------------------------
static value iossound_setMute(value mute)
{
    NSLog(@"iossound_setMute");
    return alloc_null();
}
DEFINE_PRIM(iossound_setMute,1);
///--------------------------------------------------------------------

extern "C" int iossound_register_prims () { return 0; }