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
	
	# :nodoc:
	def method_missing(method_name,*args,&block)
		if LEGAL_HASH_METHODS[method_name]
			@h.send(method_name,*args,&block)
		else
			raise NoMethodError, "#{self.class} has no method named '#{method_name}'"
		end
	end

	def initialize(initial_values={},&block)
		@h = {}
		pull_in(initial_values) unless initial_values.empty?
		mutate(&block) if block_given?
	end
	
	def to_hash
		@h.dup
	end
	
	def clone(&block)
		self.class.new(@h,&block)
	end
	
	def merge(h,&block)
		dup = self.clone.pull_in(h)
		dup.mutate(&block) if block
		dup
	end
	
	protected
		def mutate
			yield @h
			pull_in(@h)
		end
		def pull_in(values_hash)
			values_hash.each do |key,value|
				@h[key] = case value
					when Array then ::Docdo::StaticArray.new
					when Hash then self.class.new(@h)
					else value.freeze
				end
			end
			self
		end
end