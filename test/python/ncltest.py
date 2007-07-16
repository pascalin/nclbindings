#!/usr/bin/env python

import ncl
import os.path
import sys

class MyToken(ncl.NxsToken):
    '''MyToken is derived from NxsToken in order to provide a way to
    report printable NEXUS comments (the square-bracket comments in
    NEXUS files that begin with an exclamation point and are intended
    to be printed in the output).'''

    def __init__(self, ins, outs):
        ncl.NxsToken.__init__(self, ins.read())
        self.out = outs

    def OutputComment(self, msg):
        print msg
        self.out.write(msg+'\n')


class MyNexusFileReader(ncl.NxsReader):
    '''This class represents a NEXUS file reader that supervises the
    interpretation of a NEXUS-formatted data file. It overloads
    several important virtual base class functions, including
    EnteringBlock and ExitingBlock (which allow it to inform the user
    when particular blocks are being entered or exited),
    ExecuteStarting and ExecuteStopping (which allow any
    initialization before a NEXUS file is read or cleanup afterwards,
    respectively), SkippingBlock and SkippingDisabledBlock (which
    allow user to be informed when unknown NEXUS blocks are
    encountered in the data file or when NEXUS blocks are encountered
    that are known to this application but are being skipped because
    these blocks were temporarily disabled), OutputComment (which
    determines how user-specified printable comments in NEXUS files
    are displayed), and NexusError (which determines how errors
    encountered in the NEXUS data file are to be reported).'''

    def __init__(self, infname, outfname):
        ncl.NxsReader.__init__(self)
        self.infile_exists = True
        if not os.path.exists(infname):
            self.infile_exists = False
        if self.infile_exists:
            self.inf = open(infname, 'rb')
            self.outf = open(outfname, 'w')

    def EnteringBlock(self, blockName):
        print 'Reading "%s" block...' % blockName
        self.outf.write('Reading "%s" block...\n' % blockName)
        return True

    def	ExitingBlock(self, blockName):
        print 'Finished with "%s" block.' % blockName
        self.outf.write('Finished with "%s" block.\n' % blockName)

    def	SkippingBlock(self, blockName):
        print 'Skipping unknown block ("%s")...' % blockName
        self.outf.write('Skipping unknown block ("%s")...\n' % blockName)

    def SkippingDisabledBlock(self, blockName):
        print 'Skipping disabled block ("%s")...' % blockName
        self.outf.write('Skipping disabled block ("%s")...\n' % blockName)

    def OutputComment(self, s):
        print
        print s
        self.outf.write("\n%s\n" % s)

    def DebugReportBlock(self, nexusBlock):
        if not nexusBlock.IsEmpty():
            self.outf.write("\n********** Contents of the %s block **********\n" % nexusBlock.GetID())
            self.outf.write(nexusBlock.Report())

    def	NexusError(self, msg, pos, line, col):
        sys.stderr.write('\nError found at line %d, column %d (file position %d): %s' %
                         (line, col, pos, msg))
        self.out.write('\nError found at line %d, column %d (file position %d): %s' %
                       (line, col, pos, msg))
        sys.stderr.write("Press return to quit...\n")
        raw_input()


class MyCharactersBlock(ncl.NxsCharactersBlock):
    '''This derived version of NxsCharactersBlock is necessary in
    order to provide for the use of an ostream to give feedback to the
    user and report on the information contained in any CHARACTERS
    blocks found. It overloads the base class virtual function
    SkippingCommand'''

    def __init__(self, taxab, assumb, o):
        ncl.NxsCharactersBlock.__init__(self, taxab, assumb)
        self.outf = o

    def SkippingCommand(self, s):
        print "Skipping unknown command (%s)..." % s
        self.outf.write("Skipping unknown command (%s)...\n" % s)


