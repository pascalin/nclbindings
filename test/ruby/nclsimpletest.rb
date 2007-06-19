#!/usr/bin/env ruby

require 'ncl'

class MyReader < Ncl::NxsReader
  attr_accessor :inf, :outf
  def initialize(infname, outfname)
    super()
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
    STDERR << '\nError found at line #{line}, column #{col} (file position #{pos}): #{msg}'
    exit
  end

end

class MyToken < Ncl::NxsToken
  def initialize(is, os)
    super(is)
    @out = os
  end

  def OutputComment(msg)
    puts msg
    @out << msg+'\n'
  end
end

def main
  taxa = Ncl::NxsTaxaBlock.new
  trees = Ncl::NxsTreesBlock.new(taxa)
    
  nexus = MyReader.new(ARGV[0], ARGV[1])
  nexus.Add(taxa)
  nexus.Add(trees)

  token = MyToken.new(nexus.inf, nexus.outf)
  nexus.Execute(token)

  taxa.Report(nexus.outf)
  trees.Report(nexus.outf)
end

main()

