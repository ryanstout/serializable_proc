require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Multiple arities serializable proc' do

  extend SerializableProc::Spec::Macros

  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { |arg1, arg2| [\"a\", \"b\"].map { |x| puts(x) } }"

  should_handle_proc_variable expected_file, expected_code, {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do |arg1, arg2|
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        lambda { |arg1, arg2|
          %w{a b}.map{|x|
            puts x
          }
        },
      __LINE__ =>
        proc do |arg1, arg2|
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        lambda { |arg1, arg2|
          %w{a b}.map{|x|
            puts x
          }
        },
      __LINE__ =>
        Proc.new do |arg1, arg2|
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        Proc.new { |arg1, arg2|
          %w{a b}.map{|x|
            puts x
          }
        },
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do |arg1, arg2|
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        lambda { |arg1, arg2|
          %w{a b}.map{|x| puts x }
        },
      __LINE__ =>
        proc do |arg1, arg2|
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        lambda { |arg1, arg2|
          %w{a b}.map{|x| puts x }
        },
      __LINE__ =>
        Proc.new do |arg1, arg2|
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        Proc.new { |arg1, arg2|
          %w{a b}.map{|x| puts x }
        },
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do |arg1, arg2| %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        lambda { |arg1, arg2| %w{a b}.map{|x| puts x } },
      __LINE__ =>
        proc do |arg1, arg2| %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        lambda { |arg1, arg2| %w{a b}.map{|x| puts x } },
      __LINE__ =>
        Proc.new do |arg1, arg2| %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        Proc.new { |arg1, arg2| %w{a b}.map{|x| puts x } },
    }

  should "handle block using do ... end [##{__LINE__}]" do
    (
      SerializableProc.new do |arg1, arg2|
        %w{a b}.map{|x| puts x }
      end
    ).should.be having_expected_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using do ... end [##{__LINE__}]" do
    (SerializableProc.new do |arg1, arg2| %w{a b}.map{|x| puts x } end).
      should.be having_expected_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (
      SerializableProc.new { |arg1, arg2|
        %w{a b}.map{|x| puts x }
      }
    ).should.be having_expected_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (SerializableProc.new { |arg1, arg2| %w{a b}.map{|x| puts x } }).
      should.be having_expected_attrs(expected_file, __LINE__.pred, expected_code)
  end

end