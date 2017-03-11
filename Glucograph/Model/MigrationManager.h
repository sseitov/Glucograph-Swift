//
//  MigrationManager.h
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MigrationManager : NSObject

+ (MigrationManager *)sharedMigrationManager;

- (bool)startMigration;
- (void)migrate:(void (^)(void))complete;
- (void)finishMigration;

@end
