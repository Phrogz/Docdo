class Docdo; end

class Docdo::StaticHash
	# :nodoc:
	LEGAL_HASH_METHODS = Hash[ %w{
		[] assoc each each_key each_pair each_value
		empty? fetch has_key? include? key? member?
		has_value? value?
		to_s inspect keys values key values_at
		length size rassoc reject select to_a
	}.map{ |m| [m.to_sym,true] } ]

	def initialize(initial_values={})
		@h = {}
		new_values = initial_values.dup
		yield new_values if block_given?
		new_values.each do |key,value|
			@h[key] = case value
				when Array then ::Docdo::StaticArray.new
				when Hash then self.class.new(@h)
				else value.freeze
			end
		end
	end	

	def merge(new_values={},&mutating_block)
		self.class.new(@h.merge(new_values),&mutating_block)
	end
	alias_method :clone, :merge
	
	# :nodoc:
	def method_missing(method_name,*args,&block)
		if LEGAL_HASH_METHODS[method_name]
			@h.send(method_name,*args,&block)
		else
			raise NoMethodError, "#{self.class} has no method named '#{method_name}'"
		end
	end

	def to_hash
		@h.dup
	end
end