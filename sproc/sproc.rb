#--
# SProc v1.1 by Solistra
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script provides a new type of `Proc` object which may be serialized
# and reconstructed without losing its associated code. This is primarily a
# scripter's tool.
# 
# Usage
# -----------------------------------------------------------------------------
#   An `SProc` may be used almost identically to an actual `Proc` object, with
# one major difference: the code passed to it is in the form of a string rather
# than a block. As such, creating one looks somewhat different:
# 
#     sproc = SES::SProc.new(%Q{ |i| i ** 2 })
# 
#   Once created, an `SProc` may be safely serialized to disk and reconstructed
# later via `Marshal.dump` and `Marshal.load` (or the special `load_data`
# method available in RPG Maker for reading from encrypted archives).
# 
#     File.open('Example.rvdata2', 'wb') { |f| f << Marshal.dump(sproc) }
#     sproc = File.open('Example.rvdata2', 'rb') { |f| Marshal.load(f) }
# 
#   An `SProc` can be used in exactly the same way as a normal `Proc`, even
# making use of `to_proc` conversion via the `&` unary operator like so:
# 
#     sproc = SES::SProc.new(%Q{ |i| (i % 3).zero? })
#     (1..10).to_a.select(&sproc) # => [3, 6, 9]
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   This script may be placed anywhere above Materials, but above Main and any
# scripts which make use of `SProc` objects.
# 
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # SProc
  # ===========================================================================
  #   Provides a serializable `Proc` object.
  class SProc
    # The code string which generated the underlying `Proc` object.
    # @return [String]
    attr_reader :code
  
    # Instantiates a new {SProc} instance with the given code used to evaluate
    # the object's underlying `Proc`.
    # 
    # @param code [String] the code used to generate the underlying `Proc`
    # @return [SProc] the new {SProc} instance
    def initialize(code)
      @proc = create_proc(@code = code)
    end
    
    # Custom writer for the `@code` instance variable; assigns the given value,
    # then generates a new underlying `Proc` object to reflect the change.
    # 
    # @param value [String] the code to assign
    # @return [String] the newly assigned code
    def code=(value)
      @proc = create_proc(@code = value)
    end
    
    # Refreshes the underlying `Proc` object in case changes have been made to
    # the `@code` string without the use of the custom {#code=} writer (by
    # making changes via methods on the reader method, for example).
    # 
    # @return [Proc] the new underlying `Proc`
    def refresh
      @proc = create_proc(@code)
    end
    
    # Calls the underlying `Proc` object with the given arguments.
    # 
    # @param args [Array<Object>] the argument to pass to the `Proc`
    # @return [Object] the return value of the `Proc`
    def call(*args)
      @proc.call(*args)
    end
    
    # Returns the `Proc` object generated by this {SProc}.
    # 
    # @return [Proc] the underlying `Proc`
    def to_proc
      @proc
    end
    
    # Dumps the string containing the code used to generate the underlying
    # `Proc` object.
    # 
    # @return [Array<String>] the array to pass to `Marshal#dump`
    def marshal_dump
      [@code]
    end
    
    # Loads the marshalled code string and uses it to generate the underlying
    # `Proc` object for the {SProc}.
    # 
    # @return [SProc] the {SProc} instance loaded by `Marshal#load`
    def marshal_load(array)
      @code, @proc = array[0], create_proc(array[0])
    end
    
    # Generates the underlying `Proc` object from the code string defined for
    # this {SProc}.
    # 
    # @note This method uses `Kernel#eval` to produce the `Proc` object and is
    #   only called when the {SProc} is initialized or loaded via `Marshal`.
    # 
    # @param code [String] the code 
    def create_proc(code)
      eval("Proc.new { #{code} }")
    end
    private :create_proc
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      # Script metadata.
      Description = Script.new(:SProc, 1.1, :Solistra)
      Register.enter(Description)
    end
  end
end
