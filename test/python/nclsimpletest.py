#!/usr/bin/env python
"Simple test script for NCL bindings"

import ncl
import sys

class MyReader(ncl.NxsReader):
    def __init__(self, infname, outfname):
        ncl.NxsReader.__init__(self)
        self.inf = open(infname, 'rb')
        self.outf = open(outfname, 'w')

    def EnteringBlock(blockname):
        print 'Reading "%s" block...' % blockname
        self.outf.write('Reading "%s" block...\n' % blockname)

        return True

    def SkippingBlock(blockname):
        print 'Skipping unknown block ("%s")...' % blockname
        self.outf.write('Skipping unknown block ("%s")...\n' % blockname)

        return True

    def OutputComment(msg):
        self.outf.write(msg)

    def NexusError(msg, pos, line, col):
        sys.stderr.write('\nError found at line %d, column %d (file position %d): %s' %
                         (line, col, pos, msg))
        sys.exit(0)


class MyToken(ncl.NxsToken):
    def __init__(self, is, os):
        ncl.NxsToken.__init__(self, is)
        self.out = os

    def OutputComment(msg):
        print msg
        self.out.write(msg+'\n')

def main():
    taxa = ncl.NxsTaxaBlock()
    trees = ncl.NxsTreesBlock(taxa)
    
    nexus = MyReader(sys.argv[1], sys.argv[2])
    nexus.Add(taxa)
    nexus.Add(trees)

    token = MyToken(nexus.inf, nexus.outf)
    nexus.Execute(token)

    taxa.Report(nexus.outf)
    trees.Report(nexus.outf)

if __name__ == '__main__':
    main()
