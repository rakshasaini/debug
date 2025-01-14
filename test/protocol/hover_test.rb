# frozen_string_literal: true

require_relative '../support/test_case'

module DEBUGGER__
  
  class HoverTest < TestCase
    PROGRAM = <<~RUBY
      1| a = 1
      2| b = 2
      3| c = 3
      4| d = 4
      5| e = 5
    RUBY
    
    def test_hover_matches_with_stopped_place
      run_protocol_scenario PROGRAM do
        req_add_breakpoint 4
        req_continue
        assert_hover_result 2, expression: 'b'
        assert_hover_result 3, expression: 'c'
        assert_hover_result 1, expression: 'a'
        req_terminate_debuggee
      end
    end
  end

  class HoverTest2 < TestCase
    PROGRAM = <<~RUBY
      1| p 1
    RUBY
    
    def test_hover_returns_method_info
      run_protocol_scenario PROGRAM do
        b = TOPLEVEL_BINDING.dup
        assert_hover_result b.eval('self').method(:p), expression: 'p'
        req_terminate_debuggee
      end
    end
  end

  class HoverTest3 < TestCase
    PROGRAM = <<~RUBY
       1| module Abc
       2|   class Def123
       3|     class Ghi
       4|       def initialize
       5|         @a = 1
       6|       end
       7| 
       8|       def a
       9|         ::Abc.foo
      10|         ::Abc::Def123.bar
      11|         p @a
      12|       end
      13|     end
      14| 
      15|     def bar
      16|       p :bar1
      17|     end
      18| 
      19|     def self.bar
      20|       p :bar2
      21|     end
      22|   end
      23| 
      24|   def self.foo
      25|     p :foo
      26|   end
      27| end
      28| 
      29| Abc::Def123.new.bar
      30| 
      31| ghi = Abc::Def123::Ghi.new
      32| ghi.a
    RUBY
    
    def test_hover_returns_const_info
      run_protocol_scenario PROGRAM do
        req_add_breakpoint 31
        req_continue
        assert_hover_result Object.const_set('Abc', Module.new), expression: 'Abc'
        assert_hover_result Abc.const_set('Def123', Class.new), expression: 'Abc::Def123'
        assert_hover_result Abc::Def123.const_set('Ghi', Class.new), expression: 'Abc::Def123::Ghi'
        assert_hover_result Abc::Def123::Ghi, expression: 'Abc::Def123::Ghi.new'
        assert_hover_result Abc, expression: '::Abc.foo'
        assert_hover_result Abc::Def123, expression: '::Abc::Def123'
        assert_hover_result Abc::Def123, expression: '::Abc::Def123.bar'
        req_terminate_debuggee
      end
    end
  end
end
