#import <UIKit/UIKit.h>

@interface SCGIFImageFrame : NSObject {
    
}
@property (nonatomic) double duration;
@property (nonatomic, retain) UIImage* image;

@end

@interface SCGIFImageView : UIImageView {
    NSInteger _currentImageIndex;
}
@property (nonatomic, retain) NSArray* imageFrameArray;
@property (nonatomic, retain) NSTimer* timer;

//Setting this value to pause or continue animation;
@property (nonatomic) BOOL animating;

- (void)setData:(NSData*)imageData;

@end
