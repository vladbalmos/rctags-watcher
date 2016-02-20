require_relative "../lib/configuration"
require "test/unit"

class TestConfiguration < Test::Unit::TestCase

    def test_load_configuration_merges_files
        config_files = ['data/fixtures/cfg-global.yaml', 'data/fixtures/cfg-local.yaml']
        cfg = Configuration.new(config_files)
        config = cfg.load

        assert_equal false, config['logging']['verbose']
        assert_equal false, config['dirs']['project1']['recursive']
        assert_equal '~/project2', config['dirs']['project2']['path']
    end

    def test_loads_default_configuration
        cfg = Configuration.new []
        config = cfg.load
        assert_equal 'DEBUG', config['logging']['level']
        assert_equal 'STDERR', config['logging']['log_destination']
    end
end
