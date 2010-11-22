require_relative 'helper'

A = Docdo::StaticArray
class TestArray < Test
	LETTERS = *(:a..:z)
	ANIMALS = %w[ cat rat dog ]
	FUZZIES = %w[ blanket cat ]
	def test_setup
		a0 = A.new
		assert_equal 0, a0.length
		assert_nil a0[0]
		
		a1 = A.new *LETTERS
		assert_equal LETTERS.length, a1.length
		assert_equal LETTERS[0], a1[0]
		
		a2 = A.new *LETTERS do |a|
			a[0] = :start
			a << :end
		end
		assert_equal LETTERS.length+1, a2.length
		assert_equal :start, a2[0]
		assert_equal :end,   a2.last
	end
	
	def test_sets_with_self
		a1 = A.new *ANIMALS
		a2 = A.new *FUZZIES
		expected_to_actual = {
			(ANIMALS + FUZZIES) => (a1 + a2),
			(FUZZIES + ANIMALS) => (a2 + a1),
			(ANIMALS - FUZZIES) => (a1 - a2),
			(FUZZIES - ANIMALS) => (a2 - a1),
			(ANIMALS | FUZZIES) => (a1 | a2),
			(FUZZIES | ANIMALS) => (a2 | a1),
			(ANIMALS & FUZZIES) => (a1 & a2),
			(FUZZIES & ANIMALS) => (a2 & a1)
		}
		expected_to_actual.each do |expected_values, immutable|
			assert_kind_of A, immutable
			assert_equal expected_values.length, immutable.length
			immutable.each_with_index do |v,i|
				assert_equal expected_values[i], v
			end
		end
		assert_equal a1.length, ANIMALS.length
		assert_equal a2.length, FUZZIES.length
	end
	
	def test_sets_with_arrays
		a1 = A.new *ANIMALS
		expected_to_actual = {
			(ANIMALS + FUZZIES) => (a1 + FUZZIES),
			(ANIMALS - FUZZIES) => (a1 - FUZZIES),
			(ANIMALS | FUZZIES) => (a1 | FUZZIES),
			(ANIMALS & FUZZIES) => (a1 & FUZZIES),
		}
		expected_to_actual.each do |expected_values, immutable|
			assert_kind_of A, immutable
			assert_equal expected_values.length, immutable.length
			immutable.each_with_index do |v,i|
				assert_equal expected_values[i], v
			end
		end
		assert_equal a1.length, ANIMALS.length
	end
	
	def test_immutability
		a = A.new
		assert_raises(NoMethodError){ a << :more }
	end

	def test_mutability
		orig = [:a,:b]
		more = [:c,:d]
		a1 = A.new *orig
		a2 = a1.push *more
		a3 = a1.concat more
		
		assert_equal orig.length, a1.length
		assert_equal (orig.length+more.length), a2.length
		assert_equal (orig.length+more.length), a3.length		
		assert_kind_of A, a2
		assert_kind_of A, a3
	end
	
	def test_block_setup
		a1 = A.new :a, :b do |a|
			assert_equal 2, a.length
			assert_equal :a, a[0]
		end
	end

end