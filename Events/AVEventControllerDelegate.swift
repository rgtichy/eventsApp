//
//  AVEventControllerDelegate.swift
//  Events
//
//  Created by Robert G Tichy on 6/4/17.
//  Copyright © 2017 Robert G Tichy. All rights reserved.
//

import UIKit

protocol AVEventControllerDelegate: class {
    func savePressed(controller: AddViewEventController, event: event_struct, atRow: NSIndexPath?)
}

