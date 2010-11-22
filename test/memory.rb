require_relative '../lib/docdo'

sleep 5

@doc = Docdo.new do |d|
	d[:big] = "xyz" * 10_000_000
end

sleep 5

5.times{ |i|
	@doc.as 'bump' do |d|
		d["bump#{i}"] = i
	end
	sleep 5
}
