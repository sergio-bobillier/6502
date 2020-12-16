# frozen_string_literal: true

module Assembler
  module Instructions
    module AddressingModes
      ACCUMULATOR = 'A'
      IMPLIED = 'i'
      IMMEDIATE = '#'
      ABSOLUTE = 'a'
      ZERO_PAGE = 'zp'
      RELATIVE = 'r'
      ABSOLUTE_INDIRECT = '(a)'
      ABSOLUTE_X = 'a,x'
      ABSOLUTE_Y = 'a,y'
      ZERO_PAGE_X = 'zp,x'
      ZERO_PAGE_Y = 'zp,y'
      ZERO_PAGE_INDIRECT_X = '(zp,x)'
      ZERO_PAGE_INDIRECT_Y = '(zp),y'

      BIN_LITERAL_8 = '%[0-1]{1,8}'
      BIN_LITERAL_16 = '%[0-1]{9,16}'
      HEX_LITERAL_8 = '\$[0-9A-Fa-f]{1,2}'
      HEX_LITERAL_16 = '\$[0-9A-Fa-f]{3,4}'
      DEC_LITERAL_8 = '[0-9]{1,3}'
      DEC_LITERAL_16 = '[0-9]{3,5}'

      BIN_LITERAL = "#{BIN_LITERAL_8}|#{BIN_LITERAL_16}"
      HEX_LITERAL = "#{HEX_LITERAL_8}|#{HEX_LITERAL_16}"
      DEC_LITERAL = "#{DEC_LITERAL_8}|#{DEC_LITERAL_16}"

      ADDRESSING_MODES_MAP = {
        /^#(#{BIN_LITERAL}|#{HEX_LITERAL}|#{DEC_LITERAL})$/ => IMMEDIATE,
        /^(#{BIN_LITERAL_16}|#{HEX_LITERAL_16}|#{DEC_LITERAL_16})$/ => ABSOLUTE,
        /^(#{BIN_LITERAL_8}|#{HEX_LITERAL_8}|#{DEC_LITERAL_8})$/ => [ZERO_PAGE, RELATIVE],
        /^\((#{BIN_LITERAL}|#{HEX_LITERAL}|#{DEC_LITERAL})\)$/ => ABSOLUTE_INDIRECT,
        /^(#{BIN_LITERAL_16}|#{HEX_LITERAL_16}|#{DEC_LITERAL_16}),X|x$/ => ABSOLUTE_X,
        /^(#{BIN_LITERAL_8}|#{HEX_LITERAL_8}|#{DEC_LITERAL_8}),X|x$/ => ZERO_PAGE_X,
        /^(#{BIN_LITERAL_16}|#{HEX_LITERAL_16}|#{DEC_LITERAL_16}),Y|y$/ => ABSOLUTE_Y,
        /^(#{BIN_LITERAL_8}|#{HEX_LITERAL_8}|#{DEC_LITERAL_8}),Y|y$/ => ZERO_PAGE_Y,
        /^\((#{BIN_LITERAL}|#{HEX_LITERAL}|#{DEC_LITERAL}),X|x\)$/ => ZERO_PAGE_INDIRECT_X,
        /^\((#{BIN_LITERAL}|#{HEX_LITERAL}|#{DEC_LITERAL})\),Y|y$/ => ZERO_PAGE_INDIRECT_Y
      }.freeze
    end
  end
end
