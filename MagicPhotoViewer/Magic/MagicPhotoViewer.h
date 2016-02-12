//
//  PhotosHelper.h
//

#import <UIKit/UIKit.h>

typedef void(^CodeBlock)(void);

@interface MagicPhotoViewer : NSObject

+ (id)sharedInstance;

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close;

@end
