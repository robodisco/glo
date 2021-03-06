require 'spec_helper'

describe Glo::Pipe do

  op_a = Class.new do
    include Glo::Op

    def call
      context.name = 'barry'
    end
  end

  op_b = Class.new do
    include Glo::Op

    def call
      context.name = 'peter'
    end
  end

  op_fail = Class.new do
    include Glo::Op

    def call
      context.fail!
    end
  end

  describe ".initialize" do
    it "accepts an array of ops" do
      pipeline = Glo::Pipe.new([op_a, op_b])
        
      expect(pipeline.operations).to eq [op_a, op_b]
    end
  end

  describe ".call" do
    it "runs each operation" do
      context = {}
      pipeline = Glo::Pipe.new([op_a, op_b])

      result = pipeline.call(context)
      expect(result.name).to eq 'peter'
    end

    it "returns the context" do
      context = {}
      pipeline = Glo::Pipe.new([op_a, op_b])

      result = pipeline.call(context)  

      expect(result).to be_a Glo::Context
    end

    it "lets each op change the context" do
      context = {name: 'ross'}
      pipeline = Glo::Pipe.new([op_a, op_b])

      result = pipeline.call(context)  

      expect(result.name).to eq 'peter'
    end

    it "halts the pipeline if an operation fails" do
      pipeline = Glo::Pipe.new([op_a, op_fail, op_b])

      result = pipeline.call

      expect(result).to be_fail
      expect(result.name).to eq 'barry'

    end
  end
end
