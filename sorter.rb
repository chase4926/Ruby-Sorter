

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


$SORT_DIR = ARGV[0].gsub('\\', '/')
ARGV.clear()

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
  result.compact!
  return result
end


# Step 1: Acquire list of all files in folder to sort

list = recursive_search_directory($SORT_DIR)
list.each_index do |i|
  list[i] = list[i].split('/', 2)[1]
end


vp list
vprint_line()

# Step 2: Sort those files into a hash, group files in same parent folder together

list.each_index do |i|
  last_folder = $SORT_DIR.split('/').last()
  list[i] = list[i].split("#{last_folder}/").last()
end


list_hash = Hash.new()
list.each_index do |i|
  item = list[i]
  if item.include?('/')
    folder_name = item.split('/')[0]
    next if $TYPES_HASH.keys().include?(folder_name[0..-2])
    if list_hash[folder_name] == nil then
      list_hash[folder_name] = []
    end
    list_hash[folder_name] << item.split('/').last
  else
    list_hash[item] = [item]
  end
end
list = nil


vp list_hash
vprint_line()

# Step 3: Sort that hash using the file extentions
# 
# The hierarchy is the top->bottom order on the bottom of the script

type_hash = Hash.new()
list_hash.each do |item|
  parent, files = item
  type_hash[parent] = 'Other' # Set it to the default type
  files.each do |file|
    file_type = file_extension_to_type(file.split('.').last())
    file_priority = type_priority(file_type)
    if file_priority > type_priority(type_hash[parent]) then
      type_hash[parent] = file_type
    end
  end
end


vp type_hash
vprint_line()

# Step 4: Create the folders if they don't already exist

$TYPES_HASH.keys().each do |folder_name|
  folder_path = "#{$SORT_DIR}/#{folder_name +'s'}"
  unless File.directory?(folder_path) or not type_hash.values().include?(folder_name) then
    Dir.mkdir(folder_path)
  end
end

# Step 5: Move the sorted entries into these new folders

type_hash.each do |item|
  from, to = item
  from = "#{$SORT_DIR}/#{from}"
  to = "#{$SORT_DIR}/#{to}s"
  puts "Transferring: #{from} => #{to}"
  sleep(0.01)
  FileUtils.mv(from, to)
end

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

