class Hoe #:nodoc:
  module Git
    class Changelog
      attr_reader :log_text
      attr_reader :changes
      attr_accessor :version
      def initialize(log_text,options=Hash.new)
        defaults={:io=>STDOUT, :log_author=>false, :version=>"NEXT", :now=>Time.new.strftime("%Y-%m-%d")}
        opts=defaults.merge options
        @io=opts[:io]
        @now=opts[:now]
        @version=opts[:version]
        @log_author=opts[:log_author]
        @log_text=log_text
      end
      
      def process 
        raw_changes = @log_text.split(/\|\|\|/).each_slice(3).map do |msg, author, email|
          out=msg.split(/\n/).reject { |s| s.empty? }
          out=out.map {|v| "#{v} [#{author}]"} if out.size>0 and @log_author
          out
        end

        raw_changes = raw_changes.flatten

        return false if raw_changes.empty?
        @changes = Hash.new { |h,k| h[k] = [] }

        codes = {
          "!" => :major,
          "+" => :minor,
          "*" => :minor,
          "-" => :bug,
          "?" => :unknown,
        }

        codes_re = Regexp.escape codes.keys.join

        raw_changes.each do |change|
          if change =~ /^\s*([#{codes_re}])\s*(.*)/ then
            code, line = codes[$1], $2
          else
            code, line = codes["?"], change.chomp
          end

          @changes[code] << line
        end

        @io << "=== #{@version} / #{@now}\n"
        @io << "\n"
        changelog_section :major
        changelog_section :minor
        changelog_section :bug
        changelog_section :unknown
        @io << "\n"
      end
      def changelog_section code
        name = {
          :major   => "major enhancement",
          :minor   => "minor enhancement",
          :bug     => "bug fix",
          :unknown => "unknown",
        }[code]

        local_changes = @changes[code]
        count = local_changes.size
        name += "s" if count > 1
        name.sub!(/fixs/, 'fixes')

        return if count < 1

        @io <<  "* #{count} #{name}:\n"
        @io << "\n"
        local_changes.sort.each do |line|
          @io << "  * #{line}\n"
        end
        @io << "\n"
    end
    end
  end
  end  
