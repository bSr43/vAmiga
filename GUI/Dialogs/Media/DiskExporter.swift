// -----------------------------------------------------------------------------
// This file is part of vAmiga
//
// Copyright (C) Dirk W. Hoffmann. www.dirkwhoffmann.de
// Licensed under the GNU General Public License v3
//
// See https://www.gnu.org for license information
// -----------------------------------------------------------------------------

@MainActor
class DiskExporter: DialogController {

    enum Format {
        
        static let adf = 0
        static let hdf = 1
        static let ext = 2
        static let img = 3
        static let ima = 4
        static let vol = 5
    }

    var myDocument: MyDocument { return parent.mydocument! }

    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var info1: NSTextField!
    @IBOutlet weak var info2: NSTextField!
    @IBOutlet weak var partitionPopup: NSPopUpButton!
    @IBOutlet weak var formatPopup: NSPopUpButton!
    @IBOutlet weak var exportButton: NSButton!
    
    // Panel for exporting files
    var savePanel: NSSavePanel!
    
    // Panel for exporting directories
    var openPanel: NSOpenPanel!

    // Reference to the export drive
    var dfn: FloppyDriveProxy?
    var hdn: HardDriveProxy?

    // The partition to export
    var partition: Int?

    // Number of available partitions
    var numPartitions: Int { return hdf?.hdfInfo.partitions ?? 1 }

    // Results of the different decoders
    var hdf: MediaFileProxy?
    var adf: MediaFileProxy?
    var ext: MediaFileProxy?
    var img: MediaFileProxy?
    var vol: FileSystemProxy?
    
    func showSheet(diskDrive nr: Int) {
                
        dfn = emu.df(nr)

        // Run the ADF decoder
        adf = try? MediaFileProxy.make(with: dfn!, type: .ADF)

        // Run the extended ADF decoder
        ext = try? MediaFileProxy.make(with: dfn!, type: .EADF)

        // Run the DOS decoder
        img = try? MediaFileProxy.make(with: dfn!, type: .IMG)

        // Select the export partition
        select(partition: 0)
        
        super.showAsSheet()
    }

    func showSheet(hardDrive nr: Int) {
                
        hdn = emu.hd(nr)

        // Run the HDF decoder
        hdf = try? MediaFileProxy.make(with: hdn!, type: .HDF)

        // Select the export partition
        select(partition: numPartitions == 1 ? 0 : nil)
        
        super.showAsSheet()
    }
    
    func select(partition nr: Int?) {

        partition = nr
        
        if hdf != nil && nr != nil {

            // Try to decode the file system from the HDF
            vol = try? FileSystemProxy.make(with: hdf!, partition: nr!)
        
        } else if adf != nil {

            // Try to decode the file system from the ADF
            vol = try? FileSystemProxy.make(with: adf!)

        } else {
               
            // Exporting to a folder is not possible
            vol = nil
        }
    }
    
    func updatePartitionPopup() {
        
        func addItem(_ title: String, tag: Int) {
            
            partitionPopup.addItem(withTitle: title)
            partitionPopup.lastItem?.tag = tag
        }

        partitionPopup.autoenablesItems = false
        partitionPopup.removeAllItems()

        addItem("Entire disk", tag: -1)

        if hdf?.hdfInfo.hasRDB == true {

            for i in 1...numPartitions {
                addItem("Partition \(i)", tag: i - 1)
            }
        }
    }
    
    func updateFormatPopup() {
        
        func addItem(_ title: String, tag: Int) {
            
            formatPopup.addItem(withTitle: title)
            formatPopup.lastItem?.tag = tag
        }
        
        formatPopup.autoenablesItems = false
        formatPopup.removeAllItems()
        if adf != nil { addItem("ADF", tag: Format.adf) }
        if hdf != nil { addItem("HDF", tag: Format.hdf) }
        if ext != nil { addItem("Extended ADF", tag: Format.ext) }
        if img != nil { addItem("IMG", tag: Format.img) }
        if img != nil { addItem("IMA", tag: Format.ima) }
        if vol != nil { addItem("Folder", tag: Format.vol) }
    }
        
    override func dialogWillShow() {

        super.dialogWillShow()
        
        updatePartitionPopup()
        updateFormatPopup()
        update()
    }
        
    func update() {
          
        // Update icons
        updateIcon()

        // Update disk description
        updateTitleText()
        updateInfo()
    }
    
    func updateIcon() {
                    
        switch formatPopup.selectedTag() {

        case Format.hdf:
            
            icon.image = hdf!.icon()
            
        case Format.adf, Format.ext, Format.img, Format.ima:
            
            let wp = dfn!.info.hasProtectedDisk

            icon.image =
            adf?.icon(protected: wp) ??
            img?.icon(protected: wp) ??
            ext?.icon(protected: wp) ?? nil

        case Format.vol:
            
            icon.image = NSImage(named: "NSFolder")
                        
        default:
            
            icon.image = nil
        }
            
        if icon.image == nil {
            icon.image = NSImage(named: "biohazard")
        }
    }
    
    func updateTitleText() {
                
        title.stringValue =
        hdf != nil ? "Amiga Hard Drive" :
        adf != nil ? "Amiga Floppy Disk" :
        ext != nil ? "Extended Amiga Disk" :
        img != nil ? "PC Disk" : "Unrecognized device"
    }

    func updateInfo() {
        
        if hdf != nil {
            updateHardDiskInfo()
        } else {
            updateFloppyDiskInfo()
        }
    }
    
