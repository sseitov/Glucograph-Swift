//
//  MigrationManager.m
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import "MigrationManager.h"
#import "SynthesizeSingleton.h"
#import "Glucograph-Swift.h"

#include <sqlite3.h>

static NSString* databasePath()
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingString:@"/Glucograph2.sqlite"];
}

@interface MigrationManager () {
    sqlite3 *masterDB;
}

@end

@implementation MigrationManager

SYNTHESIZE_SINGLETON_FOR_CLASS(MigrationManager);

- (bool)needMigration
{
    NSString *dbPath = databasePath();
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
        return false;
    
    masterDB = nil;
    sqlite3_open(dbPath.UTF8String, &masterDB);
    if (!masterDB) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
        return false;
    }
    
    return true;
}

- (void)migrate:(void (^)(void))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {

        sqlite3_stmt *pStmt;
        NSString* sql =@"select * from bloods";
        if (sqlite3_prepare(masterDB, [sql UTF8String], -1, &pStmt, NULL) != SQLITE_OK) {
            NSLog(@"SQL Error: '%s'", sqlite3_errmsg(masterDB));
            sqlite3_finalize(pStmt);
            complete();
        }
        int count = sqlite3_column_count(pStmt);
        for (int i=0; i<count; i++) {
            NSLog(@"%s", sqlite3_column_name(pStmt, i));
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterLongStyle;
        while (sqlite3_step(pStmt) == SQLITE_ROW) {
            double timestamp = sqlite3_column_double(pStmt, 0);
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            double morning = (float)sqlite3_column_double(pStmt, 1);
            double evening = (float)sqlite3_column_double(pStmt, 2);
            NSString* comment = @"";
            const unsigned char* t = sqlite3_column_text(pStmt, 3);
            if (t) {
                comment = [NSString stringWithUTF8String:(const char*)t];
            }
            NSLog(@"%@: %f - %f. %@", [formatter stringFromDate:date], morning, evening, comment);
        }

        dispatch_async(dispatch_get_main_queue(), ^() {
            complete();
        });
    });
}

@end
