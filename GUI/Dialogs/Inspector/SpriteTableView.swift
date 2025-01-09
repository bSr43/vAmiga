// -----------------------------------------------------------------------------
// This file is part of vAmiga
//
// Copyright (C) Dirk W. Hoffmann. www.dirkwhoffmann.de
// Licensed under the GNU General Public License v3
//
// See https://www.gnu.org for license information
// -----------------------------------------------------------------------------

class SpriteTableView: NSTableView {

    @IBOutlet weak var inspector: Inspector!
    var deniseInfo: DeniseInfo { return inspector.deniseInfo }
    var spriteInfo: SpriteInfo { return inspector.spriteInfo }

    var amiga: EmulatorProxy!

    var spriteDat = [UInt64](repeating: 0, count: VAMIGA.VPOS.CNT)
    var spriteCol = [NSColor](repeating: NSColor.white, count: 16)
    var spriteLines = 0

    override func awakeFromNib() {

        amiga = inspector.emu
        delegate = self
        dataSource = self
        target = self
    }

    private func cache() {

        spriteCol[0] = NSColor(amigaRGB: spriteInfo.colors.0)
        spriteCol[1] = NSColor(amigaRGB: spriteInfo.colors.1)
        spriteCol[2] = NSColor(amigaRGB: spriteInfo.colors.2)
        spriteCol[3] = NSColor(amigaRGB: spriteInfo.colors.3)
        spriteCol[4] = NSColor(amigaRGB: spriteInfo.colors.4)
        spriteCol[5] = NSColor(amigaRGB: spriteInfo.colors.5)
        spriteCol[6] = NSColor(amigaRGB: spriteInfo.colors.6)
        spriteCol[7] = NSColor(amigaRGB: spriteInfo.colors.7)
        spriteCol[8] = NSColor(amigaRGB: spriteInfo.colors.8)
        spriteCol[9] = NSColor(amigaRGB: spriteInfo.colors.9)
        spriteCol[10] = NSColor(amigaRGB: spriteInfo.colors.10)
        spriteCol[11] = NSColor(amigaRGB: spriteInfo.colors.11)
        spriteCol[12] = NSColor(amigaRGB: spriteInfo.colors.12)
        spriteCol[13] = NSColor(amigaRGB: spriteInfo.colors.13)
        spriteCol[14] = NSColor(amigaRGB: spriteInfo.colors.14)
        spriteCol[15] = NSColor(amigaRGB: spriteInfo.colors.15)

        spriteLines = spriteInfo.height
        for i in 0 ..< spriteLines { spriteDat[i] = (spriteInfo.data + i).pointee }
    }

    func refresh(count: Int = 0, full: Bool = false) {

        if count % 4 != 0 { return }

        cache()

        if full {
            for (c, f) in ["addr": Inspector.fmt24] {
                let columnId = NSUserInterfaceItemIdentifier(rawValue: c)
                if let column = tableColumn(withIdentifier: columnId) {
                    if let cell = column.dataCell as? NSCell {
                        cell.formatter = f
                    }
                }
            }
        }

        reloadData()
    }
}

extension SpriteTableView: NSTableViewDataSource {
    
    func colorIndex(tableColumn: NSTableColumn?, row: Int) -> Int? {
       
        if let id = tableColumn?.identifier.rawValue, let nr = Int(id) {

            let data = spriteDat[row] & 0xFFFF
            let bita = (data & (0x8000 >> nr)) != 0

            let datb = (spriteDat[row] >> 16) & 0xFFFF
            let bitb = (datb & (0x8000 >> nr)) != 0

            return (bita ? 1 : 0) + (bitb ? 2 : 0)
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {

        return spriteLines > 0 ? spriteLines - 1 : 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        return nil
    }
}

extension SpriteTableView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        
        let cell = cell as? NSTextFieldCell
        if let index = colorIndex(tableColumn: tableColumn, row: row) {

            var color = NSColor.alternatingContentBackgroundColors[1]
            switch inspector.selectedSprite {
                
            case 0, 1:
                switch index {
                case 1: color = spriteCol[1]
                case 2: color = spriteCol[2]
                case 3: color = spriteCol[3]
                default: break
                }
                
            case 2, 3:
                switch index {
                case 1: color = spriteCol[5]
                case 2: color = spriteCol[6]
                case 3: color = spriteCol[7]
                default: break
                }
                
            case 4, 5:
                switch index {
                case 1: color = spriteCol[9]
                case 2: color = spriteCol[10]
                case 3: color = spriteCol[11]
                default: break
                }
                
            default:
                switch index {
                case 1: color = spriteCol[13]
                case 2: color = spriteCol[14]
                case 3: color = spriteCol[15]
                default: break
                }
            }
            
            cell?.backgroundColor = color
        }
    }
}
