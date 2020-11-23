# frozen_string_literal: true

require 'forwardable'

class Memory
  extend Forwardable

  DEFAULT_SIZE = 0xFFFF

  def_delegator :@memory, :[], :read
  def_delegator :@memory, :[]=, :write
  def_delegator :@memory, :size

  def initialize
    @memory = Array.new(DEFAULT_SIZE, 0)
  end
end
