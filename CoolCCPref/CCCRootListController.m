#import <Preferences/PSSpecifier.h>

#include <spawn.h>
#include <signal.h>

#include "CCCRootListController.h"

static NSString *prefsFileName = @"alias20.coolcc";

@implementation CCCRootListController

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/jb/User/Library/Preferences/%@.plist", prefsFileName];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/jb/User/Library/Preferences/%@.plist", prefsFileName];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)doRespring {
	pid_t pid;
	int status;
	const char *argv[] = {"sbreload", NULL};
	posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, (char* const*)argv, NULL);
	waitpid(pid, &status, WEXITED);
}

- (void)respring {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认" message:@"现在想注销设备吗？\n\n🇨🇳刀刀" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self doRespring];
    }];
    
    [alertController addAction:destructiveAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}




@end
