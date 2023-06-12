#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "colorpicker.h"

typedef void (^CDUnknownBlockType)(void);

@interface FCCCModuleViewController : UIViewController
@property (assign, nonatomic) UIViewController *parentViewController;
@end 

@interface NSObject () 
-(NSString *)className;
@end

@interface CCUIRoundButton : UIControl  {
	UIView* _normalStateBackgroundView;
}
@end

@interface CCUIButtonModuleView : UIControl {
	UIView* _highlightedBackgroundView;
}
@end

@interface MRUControlCenterView : UIView {
	UIView* _materialView;
}
@end

@interface MRPlatterViewController : UIViewController 
-(UIView *)backgroundView;
@end

@interface MediaControlsPanelViewController : UIViewController
-(UIView *)backgroundView;
@end

@interface CCUIBaseSliderView : UIControl
@end

@interface CCUIContinuousSliderView : CCUIBaseSliderView
@end


@interface MTMaterialView : UIView
- (void)CoolCC;
@end



@interface MediaControlsVolumeSliderView : CCUIContinuousSliderView {
	MTMaterialView* _materialView;
}
@end

@interface CCUIContentModuleContentContainerView : UIView {
	MTMaterialView* _moduleMaterialView;
}
-(MTMaterialView *)moduleMaterialView;
@end

@interface CCUIModularControlCenterViewController : UIViewController
@end

@interface CCUIModularControlCenterOverlayViewController : CCUIModularControlCenterViewController
-(MTMaterialView *)overlayBackgroundView;
@end

@interface CABackdropLayer : CALayer
-(void)mt_setColorMatrixDrivenOpacity:(double)arg1 removingIfIdentity:(BOOL)arg2;
@end

@interface MTMaterialLayer : CABackdropLayer
@end

@interface _MTBackdropView : UIView 
-(void)setColorMatrixColor:(UIColor *)arg1;
-(void)setSaturation:(double)arg1;
-(void)setBrightness:(double)arg1;
@end

static UIColor* BorderColor = nil;
static BOOL OnHUD = false;
static float Width = 0.0;

%group CoolCCHook
%hook MTMaterialView
%new
- (void)CoolCC {
	CALayer *ourLayer = [self layer];
	NSString *ourClassName = NSStringFromClass([ourLayer class]);

	if([ourClassName isEqual:@"MTMaterialLayer"]) {
		if(ourLayer) {
			// if([self respondsToSelector:@selector(backgroundView)]) {
			if([ourLayer respondsToSelector:@selector(mt_setColorMatrixDrivenOpacity:removingIfIdentity:)]) {
				[(MTMaterialLayer *)ourLayer mt_setColorMatrixDrivenOpacity:0.0 removingIfIdentity:true];
				[(MTMaterialLayer *)ourLayer setBorderWidth:Width];
				CGColorRef ourBorderCGColor = nil;
				if(BorderColor) {
					ourBorderCGColor = [BorderColor CGColor];
				}
				[ourLayer setBorderColor: ourBorderCGColor];
			}
		}
	} else {
		UIView *bView = MSHookIvar<UIView *>(self, "_backdropView");
		if(bView) {
			if([bView respondsToSelector:@selector(setColorMatrixColor:)]
				&& [bView respondsToSelector:@selector(setSaturation:)]
				&& [bView respondsToSelector:@selector(setBrightness:)]) {
					[(_MTBackdropView *)bView setColorMatrixColor: nil];
					[(_MTBackdropView *)bView setSaturation:0.0];
					[(_MTBackdropView *)bView setBrightness:0.0];
			}

			CALayer *bViewLayer = [bView layer];
			[bViewLayer setBorderWidth:Width];

			CGColorRef ourBorderCGColor = nil;
			if(BorderColor) {
				ourBorderCGColor = [BorderColor CGColor];
			}
			[bViewLayer setBorderColor: ourBorderCGColor];
		}
	}
}
%end

%hook CCUIContentModuleContentContainerView
-(void)layoutSubviews {
	%orig;
	if([self respondsToSelector:@selector(moduleMaterialView)]) {
		MTMaterialView *mtmview = [self moduleMaterialView];
		if(mtmview)
			[mtmview CoolCC];
	}

	MTMaterialView *mMView = MSHookIvar<MTMaterialView *>(self, "_moduleMaterialView");
	if(mMView)
		[mMView CoolCC];
}

-(void)transitionToExpandedMode:(BOOL)arg1  {
	%orig(arg1);
	CALayer *ourLayer = [self layer];
	double ourCornerRadius = [ourLayer cornerRadius];
	double ourWidth = 0.0;

	if(ourCornerRadius != 0.0 && arg1) {
		CGColorRef bcgColor = nil;
		if(BorderColor) {
			bcgColor = [BorderColor CGColor];
		}
		CALayer *ourLayer2 = [self layer];
		[ourLayer2 setBorderColor:bcgColor];
		ourWidth = Width;
	}

	CALayer *ourLayer3 = [self layer];
	[ourLayer3 setBorderWidth:ourWidth];
}
%end

%hook MediaControlsVolumeSliderView
-(void)layoutSubviews {
	%orig;
	if(OnHUD || [NSStringFromClass([self class]) isEqual:@"SBElasticSliderView"]) {
		MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_materialView");
		if(mView)
			[mView CoolCC];
	}
}
%end

//iOS 15 start!!!
%hook FCCCControlCenterModule
-(void)viewDidLayoutSubviews {
	%orig;
	MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_backgroundView");
	if(mView)
		[mView CoolCC];
}
%end

