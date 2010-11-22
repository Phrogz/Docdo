require_relative 'helper'

class TestBasics < Test
	def test_empty
		doc = Docdo.new
		assert_empty doc.keys
		assert_empty doc.values
		doc.each do |key,value|
			flunk "There should be no keys."
		end
	end
	
	def test_setup
		legal = {
			sym: :alpha,
			int: 42,
			flt: 17.0,
			str: "foo"
		}
		doc = Docdo.new do |d|
			legal.each do |k,v|
				d[k] = v
			end
		end
		assert_equal legal.keys, doc.keys
		assert_equal legal.values, doc.values
		keys, values = [], []
		doc.each do |key,value|
			keys << key
			values << value
		end
		assert_equal legal.keys, keys
		assert_equal legal.values, values
	end
end

class TestMutability < Test
	def setup
		@doc = Docdo.new do |d|
			d[:sym] = :alpha
			d[:str] = "foo"
		end
	end
	
	def test_immutable
		assert_raises NoMethodError do
			@doc[:key] = :value
		end
		assert_raises NoMethodError do
			@doc[:sym] = :omega
		end
		assert_raises RuntimeError do
			@doc[:str][0] = 'b'
		end
	end
	
	def test_mutable_through_action
		@doc.as 'Add User' do |d|
			d[:user] = "fred"
			d[:sym]  = :omega
		end
		assert_equal :omega, @doc[:sym]
		assert_equal "fred", @doc[:user]
	end

	def test_action_scope
		assert :alpha, @doc[:sym]
		assert_nil @doc[:b]
		@doc.as 'add b' do |d|
			assert :alpha, d[:sym]
			assert_nil d[:b]
			d[:b] = :b
			assert :b, d[:b]
		end
		assert :alpha, @doc[:sym]
		assert :b, @doc[:b]
	end
end

class TestUndoRedo < Test
	def setup
		@doc = Docdo.new
	end
	
	def test_undo
		assert_nil @doc[:int]
		assert !@doc.last_undo, "Can't undo a new doc" 
		assert_raises Docdo::UndoStackEmpty do
			@doc.undo
		end

		@doc.as 'make' do |d|
			d[:int] = 17
		end
		assert_equal 17, @doc[:int]
		assert @doc.last_undo

		assert_equal 'make', @doc.last_undo

		@doc.undo
		assert_nil @doc[:int]
		assert !@doc.last_undo
		
		assert_equal 'make', @doc.next_redo
	end

	def test_redo
		assert !@doc.next_redo
		assert_raises Docdo::RedoStackEmpty do
			@doc.redo
		end
		@doc.as 'make' do |d|
			d[:int] = 17
		end
		@doc.undo
		assert @doc.next_redo
		@doc.redo
		assert_equal 17, @doc[:int]
	end

	def test_no_aggregation
		assert_nil @doc[:foo]
		assert_nil @doc[:bar]

		@doc.as 'go' do |doc|
			doc[:foo] = :foo
		end
		@doc.as 'go' do |doc|
			doc[:bar] = :bar
		end
		assert_equal :foo, @doc[:foo]
		assert_equal :bar, @doc[:bar]
		
		@doc.undo
		assert_equal :foo, @doc[:foo]
		assert_nil @doc[:bar]

		@doc.undo
		assert_nil @doc[:foo]
		assert_nil @doc[:bar]
	end

	def test_aggregation
		assert_nil @doc[:foo]
		assert_nil @doc[:bar]

		@doc.as 'go', merge:true do |doc|
			doc[:foo] = :foo
		end
		@doc.as 'go', merge:true do |doc|
			doc[:bar] = :bar
		end
		assert_equal :foo, @doc[:foo]
		assert_equal :bar, @doc[:bar]
		
		@doc.undo
		assert_nil @doc[:foo]
		assert_nil @doc[:bar]

		assert !@doc.last_undo
	end
end
