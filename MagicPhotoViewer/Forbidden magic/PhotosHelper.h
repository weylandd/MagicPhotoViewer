//
//  PhotosHelper.h
//

#import <UIKit/UIKit.h>

#define PhotosViewer [PhotosHelper sharedInstance]

typedef void(^CodeBlock)(void);

@interface PhotosHelper : NSObject

+ (id)sharedInstance;

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close;

@end
