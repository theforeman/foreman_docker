module ForemanDocker
  module Utility
    def self.parse_memory(mem)
      return 0 unless mem.present?
      mem.gsub!(/\s/, '')
      return mem.to_i if mem[/^\d*$/] # Return if size is without unit
      size, unit = mem.match(/^(\d+)([a-zA-Z])$/)[1, 2]
      case unit.downcase
      when 'g'
        size.to_i * 1024 * 1024 * 1024
      when 'm'
        size.to_i * 1024 * 1024
      when 'k'
        size.to_i * 1024
      else
        fail "Unknown size unit '#{unit}'"
      end
    end
  end
end
