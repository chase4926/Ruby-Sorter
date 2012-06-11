

# WARNING!!! EXPERIMENTAL!!!
# COULD POTENTIALLY HARM FILES!!!
# This will attempt to sort a chosen folder into catergories
#
# If you want to edit the configuration of sorted data, see the bottom of this file.
# Text on bottom is yaml.


require 'yaml'
require 'fileutils'

Dir.chdir(File.dirname(__FILE__))
$:.unshift File.dirname(__FILE__)

$TYPES_HASH = YAML::load(DATA)


def file_extension_to_type(ext)
  type = $TYPES_HASH.find{|key, value| value.include?(ext)}
  unless type == nil
    return type.first()
  else
    return 'Other'
  end
end

def type_priority(type)
  return $TYPES_HASH.keys().reverse().index(type)
end

def vp(p_able)
  p p_able if $VERBOSE
end

def vprint_line()
  puts "\n=====\n\n" if $VERBOSE
end

def recursive_search_directory(directory)
  result = Dir.glob(File.join(directory, '**/*'))
  result.each_index do |i|
    result[i] = nil if File.directory?(result[i])
  end
  return result.compact
end

def priority_to_type(priority)
  return $TYPES_HASH.keys().reverse()[priority]
end

def determine_path_types(path)
  files = recursive_search_directory(path)
  result = Hash.new()
  files.each do |file|
    file.gsub!("#{path}/", '')
    parent_folder = file.split('/').first()
    priority = type_priority(file_extension_to_type(file.split('.').last()))
    if result[parent_folder] == nil or result[parent_folder] < priority then
      result[parent_folder] = priority
    end
  end
  result.each do |item|
    key, priority = item
    result[key] = priority_to_type(priority)
  end
  return result
end

def sort(path)
  path_types = determine_path_types(path)
  # Create folders based on those path types
  $TYPES_HASH.keys().each do |folder_name|
    folder_path = "#{path}/#{folder_name +'s'}"
    unless File.directory?(folder_path) or not path_types.values().include?(folder_name) then
      Dir.mkdir(folder_path)
    end
  end
  # Move the files
  path_types.each do |item|
    from, to = item
    from = "#{path}/#{from}"
    to = "#{path}/#{to}s"
    puts "Transferring: #{from} => #{to}"
    FileUtils.mv(from, to)
  end
end


if ARGV.empty?() then
  puts 'This program requires command-line arguments to function.'
  puts "Run this program with the argument -? or -help to learn more.\n\n"
  Process.exit()
end

if ARGV.include?('-?') or ARGV.include?('/?') or ARGV.include?('-help') or ARGV.include?('/help') then
  puts "USAGE: ruby sorter.rb <directory to sort> <arguments>\n\n"
  puts "ARGUMENTS:\n"
  puts "-? or -help\tDisplays this message."
  puts "-v\t\tToggles verbosity on."
  Process.exit()
end

if ARGV.include?('-v') or ARGV.include?('/v') then
  $VERBOSE = true
else
  $VERBOSE = false
end


sort(ARGV[0].gsub('\\', '/')) # Those pesky Windows users and their backslashes
ARGV.clear()


__END__
--- 
Disc: 
- iso
- img
Executable: 
- exe
- bat
- jar
Video: 
- avi
- wmv
- mp4
- mov
- mkv
- 3gp
- ogv
- mpg
- flv
Sound: 
- wav
- wma
- ac3
- mp3
- ogg
- flac
Archive: 
- rar
- 7z
- zip
- tar
- gz
- ace
Image: 
- jpg
- gif
- jpeg
- png
- bmp
- xcf
- ico
Document: 
- rtf
- txt
- doc
- docx
- odt
- pdf
Other: []

