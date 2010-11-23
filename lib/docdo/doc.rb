require_relative 'hash'

class Docdo
	VERSION = "0.1"
	class UndoStackEmpty < RuntimeError; end
	class RedoStackEmpty < RuntimeError; end
	def initialize( initial_values={}, &init_block ) 
		@state = StaticHash.new initial_values, &init_block
		@stack = [@state]
		@names = []
		@index = 0
	end
	def as( name, options={}, &block )
		@state = @state.clone(&block)
		if options[:merge] && last_undo==name
			@stack[@index] = @state
		else
			@names[@index] = name
			@state = @stack[@index+=1] = @state
		end
		self
	end
	def last_undo
		@index>0 && @names[ @index-1 ]
	end
	def undo
		raise UndoStackEmpty unless last_undo
		@state = @stack[ @index-=1 ]
	end
	def next_redo
		@names[@index]
	end
	def redo
		raise RedoStackEmpty unless next_redo
		@state = @stack[ @index+=1 ]
	end
	
	def method_missing(*args,&block)
		@state.send(*args,&block)
	end
end