    func updateHardDiskInfo() {

        let info = hdf!.hdfInfo

        let num = info.partitions
        let s = num == 1 ? "" : "s"
        
        if partition == nil {
            
            if info.hasRDB {
                info1.stringValue = "RDB hard drive with \(num) partition\(s)"
            } else {
                info1.stringValue = "Standard hard drive"
            }
            info2.stringValue = ""

        } else {
                
            info1.stringValue = "Partition \(partition! + 1) out of \(num)"
            if vol == nil {
                info2.stringValue = "No compatible file system"
            } else {
                info2.stringValue = vol!.dos.description
            }
        }
    }
        
    func updateFloppyDiskInfo() {

        if adf != nil {
            info1.stringValue = adf!.typeInfo + ", " + adf!.layoutInfo
        } else {
            info1.stringValue = ""
        }
        if vol != nil {
            info2.stringValue = vol!.dos.description
        } else {
            info2.stringValue = "No compatible file system"
        }
    }

    //
    // Action methods
    //
    
    @IBAction func formatAction(_ sender: NSPopUpButton!) {
        
        update()
    }

    @IBAction func partitionAction(_ sender: NSButton!) {

        let nr = partitionPopup.selectedTag()
        select(partition: nr >= 0 ? nr : nil)
        updateFormatPopup()
        update()
    }
    
    @IBAction func exportAction(_ sender: NSButton!) {
        
        switch formatPopup.selectedTag() {

        case Format.hdf: openExportToFilePanel(allowedTypes: ["hdf", "HDF"])
        case Format.adf: openExportToFilePanel(allowedTypes: ["adf", "ADF"])
        case Format.ext: openExportToFilePanel(allowedTypes: ["adf", "ADF"])
        case Format.img: openExportToFilePanel(allowedTypes: ["img", "IMG"])
        case Format.ima: openExportToFilePanel(allowedTypes: ["ima", "IMA"])
        case Format.vol: openExportToFolderPanel()

        default: fatalError()
        }
    }
    
    //
    // Exporting
    //
        
    func openExportToFilePanel(allowedTypes: [String]) {
             
        savePanel = NSSavePanel()
        savePanel.prompt = "Export"
        savePanel.title = "Export"
        savePanel.nameFieldLabel = "Export As:"
        savePanel.nameFieldStringValue = "Untitled." + allowedTypes.first!
        savePanel.canCreateDirectories = true

        savePanel.beginSheetModal(for: window!, completionHandler: { result in
            if result == .OK {
                if let url = self.savePanel.url {
                    self.export(url: url)
                }
            }
        })
    }

    func openExportToFolderPanel() {

        openPanel = NSOpenPanel()
        openPanel.prompt = "Export"
        openPanel.title = "Export"
        openPanel.nameFieldLabel = "Export As:"
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        
        openPanel.beginSheetModal(for: window!, completionHandler: { result in
            if result == .OK {
                if let url = self.openPanel.url {
                    self.export(url: url)
                }
            }
        })
    }
    
    func export(url: URL) {

        if hdf != nil {
            exportHardDisk(url: url)
        } else {
            exportFloppyDisk(url: url)
        }
        parent.refreshStatusBar()
    }
    
    func exportFloppyDisk(url: URL) {

        do {
            
            switch formatPopup.selectedTag() {

            case Format.adf:
                
                debug(.media, "Exporting ADF")
                try parent.mydocument.export(fileProxy: adf!, to: url)

            case Format.ext:
                
                debug(.media, "Exporting Extended ADF")
                try parent.mydocument.export(fileProxy: ext!, to: url)

            case Format.img:
                
                debug(.media, "Exporting IMG")
                try parent.mydocument.export(fileProxy: img!, to: url)

            case Format.ima:
                
                debug(.media, "Exporting IMA")
                try parent.mydocument.export(fileProxy: img!, to: url)

            case Format.vol:
                
                debug(.media, "Exporting file system")
                try vol!.export(url: url)
                
            default:
                fatalError()
            }
            
            dfn!.setFlag(.MODIFIED, value: false)
            myAppDelegate.noteNewRecentlyExportedDiskURL(url, df: dfn!.info.nr)
            
            hide()

        } catch {
            parent.showAlert(.cantExport(url: url), error: error, async: true, window: window)
        }
    }
    
    func exportHardDisk(url: URL) {
        
        do {

            switch formatPopup.selectedTag() {

            case Format.hdf:

                if let nr = partition {

                    debug(.media, "Exporting partiton \(nr) to \(url)")
                    try hdf?.writeToFile(url: url, partition: nr)

                } else {

                    debug(.media, "Exporting entire HDF to \(url)")
                    try hdf?.writeToFile(url: url)
                }

            case Format.vol:

                debug(.media, "Exporting file system")
                try vol!.export(url: url)

            default:
                fatalError()
            }

            hdn!.setFlag(.MODIFIED, value: false)
            myAppDelegate.noteNewRecentlyExportedHdrURL(url, hd: hdn!.traits.nr)
            
            hide()
            
        } catch {
            parent.showAlert(.cantExport(url: url), error: error, async: true, window: window)
        }
    }
}

//
// Protocols
//

@MainActor
extension DiskExporter: NSFilePromiseProviderDelegate {
   
    @MainActor
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        
        var name: String
        
        switch formatPopup.selectedTag() {
            
        case Format.hdf: name = "Untitled.hdf"
        case Format.adf: name = "Untitled.adf"
        case Format.ext: name = "Untitled.adf"
        case Format.img: name = "Untitled.img"
        case Format.ima: name = "Untitled.ima"
        case Format.vol: name = "Untitled"
            
        default: fatalError()
        }
        
        return name
    }
    
    @MainActor
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        
        export(url: url)
        completionHandler(nil)
    }
}
