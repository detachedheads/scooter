require 'marathon/app'
require 'json'

::Marathon::App.class_eval do

  # `jq 'keys'` used on a full configuration to quickly extract keys
  CONFIG_KEYS = [
    'acceptedResourceRoles',
    'args',
    'backoffFactor',
    'backoffSeconds',
    'cmd',
    'constraints',
    'container',
    'cpus',
    'dependencies',
    'env',
    'executor',
    'healthChecks',
    'id',
    'instances',
    'labels',
    'maxLaunchDelaySeconds',
    'mem',
    'ports',
    'requirePorts',
    'upgradeStrategy',
    'uris'
  ]

  def filtered_info
    # Remove the all non-configuration keys
    sort_hash(deep_stringify_keys(info).reject { |key, value| !CONFIG_KEYS.include?(key) })
  end

  def filtered_info_to_json
    JSON.pretty_generate(filtered_info)
  end

  def info_to_json
    JSON.pretty_generate(sort_hash(info))
  end

  def write_to_file(file)
    File.open(file, 'w') do |f|
      f.write(filtered_info_to_json)
    end
  end

  private

  def deep_stringify_keys(hash)
    transform_hash(hash, :deep => true) {|hash, key, value|
      hash[key.to_s] = value
    }                               
  end

  def slice_hash(hash, *keys)
    transform_hash(hash, :deep => false) {|hash, key, value|
      hash[key] = value if keys.include?(key)
    }
  end

  def sort_hash(h)
    {}.tap do |h2|
      h.sort.each do |k,v|
        h2[k] = v.is_a?(Hash) ? sort_hash(v) : v
      end
    end
  end

  def transform_hash(original, options={}, &block)
    original.inject({}){|result, (key,value)|
      value = if (options[:deep] && Hash === value) 
                transform_hash(value, options, &block)
              else 
                value
              end
      block.call(result,key,value)
      result
    }
  end
end
