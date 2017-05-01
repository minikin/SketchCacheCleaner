//
//  ViewController.swift
//  Sketch Cache Cleaner
//
//  Created by Sasha Prokhorenko on 2/6/17.
//  Copyright © 2017 Sasha Prokhorenko. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  // MARK: - Properties
  @IBOutlet var backgroundView: NSView!
  @IBOutlet weak var button: NSButton!
  @IBOutlet weak var mainImage: NSImageView!
  @IBOutlet weak var imageWidth: NSLayoutConstraint!
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  @IBOutlet weak var backgroundImage: NSImageView!
  @IBOutlet weak var cacheCleared: NSImageView!
  
  var permissionGranted = false
  var stringToTest = ""
  let privilegedTask = STPrivilegedTask()
  let bashPath = "/bin/sh"
  let calculateCacheSizeTask = ["calculate_cache_size.sh"]
  
  // MARK: - ViewController lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundImage.isHidden = true
    cacheCleared.isHidden = true
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    view.window?.titlebarAppearsTransparent = true
    view.window?.backgroundColor = NSColor(red:0.07, green:0.04, blue:0.20, alpha:1.00)
    view.window?.title = "Sketch Cache Cleanerd"
    backgroundView.backgroundColor = NSColor(red:0.07, green:0.04, blue:0.20, alpha:1.00)
  }
  
  func appState() {
    switch (permissionGranted, button.title) {
    case (false, "Allow"):
      button.title = "Allow"
      askPermission()
    case (true, "How big is my Sketch cache?"):
      checkSizeOfCache()
    case (true, stringToTest):
      clearCache()
    default:
      print("Do nothing")
    }
  }
  
  func askPermission() {
    privilegedTask.launchPath = bashPath
    privilegedTask.arguments = calculateCacheSizeTask
    privilegedTask.currentDirectoryPath = Bundle.main.resourcePath
    let err = privilegedTask.launch()
    if err != errAuthorizationSuccess {
      if (err == errAuthorizationCanceled) {
        print("User cancelled", permissionGranted)
        permissionGranted = false
        return
      } else {
        print("Something went wrong:", err)
        // For error codes, see http://www.opensource.apple.com/source/libsecurity_authorization/libsecurity_authorization-36329/lib/Authorization.h
      }
    }
    
    privilegedTask.waitUntilExit()
    permissionGranted = true
    backgroundImage.isHidden = false
    button.title = "How big is my Sketch cache?"
    imageHeight.constant = 180
    imageWidth.constant = 155
    mainImage.cell?.image = #imageLiteral(resourceName: "cube")
  }
  
  func checkSizeOfCache() {
    let readHandle = privilegedTask.outputFileHandle
    let outputData = readHandle?.readDataToEndOfFile()
    let outputString = String(data: outputData!, encoding: .utf8)
    let stringArray = outputString?.components(separatedBy: "/")
    guard let stringToDispaly = stringArray?[0] else { return }
    if stringToDispaly == "" {
      finalUIState()
    } else {
      stringToTest = "Clear \(stringToDispaly)"
      button.title = "Clear \(stringToDispaly)"
    }
  }
  
  func clearCache() {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["rm -rf /.DocumentRevisions-V100"]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    finalUIState()
  }
  
  func finalUIState(){
    imageHeight.constant = 200
    imageWidth.constant = 232
    mainImage.cell?.image = #imageLiteral(resourceName: "openBox")
    button.isHidden = true
    cacheCleared.isHidden = false
  }
  
  
  // MARK: - Actions
  @IBAction func buttonPressed(_ sender: NSButton) {
    appState()
  }
  
}

