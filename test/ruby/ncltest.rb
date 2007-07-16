#!/usr/bin/env ruby

require 'ncl'


# MyToken is derived from NxsToken in order to provide a way to
# report printable NEXUS comments (the square-bracket comments in
# NEXUS files that begin with an exclamation point and are intended
# to be printed in the output).
class MyToken < Ncl::NxsToken

  def initialize(ins, outs)
    super(ins.read())
    @out = outs
  end
  
  def OutputComment(msg)
    print msg
    @out.puts msg
  end

end


# This class represents a NEXUS file reader that supervises the
# interpretation of a NEXUS-formatted data file. It overloads
# several important virtual base class functions, including
# EnteringBlock and ExitingBlock (which allow it to inform the user
# when particular blocks are being entered or exited),
# ExecuteStarting and ExecuteStopping (which allow any
# initialization before a NEXUS file is read or cleanup afterwards,
# respectively), SkippingBlock and SkippingDisabledBlock (which
# allow user to be informed when unknown NEXUS blocks are
# encountered in the data file or when NEXUS blocks are encountered
# that are known to this application but are being skipped because
# these blocks were temporarily disabled), OutputComment (which
# determines how user-specified printable comments in NEXUS files
# are displayed), and NexusError (which determines how errors
# encountered in the NEXUS data file are to be reported).
class MyNexusFileReader < Ncl::NxsReader
  attr_accessor :infile_exists, :inf, :outf
  def initialize(infname, outfname)
    super()
    @infile_exists = true
    @infile_exists = false if not FileTest.exists? infname
    @inf = File.open(infname, 'r') if @infile_exists
    @outf = File.open(outfname, 'w')
  end

  def EnteringBlock(blockName)
    puts "Reading \"#{blockName}\" block..."
    @outf.puts "Reading \"#{blockName}\" block..."
    return true
  end

  def	ExitingBlock(blockName)
    puts "Finished with \"#{blockName}\" block."
    @outf.puts "Finished with \"#{blockName}\" block."
  end

  def	SkippingBlock(blockName)
    puts "Skipping unknown block (\"#{blockName}\")..."
    @outf.puts "Skipping unknown block (\"#{blockName}\")..."
  end

  def SkippingDisabledBlock(blockName)
    puts "Skipping disabled block (\"#{blockName}\")..."
    @outf.puts "Skipping disabled block (\"#{blockName}\")..."
  end

  def OutputComment(s)
    puts "\n#{s}"
    @outf.puts "\n#{s}"
  end

  def DebugReportBlock(nexusBlock)
    if not nexusBlock.IsEmpty?
      @outf.puts "\n********** Contents of the #{nexusBlock.GetID} block **********"
      @outf.puts nexusBlock.Report
    end
  end

  def	NexusError(msg, pos, line, col)
    STDERR.puts "\nError found at line #{line}, column #{col} (file position #{pos}): #{msg}"
    @out.puts "\nError found at line #{line}, column #{col} (file position #{pos}): #{msg}"
    STDERR.puts "Press return to quit..."
    #raw_input()
  end
end

  
# This derived version of NxsCharactersBlock is necessary in
# order to provide for the use of an ostream to give feedback to the
# user and report on the information contained in any CHARACTERS
# blocks found. It overloads the base class virtual function
# SkippingCommand
class MyCharactersBlock < Ncl::NxsCharactersBlock

    def initialize(taxab, assumb, o)
      super(taxab, assumb)
      @outf = o
    end

    def SkippingCommand(s)
      puts "Skipping unknown command (#{s})..."
      @outf.puts "Skipping unknown command (#{s})..."
    end

  end


# This derived version of NxsDataBlock is necessary in order to
# provide for the use of an ostream to give feedback to the user and
# report on the information contained in any DATA blocks found. It
# overloads the base class virtual function SkippingCommand
class MyDataBlock < Ncl::NxsDataBlock

    def initialize(taxab, assumb, o)
      super(taxab, assumb)
      @outf = o
    end

    def SkippingCommand(s)
      puts "Skipping unknown command (#{s})..."
      @outf.puts "Skipping unknown command (#{s})..."
    end
end


# This derived version of NxsAssumptionsBlock was created in
# order to provide feedback to the user on commands that are not yet
# impemented (much of the NxsAssumptionsBlock is not yet
# implemented, and the NxsAssumptionsBlock version of
# SkippingCommand is simply the one it inherited from NxsBlock,
# which does nothing).
class MyAssumptionsBlock < Ncl::NxsAssumptionsBlock

  def initialize(taxab, o)
    super(taxab)
    @outf = o
  end

  def SkippingCommand(s)
    puts "Skipping unknown command (#{s})..."
    @outf.puts "Skipping unknown command (#{s})..."
  end
end


def main()
  infname = "characters.nex"
  outfname = "output.txt"
  infname = ARGV[0] if ARGV.length > 0
  outfname = ARGV[1] if ARGV.length > 1

  nexus = MyNexusFileReader.new(infname, outfname)
  if not nexus.infile_exists
    outf = File.open(outfname, 'w')
    outf.puts "Error: specified input file (#{infname}) does not exist."
    outf.close
    STDERR.puts "Error: specified input file (#{infname}) does not exist."
    STDERR.puts "Press return to quit..."
    #raw_input()
    exit
  end

  taxa = Ncl::NxsTaxaBlock.new
  assumptions = MyAssumptionsBlock.new(taxa, nexus.outf)
  trees = Ncl::NxsTreesBlock.new(taxa)
  characters = MyCharactersBlock.new(taxa, assumptions, nexus.outf)
  data = MyDataBlock.new(taxa, assumptions, nexus.outf)
  distances = Ncl::NxsDistancesBlock.new(taxa)
    
  nexus.Add taxa
  nexus.Add assumptions
  nexus.Add trees
  nexus.Add characters
  nexus.Add data
  nexus.Add distances

  token = MyToken.new(nexus.inf, nexus.outf)
  nexus.Execute(token)

  nexus.outf.puts "\nReports follow on all blocks currently in memory."

  nexus.outf.puts taxa.Report if not taxa.IsEmpty?
  nexus.outf.puts trees.Report if not trees.IsEmpty?
  nexus.outf.puts characters.Report if not characters.IsEmpty?
  nexus.outf.puts data.Report if not data.IsEmpty?
  nexus.outf.puts distances.Report if not distances.IsEmpty?
  nexus.outf.puts assumptions.Report if not assumptions.IsEmpty?

  nexus.outf.puts
  assumptions.GetTaxSetNames.each do |name|
    nexus.outf.puts "Taxset #{name}: "
    assumptions.GetTaxSet(name).each {|taxset|
      nexus.outf.write "#{taxset+1} "
    }
    nexus.outf.puts
  end

  assumptions.GetCharSetNames.each do |name|
    nexus.outf.puts "Charset #{name}: "
    assumptions.GetCharSet(name).each {|charset|
      nexus.outf.write "#{charset+1} "
    }
    nexus.outf.puts
  end

  assumptions.GetExSetNames.each do |name|
    nexus.outf.puts "Exset #{name}: "
    assumptions.GetExSet(name).each {|exset|
      nexus.outf.write "#{exset+1} "
    }
    nexus.outf.puts
  end

#   sys.stderr.write("\n")
#   sys.stderr.write("Press return to quit...\n")
#   raw_input()

  return 0

end

main()
