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
    puts "Reading \"#{blockname}\" block..."
    @outf.puts "Reading \"#{blockname}\" block...\n"
    true
  end

  def SkippingBlock(blockname)
    puts "Skipping unknown block (#{blockname})..."
    @outf.puts "Skipping unknown block (#{blockname})..."
    true
  end

  def OutputComment(msg)
    @outf.puts msg
  end

  def NexusError(msg, pos, line, col)
    STDERR.puts "\nError found at line #{line}, column #{col} (file position #{pos}): #{msg}"
    exit
  end

end

class MyToken < Ncl::NxsToken

  def initialize(is, os)
    super(is.read)
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

  nexus.outf.puts taxa.Report
  nexus.outf.puts trees.Report
end

main()