class MyDataBlock(ncl.NxsDataBlock):
    '''This derived version of NxsDataBlock is necessary in order to
    provide for the use of an ostream to give feedback to the user and
    report on the information contained in any DATA blocks found. It
    overloads the base class virtual function SkippingCommand'''

    def __init__(self, taxab, assumb, o):
        ncl.NxsDataBlock.__init__(self, taxab, assumb)
        self.outf = o

    def SkippingCommand(self, s):
        print "Skipping unknown command (%s)..." % s
        self.outf.write("Skipping unknown command (%s)...\n" % s)


class MyAssumptionsBlock(ncl.NxsAssumptionsBlock):
    '''This derived version of NxsAssumptionsBlock was created in
    order to provide feedback to the user on commands that are not yet
    impemented (much of the NxsAssumptionsBlock is not yet
    implemented, and the NxsAssumptionsBlock version of
    SkippingCommand is simply the one it inherited from NxsBlock,
    which does nothing).'''

    def __init__(self, taxab, o):
        ncl.NxsAssumptionsBlock.__init__(self, taxab)
        self.outf = o

    def SkippingCommand(s):
        print "Skipping unknown command (%s)..." % s
        self.outf.write("Skipping unknown command (%s)...\n" % s)

def main():
    infname = "characters.nex"
    outfname = "output.txt"
    if (len(sys.argv) > 1):
        infname = sys.argv[1]
    if (len(sys.argv) > 2):
        outfname = sys.argv[2]

    nexus = MyNexusFileReader(infname, outfname)
    if not nexus.infile_exists:
        outf=open(outfname, 'w')
        outf.write("Error: specified input file (%s) does not exist.\n" % infname)
        outf.close()
        sys.stderr.write("Error: specified input file (%s) does not exist.\n" % infname)
        sys.stderr.write("Press return to quit...\n")
        raw_input()
        sys.exit(0)

    taxa = ncl.NxsTaxaBlock()
    assumptions	= MyAssumptionsBlock(taxa, nexus.outf)
    trees = ncl.NxsTreesBlock(taxa)
    characters = MyCharactersBlock(taxa, assumptions, nexus.outf)
    data = MyDataBlock(taxa, assumptions, nexus.outf)
    distances = ncl.NxsDistancesBlock(taxa)
    
    nexus.Add(taxa)
    nexus.Add(assumptions)
    nexus.Add(trees)
    nexus.Add(characters)
    nexus.Add(data)
    nexus.Add(distances)

    token = MyToken(nexus.inf, nexus.outf)
    nexus.Execute(token)

    nexus.outf.write("\nReports follow on all blocks currently in memory.\n")

    if not taxa.IsEmpty():
        nexus.outf.write(taxa.Report())
    if not trees.IsEmpty():
        nexus.outf.write(trees.Report())
    if not characters.IsEmpty():
        nexus.outf.write(characters.Report())
    if not data.IsEmpty():
        nexus.outf.write(data.Report())
    if not distances.IsEmpty():
        nexus.outf.write(distances.Report())
    if not assumptions.IsEmpty():
        nexus.outf.write(assumptions.Report())

    nexus.outf.write("\n")
    z = assumptions.GetTaxSetNames()
    if z:
        for zi in z:
            nexus.outf.write("Taxset %s: " % zi)
            x = assumptions.GetTaxSet(zi)
            for xi in x:
                nexus.outf.write("%d " % (xi + 1))
            nexus.outf.write("\n")

    z = assumptions.GetCharSetNames()
    if z:
        for zi in z:
            nexus.outf.write("Charset %s: " % zi)
            x = assumptions.GetCharSet(zi)
            for xi in x:
                nexus.outf.write("%d " % (xi + 1))
            nexus.outf.write("\n")

    z = assumptions.GetExSetNames()
    if z:
        for zi in z:
            nexus.outf.write("Exset %s: " % zi)
            x = assumptions.GetExSet(zi)
            for xi in x:
                nexus.outf.write("%d " % (xi + 1))
            nexus.outf.write("\n")

#     sys.stderr.write("\n")
#     sys.stderr.write("Press return to quit...\n")
#     raw_input()

    return 0;

if __name__ == '__main__':
    main()
