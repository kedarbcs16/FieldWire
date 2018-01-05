//
//  AppDelegate.h
//  Fieldwire
//
//  Created by kedar on 12/26/17.
//  Copyright © 2017 kedar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

