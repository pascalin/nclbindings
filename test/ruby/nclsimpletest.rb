#!/usr/bin/env ruby

require 'ncl'

class MyReader < ncl.NxsReader
  def initialize(infname, outfname)
    super
    @inf = File.open(infname, 'r')
    @outf = File.open(outfname, 'w')
  end

  def EnteringBlock(blockname)
    puts 'Reading "#{blockname}" block...'
    @outf << 'Reading "#{blockname}" block...\n'
    true
  end

  def SkippingBlock(blockname)
    puts 'Skipping unknown block ("#{blockname}")...'
    @outf << 'Skipping unknown block ("#{blockname}")...'
    true
  end

  def OutputComment(msg)
    @outf << msg
  end

  def NexusError(msg, pos, line, col)
    #sys.stderr.write('\nError found at line %d, column %d (file position %d): %s' % (line, col, pos, msg))
    exit
  end

end

class MyToken < ncl.NxsToken
  def initialize(is, os)
    super(is)
    @out = os
  end

  def OutputComment(msg)
    puts msg
    @out << msg+'\n'
  end

def main
  taxa = ncl.NxsTaxaBlock.new
  trees = ncl.NxsTreesBlock.new
    
  nexus = MyReader.new(ARGV[0], ARGV[1])
  nexus.Add(taxa)
  nexus.Add(trees)

  token = MyToken.new(nexus.inf, nexus.outf)
  nexus.Execute(token)

  taxa.Report(nexus.outf)
  trees.Report(nexus.outf)

main()
