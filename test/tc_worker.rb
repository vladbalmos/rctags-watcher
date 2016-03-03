# The MIT License (MIT)
# 
# Copyright (c) 2016 Vlad Balmos
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative "../lib/rctags-watcher/worker"
require "test/unit"
require "logger"

class TestWorker < Test::Unit::TestCase

    def test_make_ctags_command_returns_correct_format
        test_data = commands_params_data_provider

        test_data.each do |data|
            params, expected = data
            actual = Worker.make_ctags_command params

            assert_equal expected, actual
        end
    end

    def commands_params_data_provider
        test_data = []
        test_data << [
            {
                :ctags_binary => 'ctags',
                :scan_path => '/tmp',
                :tags_filename => 'tags',
                :recursive => true,
                :ctags_languages => nil
            },
            'ctags -f tags -R /tmp 1>/dev/null 2>&1'
        ]

        test_data << [
            {
                :ctags_binary => 'ctags',
                :scan_path => '/tmp',
                :tags_filename => 'tags',
                :recursive => true,
                :ctags_languages => ['php', 'javascript', 'ruby', 'python', 'c', 'c++']
            },
            'ctags --languages=php,javascript,ruby,python,c,c++ -f tags -R /tmp 1>/dev/null 2>&1'
        ]
        return test_data
    end

end

