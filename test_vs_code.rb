# doesn't include special files (Gemfile)
# only ruby (.rb and _spec.rb)
# some files that i had open show 0 seconds, which could be less then 4 seconds

def read_files(dir)
  all_files = {}

  Dir["#{dir}/*"].each do |file|
    file =~ /.*\.(\d+)\.(\d+)\.(\d+)\.(\d+)/
    date = "#{$2}.#{$3}.#{$4}"

    if all_files[date].nil?
      all_files[date] = [file]
    else
      all_files[date] << file
    end
  end

  all_days = []
  all_files.each do |date,filenames|
    all_days << read_day(date, filenames)
  end

  all_days
end

def read_day(date, filenames)

  total_test = 0
  total_code = 0

  filenames.each do |filename|
    values = read_file(filename)
    total_test += (values.collect{|n|
      n[:test]|| 0
    }.compact.inject(:+) || 0)

    total_code += ( values.collect{|n|
      n[:code]|| 0
    }.compact.inject(:+) || 0 )
  end

  {
    date: date,
    test: total_test,
    code: total_code
  }

end

def read_file(filename)
  times = []
  File.open(filename, "r") do |infile|
    while (line = infile.gets)
      value = parse_line(line)
      if value
        times << value
      end
    end
  end
  times
end

# Returns
# {code: 100} Means that 100 seconds were spend on code
# {test: 100} Means that 100 seconds were spend on testing
def parse_line(line)
  values = line.split(" ")
  time_string = values[1]
  file = values[2]

  unless file =~ /.*\.(rb|haml|erb|rake)$/
    puts "1)Skipping #{file}"
    return nil
  end

  file_type =if file =~ /.*_spec*/
               :test
             else
               :code
             end

  time = seconds(time_string)

  if time == 0
    puts "2)Skipping #{file}"
    return nil
  end

  return {
    file_type => time,
    name: file
  }
end

#Parameters
#00:00:00 format
def seconds(time_string)
  hours, minutes, seconds = time_string.split(":")
  return hours.to_i * 60 *60 +
    minutes.to_i * 60 +
    seconds.to_i
end

dir = "/tmp/buftimer"
read_files(dir)
