//
//  BluetoothCentralManager.m
//  RemoteKBDesktop
//
//  Created by everettjf on 2019/7/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "BluetoothCentralManager.h"
#include "../../dep/logic/logic.hpp"
#include "../../dep/logic/bledef.h"

@interface BluetoothCentralManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray<CBPeripheral*> *items;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (strong, nonatomic) CBCharacteristic *connectedCharacteristic;

@end

@implementation BluetoothCentralManager

+ (instancetype)sharedManager {
    static BluetoothCentralManager *o;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        o = [[BluetoothCentralManager alloc] init];
    });
    return o;
}


- (void)start {
    
}

- (void)connect:(NSString *)peripheralName {
    CBPeripheral *foundPeripheral = nil;
    for(CBPeripheral *peripheral in self.items){
        if ([peripheral.name isEqualToString:peripheralName]) {
            foundPeripheral = peripheral;
            break;
        }
    }
    if(foundPeripheral == nil){
        return;
    }
    
    if (self.onStatus) {
        self.onStatus(ChannelClientStatus_ConnectStart, @"");
    }
    
    [self connectByPeripheral:foundPeripheral];
}

- (void)connectByPeripheral:(CBPeripheral*)peripheral {
    [self.centralManager connectPeripheral:peripheral options:nil];
}
- (void)send:(NSString*)type content:(NSString*)content {
    if(!self.connectedPeripheral) {
        return;
    }
    std::string msg = rekb::construct_message(type.UTF8String, content.UTF8String);
    NSString *myString = [NSString stringWithUTF8String:msg.c_str()];
    NSData *myValue = [myString dataUsingEncoding:NSUTF8StringEncoding];
    [self.connectedPeripheral writeValue:myValue forCharacteristic:self.connectedCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)close {
    [self stopScan];
    
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startScan {
    
    CBUUID *myServiceUUID = [CBUUID UUIDWithString:MYBLE_SERVICE_UUID];
    [self.centralManager scanForPeripheralsWithServices:@[myServiceUUID] options:nil];

}
- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral %@",peripheral);
    
    if (self.onStatus) {
        self.onStatus(ChannelClientStatus_ConnectReady, @"");
    }
    
    [self stopScan];
    
    self.connectedPeripheral = peripheral;
    
    self.connectedPeripheral.delegate = self;
    [self.connectedPeripheral discoverServices: nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    NSLog(@"didWriteValueForCharacteristic error = %@", error);
    
    if (error) {
        [self close];
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch(central.state) {
        case CBManagerStateUnknown: {
            NSLog(@"centralManagerDidUpdateState Unknown");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_ConnectFailed, @"Unknown");
            }
            break;
        }
        case CBManagerStateResetting: {
            NSLog(@"centralManagerDidUpdateState Resetting");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_ConnectFailed, @"Resetting");
            }
            break;
        }
        case CBManagerStateUnsupported: {
            NSLog(@"centralManagerDidUpdateState Unsupported");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_Unsupported, @"Unsupported");
            }
            break;
        }
        case CBManagerStateUnauthorized: {
            NSLog(@"centralManagerDidUpdateState Unauthorized");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_ConnectFailed, @"Unauthorized");
            }
            break;
        }
        case CBManagerStatePoweredOff: {
            NSLog(@"centralManagerDidUpdateState PoweredOff");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_PowerOff, @"");
            }
            break;
        }
        case CBManagerStatePoweredOn: {
            NSLog(@"centralManagerDidUpdateState PoweredOn");
            if (self.onStatus) {
                self.onStatus(ChannelClientStatus_Scanning, @"");
            }
            [self startScan];
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (peripheral.name.length == 0) {
        return;
    }

    NSLog(@"%@, %@, %@, %@",
          peripheral.name,
          @(peripheral.state) ,
          RSSI,
          peripheral.services);
    
    // 配对成功后，下一次连接，peripheral的name会变成对面的host名称（macbook的hostname，例如mbphome）
    //    if ([peripheral.name rangeOfString:@"RemoteKB-"].location != 0) {
    //        return;
    //    }


    dispatch_async(dispatch_get_main_queue(), ^{

        NSInteger findIndex = -1;
        for(NSInteger index = 0; index < self.items.count; ++index) {
            CBPeripheral *item = self.items[index];
            if([item.name isEqualToString:peripheral.name]) {
                findIndex = index;
                break;
            }
        }
        if (findIndex != -1) {
            self.items[findIndex] = peripheral;
        } else {
            [self.items addObject:peripheral];
        }

        if (self.onScanResult) {
            NSMutableArray<NSString*> *names = [[NSMutableArray alloc] init];
            for(CBPeripheral *item in self.items) {
                [names addObject:item.name];
            }
            self.onScanResult(names);
        }
    });
}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral %@",peripheral);
    
    if (self.onStatus) {
        self.onStatus(ChannelClientStatus_ConnectClose, @"");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices %@",@(peripheral.services.count));
    
    CBUUID *myServiceUUID = [CBUUID UUIDWithString:MYBLE_SERVICE_UUID];
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        
        if ([service.UUID isEqual:myServiceUUID]) {
            // go on
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService %@",service);
    CBUUID *myCharacteristicUUID = [CBUUID UUIDWithString:MYBLE_CHARACTERISTIC_UUID];
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        
        if ([characteristic.UUID isEqual:myCharacteristicUUID]) {
            
            // save
            self.connectedCharacteristic = characteristic;
            
            // subscribe
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
}
//
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"didUpdateValueForCharacteristic %@",characteristic);
//
//    NSData *data = characteristic.value;
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"value = %@", str);
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"didUpdateNotificationStateForCharacteristic %@",characteristic);
//    NSData *data = characteristic.value;
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"subscribe value = %@", str);
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"didWriteValueForCharacteristic %@ , error=%@",characteristic,error);
//
//}


@end
