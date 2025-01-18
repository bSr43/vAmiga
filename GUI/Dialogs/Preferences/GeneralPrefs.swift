// -----------------------------------------------------------------------------
// This file is part of vAmiga
//
// Copyright (C) Dirk W. Hoffmann. www.dirkwhoffmann.de
// Licensed under the GNU General Public License v3
//
// See https://www.gnu.org for license information
// -----------------------------------------------------------------------------

@MainActor
extension PreferencesController {
    
    func refreshGeneralTab() {
        
        // Initialize combo boxes
        if genFFmpegPath.tag == 0 {
            
            genFFmpegPath.tag = 1
            
            for i in 0...5 {
                if let path = emu.recorder.findFFmpeg(i) {
                    genFFmpegPath.addItem(withObjectValue: path)
                } else {
                    break
                }
            }
        }
        
        // Snapshots
        genSnapshotStorage.integerValue = pref.snapshotStorage
        genAutoSnapshots.state = pref.autoSnapshots ? .on : .off
        genSnapshotInterval.integerValue = pref.snapshotInterval
        genSnapshotInterval.isEnabled = pref.autoSnapshots

        // Screenshots
        genScreenshotSourcePopup.selectItem(withTag: pref.screenshotSource)
        genScreenshotTargetPopup.selectItem(withTag: pref.screenshotTargetIntValue)
                
        // Screen captures
        let hasFFmpeg = emu.recorder.hasFFmpeg
        genFFmpegPath.stringValue = emu.recorder.path
        genFFmpegPath.textColor = hasFFmpeg ? .textColor : .warning
        genSource.selectItem(withTag: pref.captureSourceIntValue)
        genBitRate.stringValue = "\(pref.bitRate)"
        genAspectX.integerValue = pref.aspectX
        genAspectY.integerValue = pref.aspectY
        genSource.isEnabled = hasFFmpeg
        genBitRate.isEnabled = hasFFmpeg
        genAspectX.isEnabled = hasFFmpeg
        genAspectY.isEnabled = hasFFmpeg
        
        // Fullscreen
        genAspectRatioButton.state = pref.keepAspectRatio ? .on : .off
        genExitOnEscButton.state = pref.exitOnEsc ? .on : .off
                
        // Miscellaneous
        genEjectWithoutAskingButton.state = pref.ejectWithoutAsking ? .on : .off
        genDetachWithoutAskingButton.state = pref.detachWithoutAsking ? .on : .off
        genCloseWithoutAskingButton.state = pref.closeWithoutAsking ? .on : .off
        genPauseInBackground.state = pref.pauseInBackground ? .on : .off
    }

    func selectGeneralTab() {

        refreshGeneralTab()
    }

    //
    // Action methods (Snapshots)
    //
    
    @IBAction func genSnapshotStorageAction(_ sender: NSTextField!) {

        if sender.integerValue > 0 {
            pref.snapshotStorage = sender.integerValue
        }
        refresh()
    }

    @IBAction func genAutoSnapshotAction(_ sender: NSButton!) {

        pref.autoSnapshots = sender.state == .on
        refresh()
    }

    @IBAction func genSnapshotIntervalAction(_ sender: NSTextField!) {
        
        if sender.integerValue > 0 {
            pref.snapshotInterval = sender.integerValue
        }
        refresh()
    }
    
    //
    // Action methods (Screenshots)
    //

    @IBAction func genScreenshotSourceAction(_ sender: NSPopUpButton!) {
        
        pref.screenshotSource = sender.selectedTag()
        refresh()
    }
    
    @IBAction func genScreenshotTargetAction(_ sender: NSPopUpButton!) {
        
        pref.screenshotTargetIntValue = sender.selectedTag()
        refresh()
    }

    //
    // Action methods (Screen captures)
    //
    
    @IBAction func genPathAction(_ sender: NSComboBox!) {

        let path = sender.stringValue
        pref.ffmpegPath = path
        refresh()
        
        // Display a warning if the recorder is inaccessible
        let fm = FileManager.default
        if fm.fileExists(atPath: path), !fm.isExecutableFile(atPath: path) {

            parent.showAlert(.recorderSandboxed(exec: path), window: window)
        }
    }
        
    @IBAction func capSourceAction(_ sender: NSPopUpButton!) {
        
        pref.captureSourceIntValue = sender.selectedTag()
        refresh()
    }

    @IBAction func genBitRateAction(_ sender: NSComboBox!) {
        
        var input = sender.objectValueOfSelectedItem as? Int
        if input == nil { input = sender.integerValue }
        
        if let bitrate = input {
            pref.bitRate = bitrate
        }
        refresh()
    }

    @IBAction func genAspectXAction(_ sender: NSTextField!) {
        
        pref.aspectX = sender.integerValue
        refresh()
    }

    @IBAction func genAspectYAction(_ sender: NSTextField!) {
        
        pref.aspectY = sender.integerValue
        refresh()
    }
    
    //
    // Action methods (Fullscreen)
    //
    
    @IBAction func genAspectRatioAction(_ sender: NSButton!) {
        
        pref.keepAspectRatio = (sender.state == .on)
        refresh()
    }

    @IBAction func genExitOnEscAction(_ sender: NSButton!) {
        
        pref.exitOnEsc = (sender.state == .on)
        refresh()
    }
    
    //
    // Action methods (Miscellaneous)
    //
    
    @IBAction func genEjectWithoutAskingAction(_ sender: NSButton!) {
        
        pref.ejectWithoutAsking = (sender.state == .on)
        refresh()
    }

    @IBAction func genDetachWithoutAskingAction(_ sender: NSButton!) {
        
        pref.detachWithoutAsking = (sender.state == .on)
        refresh()
    }
    
    @IBAction func genCloseWithoutAskingAction(_ sender: NSButton!) {
        
        pref.closeWithoutAsking = (sender.state == .on)
        for c in myAppDelegate.controllers {
            c.needsSaving = c.emu.running
        }
        refresh()
    }

    @IBAction func genPauseInBackgroundAction(_ sender: NSButton!) {
        
        pref.pauseInBackground = (sender.state == .on)
        refresh()
    }

    //
    // Action methods (Misc)
    //
    
    @IBAction func generalPresetAction(_ sender: NSPopUpButton!) {
        
        assert(sender.selectedTag() == 0)
                        
        // Revert to standard settings
        EmulatorProxy.defaults.removeGeneralUserDefaults()
                        
        // Apply the new settings
        pref.applyGeneralUserDefaults()
        
        refresh()
    }
}
