require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Initializing errors' do

  unless $parse_tree_installed
    describe '>> SerializableProc::CannotAnalyseCodeError' do

      extend SerializableProc::Spec::Helpers

      should "raise if line has more than 1 'SerializableProc.new'" do
        lambda {
          SerializableProc.new {} ; SerializableProc.new { |arg| %w{a b}.map{|x| puts x } }
        }.should.be raising_cannot_analyse_error("'SerializableProc.new'")
      end

      should "raise if line has more than 1 'Proc.new'" do
        lambda {
          p1 = Proc.new {} ; p2 = Proc.new { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line has more than 1 'lambda'" do
        lambda {
          p1 = lambda {} ; p2 = lambda { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line has more than 1 'proc'" do
        lambda {
          p1 = proc {} ; p2 = proc { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line mixes 'lambda' & 'proc'" do
        lambda {
          p1 = lambda {} ; p2 = proc { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line mixes 'Proc.new' & 'proc'" do
        lambda {
          p1 = Proc.new {} ; p2 = proc { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line mixes 'Proc.new' & 'lambda'" do
        lambda {
          p1 = Proc.new {} ; p2 = lambda { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_analyse_error("'lambda'/'proc'/'Proc.new'")
      end

      should "raise if line does not have lambda, proc, Proc.new or SerializableProc.new" do
        lambda {
          def create_serializable_proc(&block) ; SerializableProc.new(&block) ; end
          create_serializable_proc { %w{a b}.map{|x| puts x } }
        }.should.raise(SerializableProc::CannotAnalyseCodeError).
          message.should.equal('Cannot find specified initializer !!')
      end

    end
  end

  describe '>> SerializableProc::CannotSerializeVariableError' do

    extend SerializableProc::Spec::Helpers

    should "raise if local variable cannot be marshalled" do
      f = Tempfile.new('fake')
      lambda { SerializableProc.new{ f } }.should.be raising_cannot_serialize_variable_error('f')
    end

    should "raise if class variable cannot be marshalled" do
      @@f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @@f } }.should.be raising_cannot_serialize_variable_error('@@f')
    end

    should "raise if instance variable cannot be marshalled" do
      @f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @f } }.should.be raising_cannot_serialize_variable_error('@f')
    end

    should "raise if global variable cannot be marshalled" do
      $f = Tempfile.new('fake')
      lambda { SerializableProc.new{ $f } }.should.be raising_cannot_serialize_variable_error('$f')
    end

  end

end
