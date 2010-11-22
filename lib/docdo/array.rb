class Docdo; end
class Docdo::StaticArray
	# :nodoc:
	PASS_ARRAY_METHODS = Hash[ %w{
		[] <=> length size send first last
		each each_index each_with_index abbrev at
		collect map combination empty? fetch
		count cycle index to_s inspect
		join pack reverse_each
	}.map{ |m| [m.to_sym,true] } ]

	WRAP_ARRAY_METHODS = Hash[ %w{
		* + - | & push concat drop_while flatten
		insert permutation product reject select shuffle
		take values_at zip
	}.map{ |m| [m.to_sym,true] } ]
	
	# :nodoc:
	def method_missing(method_name,*args,&block)
		if PASS_ARRAY_METHODS[method_name]
			@a.send(method_name,*args,&block)
		elsif WRAP_ARRAY_METHODS[method_name]
			self.class.new( *@a.dup.send(method_name,*args,&block) )
		else
			raise NoMethodError, "#{self.class} has no method named '#{method_name}'"
		end
	end

 	def initialize(*initial_values,&block)
		@a = []
		set_values(initial_values) unless initial_values.empty?
		mutate(&block) if block_given?
	end
	
	def to_a
		@a.dup
	end
	alias_method :to_ary, :to_a
	
	protected
		def set_values(values)
			@a = values.map do |value|
				case value
					when Array then self.class.new value
					when Hash then ::Docdo::StaticArray.new( value )
					else value.freeze
				end
			end
		end
		def mutate
			yield @a
			set_values @a
		end
end

:IMOGEN
:Imogen

:LACHLAN
:Lachlan