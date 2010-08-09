require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'ruby_parser'

class SerializableProc

  RUBY_PARSER = RubyParser.new
  RUBY_2_RUBY = Ruby2Ruby.new

  extend Forwardable
  %w{line file arity}.each{|meth| def_delegator :@proc, meth.to_sym }

  attr_reader :code

  def initialize(&block)
    @proc = Proc.new(block)
    @code = extract_code(Matcher.new(@proc))
  end

  def marshal_dump
    [@code, @proc]
  end

  def marshal_load(data)
    @code, @proc = data
  end

  private

    def eval!
      eval(@code, nil, @file, @line)
    end

    def extract_code(matcher)
      code, remaining = matcher.code_args
      while frag = matcher.next_frag(remaining)
        begin
          sexp = RUBY_PARSER.parse(escape_magic_vars(code += frag))
          if matcher.matching_sexp?(sexp.inspect)
            return unescape_magic_vars(RUBY_2_RUBY.process(sexp)).sub('proc {','lambda {')
          end
        rescue SyntaxError, Racc::ParseError, NoMethodError
          remaining.sub!(frag,'')
        end
      end
    end

    def escape_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(var, "%|((#{var}))|")
      end
    end

    def unescape_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(%|"((#{var}))"|, var)
      end
    end

    class Proc

      attr_reader :file, :line, :arity, :raw_code

      def initialize(block)
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
        @file, @line, @arity = File.expand_path(file), line.to_i, block.arity
        @raw_code = File.readlines(@file)[@line.pred .. -1].join
      end

    end

    class Matcher

      def initialize(context)
        @context = context
      end

      def code_args
        ignore, start_marker, arg = [:ignore, :start_marker, :arg].map{|key| match_args[key] }
        [
          arg ? "proc #{start_marker} |#{arg}|" : "proc #{start_marker}",
          @context.raw_code.sub(ignore, ''),
        ]
      end

      def next_frag(str)
        str[frag_regexp, 1]
      end

      def matching_sexp?(str)
        str =~ sexp_regexp
      end

      private

        def match_args
          @match_args ||= (
            args = @context.raw_code.match(code_regexp)
            {
              :ignore => args[1],
              :start_marker => args[3],
              :arg => args[5]
            }
          )
        end

        def sexp_regexp
          @sexp_regexp ||= (
            Regexp.new([
              Regexp.quote("s(:iter, s(:call, nil, :"),
              "(proc|lambda)",
              Regexp.quote(", s(:arglist)), "),
              '(%s|%s|%s)' % [
                Regexp.quote('s(:masgn, s(:array, s('),
                Regexp.quote('s(:lasgn, :'),
                Regexp.quote('nil, s(')
              ]
            ].join)
          )
        end

        def frag_regexp
          @frag_regexp ||= (
            end_marker = {'do' => 'end', '{' => '\}'}[match_args[:start_marker]]
            /^(.*?\W#{end_marker})/m
          )
        end

        def code_regexp
          @code_regexp ||=
            /^(.*?(SerializableProc\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
        end

    end

end
