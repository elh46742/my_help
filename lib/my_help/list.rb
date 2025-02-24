require_relative "./org2yml"
#require "colorize"
require "colorized_string"

module MyHelp
  # Your code goes here...
  class List
    def initialize(path = "", ext = ".org")
      @path = path
      @ext = ext
    end

    def list(help_options = "", level = 0)
      name, item = help_options.split(" ")
      if item == nil && name == nil
        list_helps()
      else
        path = File.exists?(name + @ext) ? name + @ext :
          File.join(@path, name + @ext)
        list_help_with(path, name, item)
      end
    end

    def read_help(file)
      info = {}
      info[:items] = Org2Hash.new(File.read(file)).contents
      info[:name] = File.basename(file).split(".")[0]
      return info
    end

    def list_helps()
      files = File.join(@path, "*#{@ext}")
      Dir.glob(files).inject("") do |out, file|
        p [out, file]
        help_info = read_help(file)
        out << "%10s: %s\n" % [help_info[:name],
                               help_info[:items]["head"].split("\n")[0]]
      end
    end

    # defaultで@path/name.@extのヘルプを読み込んで，itemを表示
    #
    def list_help_with(path, name, item)
      @help_info = read_help(path)
      output = ColorizedString["my_help called with name : #{name}, item : #{item}\n"].colorize(:cyan)

      if item == nil
        @help_info[:items].each_pair do |item, val|
          item, desc = item.split(":")
          desc ||= ""
          output << "- %20s : %s\n" % [item, desc]
        end
      else
        output << find_near(item)
      end
      return output
    end

    def find_near(input_item)
      candidates = []
      @help_info[:items].each_pair do |item, val|
        candidates << item if item.include?(input_item)
      end
      if candidates.size == 0
        "Can't find similar item name with : #{input_item}"
      else
        contents = candidates.collect do |near_item|
          ColorizedString["item : #{near_item} \n"].colorize(:cyan) +
          @help_info[:items][near_item]
        end
        contents.join("\n")
      end
    end
  end
end
