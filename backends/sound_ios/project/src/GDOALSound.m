#import "GDOALSound.h"
#import "ObjectAL.h"


#define INGAME_MUSIC_FILE @"assets/shotgun.mp3"

@implementation GDOALSound
- (id) init
{
    if(nil != (self = [super init]))
    {
        // We don't want ipod music to keep playing since
        // we have our own bg music.
        [OALSimpleAudio sharedInstance].allowIpod = NO;
        
        // Mute all audio if the silent switch is turned on.
        [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
        
        // This loads the sound effects into memory so that
        // there's no delay when we tell it to play them.
        [[OALSimpleAudio sharedInstance] preloadEffect:INGAME_MUSIC_FILE];
    }
    return self;
}
- (void) play
{
    // Play the BG music and loop it.
    [[OALSimpleAudio sharedInstance] playEffect:INGAME_MUSIC_FILE loop:NO];
}
- (void) pause
{
    [OALSimpleAudio sharedInstance].paused = YES;
}
- (void) resume
{
    [OALSimpleAudio sharedInstance].paused = NO;
}
- (void) mute
{

}
- (void) set_volume
{

}
- (void) set_loop
{

}
- (void) get_length
{

}
- (void) get_position
{

}
- (void) playBG
{
    // Could use stopEverything here if you want
    [[OALSimpleAudio sharedInstance] stopAllEffects];
    
    // We only play the game over music through once.
    [[OALSimpleAudio sharedInstance] playBg:GAMEOVER_MUSIC_FILE];
}
- (void) cleanup
{
    // Stop all music and sound effects.
    [[OALSimpleAudio sharedInstance] stopEverything];   
    
    // Unload all sound effects and bg music so that it doesn't fill
    // memory unnecessarily.
    [[OALSimpleAudio sharedInstance] unloadAllEffects];
}
@end