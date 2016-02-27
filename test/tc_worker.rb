require_relative "../lib/worker"
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

