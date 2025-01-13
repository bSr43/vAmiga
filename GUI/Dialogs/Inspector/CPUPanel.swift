// -----------------------------------------------------------------------------
// This file is part of vAmiga
//
// Copyright (C) Dirk W. Hoffmann. www.dirkwhoffmann.de
// Licensed under the GNU General Public License v3
//
// See https://www.gnu.org for license information
// -----------------------------------------------------------------------------

extension Inspector {

    private func cacheCPU() {

        cpuInfo = emu.paused ? emu.cpu.info : emu.cpu.cachedInfo
    }

    func refreshCPU(count: Int = 0, full: Bool = false) {

        cacheCPU()

        if full {
            let elements = [ cpuPC: fmt32,

                            cpuIRD: fmt16,
                            cpuIRC: fmt16,

                            cpuISP: fmt32,
                            cpuMSP: fmt32,
                            cpuUSP: fmt32,

                            cpuVBR: fmt32,

                            cpuSFC: fmt4,
                            cpuDFC: fmt4,
                           cpuCACR: fmt32,
                           cpuCAAR: fmt32,

                             cpuD0: fmt32, cpuD1: fmt32,
                             cpuD2: fmt32, cpuD3: fmt32,
                             cpuD4: fmt32, cpuD5: fmt32,
                             cpuD6: fmt32, cpuD7: fmt32,

                             cpuA0: fmt32, cpuA1: fmt32,
                             cpuA2: fmt32, cpuA3: fmt32,
                             cpuA4: fmt32, cpuA5: fmt32,
                             cpuA6: fmt32, cpuA7: fmt32
            ]

            for (c, f) in elements { assignFormatter(f, c!) }

            let style = emu.get(.CPU_DASM_SYNTAX)
            cpuDasmStyle1.selectItem(withTag: style)
            cpuDasmStyle2.selectItem(withTag: style)

            let dasmRev = emu.get(.CPU_DASM_REVISION)
            cpuDasmRev1.selectItem(withTag: dasmRev)
            cpuDasmRev2.selectItem(withTag: dasmRev)

            let rev = CPURevision(rawValue: emu.get(.CPU_REVISION))
            let below10 = rev == ._68000
            let below20 = rev == ._68000 || rev == ._68010
            cpuMSP.isHidden = below20
            cpuVBR.isHidden = below10
            cpuSFC.isHidden = below10
            cpuDFC.isHidden = below10
            cpuCACR.isHidden = below20
            cpuCAAR.isHidden = below20
            cpuMSPlabel.isHidden = below20
            cpuVBRlabel.isHidden = below10
            cpuSFClabel.isHidden = below10
            cpuDFClabel.isHidden = below10
            cpuCACRlabel.isHidden = below20
            cpuCAARlabel.isHidden = below20
            cpuT1label.stringValue = below20 ? "T" : "T1"
            cpuT0label.stringValue = below20 ? "-" : "T0"
            cpuT0.isHidden = below20
            cpuMlabel.stringValue = below20 ? "-" : "M"
            cpuM.isHidden = below20
        }

        cpuPC.integerValue = Int(cpuInfo.pc0)

        cpuIRD.integerValue = Int(cpuInfo.ird)
        cpuIRC.integerValue = Int(cpuInfo.irc)

        cpuISP.integerValue = Int(cpuInfo.isp)
        cpuUSP.integerValue = Int(cpuInfo.usp)
        cpuMSP.integerValue = Int(cpuInfo.msp)

        cpuVBR.integerValue = Int(cpuInfo.vbr)

        cpuSFC.integerValue = Int(cpuInfo.sfc)
        cpuDFC.integerValue = Int(cpuInfo.dfc)
        cpuCACR.integerValue = Int(cpuInfo.cacr)
        cpuCAAR.integerValue = Int(cpuInfo.caar)

        cpuD0.integerValue = Int(cpuInfo.d.0)
        cpuD1.integerValue = Int(cpuInfo.d.1)
        cpuD2.integerValue = Int(cpuInfo.d.2)
        cpuD3.integerValue = Int(cpuInfo.d.3)
        cpuD4.integerValue = Int(cpuInfo.d.4)
        cpuD5.integerValue = Int(cpuInfo.d.5)
        cpuD6.integerValue = Int(cpuInfo.d.6)
        cpuD7.integerValue = Int(cpuInfo.d.7)

        cpuA0.integerValue = Int(cpuInfo.a.0)
        cpuA1.integerValue = Int(cpuInfo.a.1)
        cpuA2.integerValue = Int(cpuInfo.a.2)
        cpuA3.integerValue = Int(cpuInfo.a.3)
        cpuA4.integerValue = Int(cpuInfo.a.4)
        cpuA5.integerValue = Int(cpuInfo.a.5)
        cpuA6.integerValue = Int(cpuInfo.a.6)
        cpuA7.integerValue = Int(cpuInfo.a.7)

        let sr = Int(cpuInfo.sr)
        let ipl = Int(cpuInfo.ipl)
        let fc = Int(cpuInfo.fc)

        cpuT1.state = (sr & 0b1000000000000000 != 0) ? .on : .off
        cpuT0.state = (sr & 0b0100000000000000 != 0) ? .on : .off
        cpuS.state  = (sr & 0b0010000000000000 != 0) ? .on : .off
        cpuM.state  = (sr & 0b0001000000000000 != 0) ? .on : .off
        cpuI2.state = (sr & 0b0000010000000000 != 0) ? .on : .off
        cpuI1.state = (sr & 0b0000001000000000 != 0) ? .on : .off
        cpuI0.state = (sr & 0b0000000100000000 != 0) ? .on : .off
        cpuX.state  = (sr & 0b0000000000010000 != 0) ? .on : .off
        cpuN.state  = (sr & 0b0000000000001000 != 0) ? .on : .off
        cpuZ.state  = (sr & 0b0000000000000100 != 0) ? .on : .off
        cpuV.state  = (sr & 0b0000000000000010 != 0) ? .on : .off
        cpuC.state  = (sr & 0b0000000000000001 != 0) ? .on : .off

        cpuIPL2.state = (ipl & 0b100 != 0) ? .on : .off
        cpuIPL1.state = (ipl & 0b010 != 0) ? .on : .off
        cpuIPL0.state = (ipl & 0b001 != 0) ? .on : .off

        cpuFC2.state = (fc & 0b100 != 0) ? .on : .off
        cpuFC1.state = (fc & 0b010 != 0) ? .on : .off
        cpuFC0.state = (fc & 0b001 != 0) ? .on : .off

        cpuHalt.state = cpuInfo.halt ? .on : .off

        cpuInstrView.refresh(count: count, full: full, addr: Int(cpuInfo.pc0))
        cpuTraceView.refresh(count: count, full: full)
        cpuBreakView.refresh(count: count, full: full)
        cpuWatchView.refresh(count: count, full: full)
    }

    @IBAction func cpuClearTraceBufferAction(_ sender: NSButton!) {

        emu.cpu.clearLog()
        refreshCPU(full: true)
    }
    
    @IBAction func cpuGotoAction(_ sender: NSSearchField!) {

        if sender.stringValue == "" {
            cpuInstrView.jumpTo(addr: Int(cpuInfo.pc0))
        } else if let addr = Int(sender.stringValue, radix: 16) {
            cpuInstrView.jumpTo(addr: addr)
        } else {
            sender.stringValue = ""
        }
    }

    @IBAction func cpuSyntaxAction(_ sender: NSPopUpButton!) {

        emu.set(.CPU_DASM_SYNTAX, value: sender.selectedTag())
    }

    @IBAction func cpuDasmRevAction(_ sender: NSPopUpButton!) {

        emu.set(.CPU_DASM_REVISION, value: sender.selectedTag())
    }
}
