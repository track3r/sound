@interface GDSoundNativeExtension : NSObject<AVAudioPlayerDelegate>
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;

/// Deprecated in IOS8
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags;
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player;
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags;
@end