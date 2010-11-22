require_relative 'helper'

H = Docdo::StaticHash
class TestHash < Test
	def test_immutable
		h = H.new
		assert_raises NoMethodError do
			h[:foo] = :foo
		end
		assert_equal 0, h.length
		h.each do |k,v|
			flunk "There should not be any keys"
		end
	end
	def test_population
		h1 = H.new sym: :alph, int:42
		assert_equal 2, h1.length

		h2 = H.new do |h|
			h[:foo] = :bar
		end
		assert_equal 1, h2.length
		assert_equal :bar, h2[:foo]
		
		h3 = H.new a:1, b:1 do |h|
			assert_equal 1, h[:b]
			h[:b] = 2
			h[:c] = 3
		end
		assert_equal 3, h3.length
		assert_equal 1, h3[:a]
		assert_equal 2, h3[:b]
		assert_equal 3, h3[:c]
	end
	
	def test_shared
		h1 = H.new a:"foo"
		h2 = h1.merge b:"bar"
		assert_equal "foo", h1[:a]
		assert_nil h1[:b]
		assert_equal "bar", h2[:b]
	end
	
	def test_immutability_of_values
		h = H.new a:{}, b:[], c:"foo", d:17, e:42.0, f:2**40
		assert h[:a], "Hashes are allowed as source values"
		assert h[:b], "Arrays are allowed as source values"
		assert h[:c], "Strings are allowed as source values"
		assert h[:d], "Integers are allowed as source values"
		assert h[:e], "Float are allowed as source values"
		assert h[:f], "BigNums are allowed as source values"
		assert_raises NoMethodError do
			h[:a][:foo] = :bar
		end
	end
end