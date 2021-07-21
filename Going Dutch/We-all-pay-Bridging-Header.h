//
//  We-all-pay-Bridging-Header.h
//  We all pay
//
//  Created by Mark Cornelisse on 30/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#pragma mark - Model
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCEmailAddress+addons.h"

#pragma mark - Persistence
#import "MCWeAllPayStoreController.h"

#pragma mark - Protocols
#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"
#import "MCDismissKeyboardProtocol.h"
#import "MCPathComponentsToOpenProtocol.h"

#pragma mark - Miscellanwous
#import "MCTools.h"

#pragma mark - ViewControllers
#import "MCGenericInterstitialAdTableViewController.h"
#import "MCGenericAdBannerTableViewController.h"
#import "MCAllTripsTableViewController.h"
#import "MCAllTripsTableViewController-iPad.h"
#import "MCReturnPaymentViewController.h"
#import "MCSolutionTableViewController.h"

#pragma mark - Views
#import "MCNotificationUnreadIndicator.h"
#import "MCBadgeButton.h"
#import "MCBorderLineView.h"

#import "MCEmailTextInputProxy.h"