%hook FCUIActivityControl 
-(void)layoutSubviews {
	%orig;
	MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_backgroundView");
	if(mView)
		[mView CoolCC];
}
%end

%hook CCUILabeledRoundButtonViewController
-(void)viewDidLayoutSubviews {
	%orig;
	CCUIRoundButton *btn = MSHookIvar<CCUIRoundButton *>(self, "_button");
	if(btn) {
		UIView *mView = MSHookIvar<UIView *>(btn, "_normalStateBackgroundView");
		if([NSStringFromClass([mView class]) isEqual:@"MTMaterialView"])
			if(mView)
				[(MTMaterialView *)mView CoolCC];
	}
	
}
%end

%hook MediaControlsExpandableButton
-(void)layoutSubviews {
	%orig;
	MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_backgroundView");
	if(mView && [NSStringFromClass([mView class]) isEqual:@"MTMaterialView"])
		[mView CoolCC];
}
%end

%hook _FCUIAddActivityControl
-(void)layoutSubviews {
	%orig;
	MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_backgroundMaterialView");
	if(mView && [NSStringFromClass([mView class]) isEqual:@"MTMaterialView"])
		[mView CoolCC];
}
%end
///iOS 15 End!!!

%hook MediaControlsPanelViewController
-(void)viewDidLayoutSubviews {
	%orig;
	if([self respondsToSelector:@selector(backgroundView)]) {
		UIView *bgView = [self backgroundView];
		if(bgView) {
			NSString *bgViewClassName = NSStringFromClass([bgView class]);
			if([bgViewClassName isEqualToString:@"MediaControlsMaterialView"]) {
				[(MTMaterialView *)bgView CoolCC]; 
				return;
			}
			double version = kCFCoreFoundationVersionNumber;
			const char* ourView = version <= 1556.0 ? "_materialView" : "_backgroundView";
			MTMaterialView *mView = MSHookIvar<MTMaterialView *>(bgView, ourView);
			if(mView) {
				[mView CoolCC];
				return;
			}
		}
	}
}
%end

%hook MRPlatterViewController
-(void)viewDidLayoutSubviews {
	%orig;
	if([self respondsToSelector:@selector(backgroundView)]) {
		UIView *bgView = [self backgroundView];
		if(bgView) {
			NSString *bgViewClassName = NSStringFromClass([bgView class]);
			if([bgViewClassName isEqual:@"MediaControlsMaterialView"]) {
				MTMaterialView *mView = MSHookIvar<MTMaterialView *>(bgView, "_backgroundView");
				if(mView) {
					[mView CoolCC];
					return;
				}
			}
		}
	}
}
%end

%hook MRUControlCenterView
-(void)layoutSubviews {
	%orig;
	MTMaterialView *mView = MSHookIvar<MTMaterialView *>(self, "_materialView");
	if(mView)
		[mView CoolCC];
}
%end
%end

%group CoolCCHookRH
%hook CCUIButtonModuleView
-(void)layoutSubviews {
	%orig;
	UIView *hView = MSHookIvar<UIView *>(self, "_highlightedBackgroundView");
	if(hView)
		[hView setHidden:true];
}
%end
%end

%group CoolCCHookDB
%hook CCUIModularControlCenterOverlayViewController
-(void)presentAnimated:(BOOL)arg1 withCompletionHandler:(CDUnknownBlockType)arg2 {
	%orig(arg1, arg2);
	if([self respondsToSelector:@selector(overlayBackgroundView)]) {
		MTMaterialView *mView = [self overlayBackgroundView];
		if(mView) {
			UIColor *ourColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
			[mView setBackgroundColor:ourColor];
			[UIView animateWithDuration:0.0 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				UIColor *ourColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
				[mView setBackgroundColor:ourColor];
    		} completion:nil];
		}
	}
}

-(void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(CDUnknownBlockType)arg2 {
	%orig(arg1, arg2);
	if([self respondsToSelector:@selector(overlayBackgroundView)]) {
		MTMaterialView *mView = [self overlayBackgroundView];
		if(mView) {
			[UIView animateWithDuration:0.0 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				UIColor *ourColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
				[mView setBackgroundColor:ourColor];
    		} completion:nil];
		}
	}
}
%end
%end

%ctor {
	@autoreleasepool {
		NSLog(@"[CoolCC] Loaded.");


		dlopen("/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/FocusUIModule", RTLD_GLOBAL);

		NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/jb/var/mobile/Library/Preferences/alias20.coolcc.plist"];


		BOOL kEnabled = [[settings objectForKey:@"enabled"] boolValue];
		if(!settings)
			kEnabled = true;

		BOOL kRemovehighlight = [[settings objectForKey:@"removehighlight"] boolValue];
		BOOL kDarkbg = [[settings objectForKey:@"darkbg"] boolValue];
		float kWidth = [[settings objectForKey:@"width"] floatValue];
		Width = kWidth;
		NSString *kBorderColorStr = [settings objectForKey:@"BorderColor"];
		UIColor *kBorderColor = LCPParseColorString(kBorderColorStr, @"#FFFFFF");
		if(!kBorderColor)
			kBorderColor = [UIColor whiteColor];
		BorderColor = kBorderColor;
		BOOL kOnhUD = [[settings objectForKey:@"onhud"] boolValue];
		if(!settings)
			kOnhUD = true;
		OnHUD = kOnhUD;

		if(kEnabled) {

			%init(CoolCCHook);

			if(kRemovehighlight) {
				%init(CoolCCHookRH);
			}

			if(kDarkbg) {
				%init(CoolCCHookDB);

			}
		}
	}
}