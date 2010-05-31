# -------------------------------------------------------------------------
# gedcom.rb -- core module definition of GEDCOM-Ruby interface
# Copyright (C) 2003 Jamis Buck (jgb3@email.byu.edu)
# -------------------------------------------------------------------------
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------

#require '_gedcom'
require 'gedcom_date'
require 'stringio'

module GEDCOM
  attr_accessor :auto_concat

  # Possibly a better way to do this?
  VERSION = "0.2.1"
  
  class Parser
    def initialize &block
      @before = {}
      @after = {}
      @ctxStack = []
      @dataStack = []
      @curlvl = -1

      @auto_concat = true

      instance_eval(&block) if block_given?
    end

    def before tag, proc=nil, &block
      proc = check_proc_or_block proc, &block
      @before[[tag].flatten] = proc
    end

    def after tag, proc=nil, &block
      proc = check_proc_or_block proc, &block
      @after[[tag].flatten] = proc
    end

    def parse( file )
      case file
      when String
        if file =~ /\n/mo
          parse_string(file)
        else
          parse_file(file)
        end
      when IO
        parse_io(file)
      else
        raise ArgumentError.new("requires a String or IO")
      end
    end

    def context
      @ctxStack
    end


    protected
    
    def check_proc_or_block proc, &block
      unless proc or block_given?
        raise ArgumentError.new("proc or block required")
      end
      proc = method(proc) if proc.kind_of? Symbol
      proc ||= Proc.new(&block)
    end

    def parse_file(file)
      File.open( file, "r" ) do |io|
        parse_io(io)
      end
    end

    def parse_string(str)
      parse_io(StringIO.new(str))
    end

    def parse_io(io)
      rs = detect_rs(io)
      io.each_line(rs) do |line|
        level, tag, rest = line.chop.split( ' ', 3 )
        next if level.nil? or tag.nil?
        level = level.to_i

        if (tag == 'CONT' || tag == 'CONC') and @auto_concat
          concat_data tag, rest
          next
        end

        unwind_to level

        tag, rest = rest, tag if tag =~ /@.*@/

        @ctxStack.push tag
        @dataStack.push rest
        @curlvl = level

        do_before @ctxStack, rest
      end
      unwind_to -1
    end

    def unwind_to level
      while @curlvl >= level
        do_after @ctxStack, @dataStack.last
        @ctxStack.pop
        @dataStack.pop
        @curlvl -= 1
      end
    end

    def concat_data tag, rest
      if @dataStack[-1].nil? 
        @dataStack[-1] = rest
      else
        if @ctxStack[-1] == 'BLOB'
          @dataStack[-1] << rest
        else
          if tag == 'CONT'
            @dataStack[-1] << "\n" + rest
          elsif tag == 'CONC'
            old = @dataStack[-1].chomp
            @dataStack[-1] = old + rest
          end
        end
      end
    end

    def do_before tag, data
      if proc = @before[tag]
        proc.call data
      elsif proc = @before[ANY]
        proc.call tag, data
      end
    end

    def do_after tag, data
      if proc = @after[tag]
        proc.call data
      elsif proc = @after[ANY]
        proc.call tag, data
      end
    end

    ANY = [:any]

    # valid gedcom may use either of \r or \r\n as the record separator.
    # just in case, also detects simple \n as the separator as well
    # detects the rs for this string by scanning ahead to the first occurence
    # of either \r or \n, and checking the character after it
    def detect_rs io
      rs = "\x0d"
      mark = io.pos
      begin
        while ch = io.readchar
          case ch
          when 0x0d
            ch2 = io.readchar
            if ch2 == 0x0a
              rs = "\x0d\x0a"
            end
            break
          when 0x0a
            rs = "\x0a"
            break
          end
        end
      ensure
        io.pos = mark
      end
      rs
    end

  end #/ Parser

end #/ GEDCOM

