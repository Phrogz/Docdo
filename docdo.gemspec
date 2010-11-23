# encoding: UTF-8
Dir.chdir 'lib' do
	require 'docdo'
end

Gem::Specification.new do |s|
	s.name        = "docdo"
	s.version     = Docdo::VERSION
	s.date        = "2010-11-22"
	s.author      = "Gavin Kistner"
	s.email       = "gavin@phrogz.net"
	s.homepage    = "http://github.com/Phrogz/Docdo"
	s.summary     = "Ruby document with undo/redo tracking."
	s.description = "A Docdo is like a Hash that can only be modified through recorded, undoable (and redoable) actions. The undo stack is very lightweight: each state stores only the difference from the previous state."
	s.files       = %w[ lib/**/* test/**/* ].inject([]){ |all,glob| all+Dir[glob] }
	s.test_file   = 'test/test_all.rb'
	s.add_dependency 'minitest'
	s.requirements << "MiniTest gem for running unit tests."
	#s.has_rdoc = true
end
