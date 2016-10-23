//
//  Address.h
//  CoreData_Example
//
//  Created by HealthOne on 23/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Address : NSManagedObject

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSString *number;
@property (nullable, nonatomic, retain) NSString *street;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *persons;

@end
