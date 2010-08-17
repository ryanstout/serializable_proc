class SerializableProc
  module Parsers

    RUBY_2_RUBY = Ruby2Ruby.new

    class Base
      class << self

        def sexp_derivatives(sexp, &fix_code)
          fsexp = Sandboxer.fsexp(sexp)
          fcode, code = [fsexp, sexp].map do |_sexp|
            code = RUBY_2_RUBY.process(Sexp.from_array(_sexp.to_a))
            block_given? ? fix_code.call(code) : code
          end
          [
            {:runnable => fcode, :extracted => code},
            {:runnable => fsexp, :extracted => sexp}
          ]
        end

      end
    end

  end
end

require 'serializable_proc/parsers/pt'
require 'serializable_proc/parsers/rp'
