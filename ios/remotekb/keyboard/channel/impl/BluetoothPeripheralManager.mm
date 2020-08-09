//
//  BluetoothPeripheralManager.m
//  keyboard
//
//  Created by everettjf on 2019/7/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "BluetoothPeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#include "../../../dep/logic/logic.hpp"
#include "../../../dep/logic/bledef.h"

@interface BluetoothPeripheralManager () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager * peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *characteristic;
@property (strong, nonatomic) CBMutableService *service;

@property (strong, nonatomic) NSMutableArray<CBCentral*> *subscribedCentrals;
@property (strong, nonatomic) NSString* serviceName;

@end

@implementation BluetoothPeripheralManager

+ (instancetype)sharedManager {
    static BluetoothPeripheralManager *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[BluetoothPeripheralManager alloc] init];
    });
    return o;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subscribedCentrals = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)start {
    self.serviceName = @"Unknown";
    
    [self close];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)close {
    if (self.peripheralManager) {
        [self.peripheralManager stopAdvertising];
        self.peripheralManager = nil;
    }
}

- (void)onPoweredOn {
    CBUUID *myServiceUUID = [CBUUID UUIDWithString:MYBLE_SERVICE_UUID];
    CBUUID *myCharacteristicUUID = [CBUUID UUIDWithString:MYBLE_CHARACTERISTIC_UUID];
    
    self.characteristic = [[CBMutableCharacteristic alloc] initWithType:myCharacteristicUUID
                                                             properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify
                                                                  value:nil
                                                            permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable
                           ];
    
    self.service = [[CBMutableService alloc] initWithType:myServiceUUID primary:YES];
    self.service.characteristics = @[self.characteristic];
    
    [self.peripheralManager addService:self.service];
}

- (void)onAddService{
    NSString *hostName = [UIDevice currentDevice].name;
    
    NSString *localName = [NSString stringWithFormat:@"%@",hostName];
    self.serviceName = [localName copy];
    
    [self.peripheralManager startAdvertising:@{
                                               CBAdvertisementDataServiceUUIDsKey : @[self.service.UUID],
                                               CBAdvertisementDataLocalNameKey : localName
                                               }];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStateUnknown:
            NSLog(@"peripheralManagerDidUpdateState Unknown");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth unknown error");
            }
            break;
        case CBManagerStateResetting:
            NSLog(@"peripheralManagerDidUpdateState CBManagerStateResetting");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth resetting");
            }
            break;
        case CBManagerStateUnsupported:
            NSLog(@"peripheralManagerDidUpdateState CBManagerStateUnsupported");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth unsupported");
            }
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"peripheralManagerDidUpdateState CBManagerStateUnauthorized");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth unauthorized");
            }
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"peripheralManagerDidUpdateState CBManagerStatePoweredOff");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth powered off");
            }
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"peripheralManagerDidUpdateState CBManagerStatePoweredOn");
            if(self.onStatus){
                self.onStatus(@"waiting",@"Bluetooth powered on");
            }
            [self onPoweredOn];
            break;
        default:
            break;
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"didAddService service:%@ error:%@",service,error);
    
    if (error) {
        if(self.onStatus){
            self.onStatus(@"waiting",[NSString stringWithFormat:@"Bluetooth service create error:%@",error.localizedDescription]);
        }
        return;
    }
    
    [self onAddService];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"DidStartAdvertising %@ %@",peripheral,error);
    if (error) {
        if(self.onStatus){
            self.onStatus(@"waiting",[NSString stringWithFormat:@"Bluetooth start advertising error:%@",error.localizedDescription]);
        }
        return;
    }

    if (self.onReady) {
        self.onReady(self.serviceName);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"didReceiveReadRequest %@", request);
    
    if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
        
        if(self.onStatus){
            self.onStatus(@"connected",@"");
        }
        
        NSString *myString = @"hello everettjf";
        NSData *myValue = [myString dataUsingEncoding:NSUTF8StringEncoding];
        request.value = myValue;
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        
    } else {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorRequestNotSupported];
        
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSLog(@"didReceiveWriteRequests %@",requests);
    
    CBATTRequest * request = requests.firstObject;
    NSData *data = request.value;
    NSString *value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"value = %@",value);
    
    std::string command;
    std::string content;
    if (rekb::deconstruct_message(value.UTF8String, command, content) ) {
        if(self.onMessage) {
            self.onMessage([NSString stringWithUTF8String:command.c_str()], [NSString stringWithUTF8String:content.c_str()]);
        }
    }
    
    [self.peripheralManager respondToRequest:requests.firstObject withResult:CBATTErrorSuccess];
}

//- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"didSubscribeToCharacteristic %@ %@",central, characteristic);
//    
//    [self.subscribedCentrals addObject:central];
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"didUnsubscribeFromCharacteristic %@",characteristic);
//    
//    [self.subscribedCentrals removeObject:central];
//}
//
//- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
//    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
//}
//
//- (void)updateCharacteristicValues {
//    static int i = 0;
//    ++i;
//    
//    NSString *myString = [NSString stringWithFormat:@"hello %@",@(i)];
//    NSData *myValue = [myString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    BOOL didSendValue = [self.peripheralManager updateValue:myValue forCharacteristic:self.characteristic onSubscribedCentrals:self.subscribedCentrals];
//    
//    NSLog(@"didSendValue = %@", @(didSendValue));
//}
@end
