#!/usr/bin/ruby
# Cli for practicing memorizing student's names
# requires a folder (default path "./data/students") of practice images with names like 'first_last_profile.png' or 'first_last_profile.jpg'
# keeps track of score in a file (default path "./data/score")

require "base64"
require "json"

class LRU
  def initialize(size)
    @size = size
    @data = []
  end

  def push(item)
    if @data.include?(item)
      #so to update recency
      @data.delete_value(item)
    end

    @data.unshift(item)
    if @data.length > @size
      @data.pop
    end
  end

  def has?(item)
    @data.include?(item)
  end
end

class Flashcards
  DEFAULT_DATA_PATH = "./data/students/*"
  DEFAULT_SCORE_PATH = "./data/score"
  IGNORE_MOST_RECENT = 5

  def initialize(data_path=DEFAULT_DATA_PATH, score_path=DEFAULT_SCORE_PATH)
    @data_path = data_path
    @score_path = score_path
    @lru = LRU.new(IGNORE_MOST_RECENT)
    initialize_score(score_path)
    initialize_signal_trap
  end

  def initialize_score(path)
    if File.exists?(path)
      File.open(path, 'r') do |score_file|
        @score = JSON.parse(score_file.read)
      end
    else
      @score = all_names.map { |name| [name, 0] }.to_h
    end
  end

  # setup signal catching
  def initialize_signal_trap
    Signal.trap('INT') do |sig|
      puts ""
      save_and_quit
    end
  end

  def save_and_quit
    persist_score
    exit
  end

  def persist_score
    print "Saving..."
    File.open(@score_path, "w") do |score_file|
      score_file.puts @score.to_json # requiring 'json' monkeypatches Hash
    end
    puts "done!"
  end

  def student_name(filename)
    filename.split('/')[3].split('_profile')[0]
  end

  def first_name(name)
    name.split(/[ _-]/).first
  end

  def files
    Dir[@data_path]
  end

  def names_to_files
    files.map { |filename| [student_name(filename), filename] }.to_h
  end

  def all_names
    files.map { |filename| student_name(filename) }
  end

  def random_success(name)
    ["Bingo!", "Nice!", "Nailed it!", "You're really getting these!", "Yes!", "Winner!",
      "Correct!", "Awesome!", "#{name} will be so pleased you remembered!", "You and #{name} are well on your way towards friendship"].sample
  end

  def random_failure(actual, guess)
    ["Not quite, it was #{actual}.", "Nope, that's #{actual}", "Yikes! You guessed #{guess}, but it was really #{actual}", "Shhhh, #{actual} won't know that you guessed their name wrong.", "It's #{actual}, actually",
      "They call me 'Bell' \nThey call me 'Stacey'\nThey call me 'her'\nThey call me '#{guess}'\nThat's not my name\n
      That's not my name\nThat's not my name\nThat's not my name\n\n It's #{actual}"].sample
  end

  def normalize_name(name)
    name.downcase.strip
  end

  def update_score(guess, full_name)
    nguess = normalize_name(guess)
    nfull_name = normalize_name(full_name)
    nfirst = normalize_name(first_name(full_name))
    got_it = nguess == nfirst || guess == nfull_name
    puts got_it ? random_success(guess) : random_failure(nfirst, guess)
    @score[full_name] += (got_it ? 1 : -1)
  end

  def names_by_score_without_most_recent
    @score
    .select { |k, v| !@lru.has?(k) }
    .group_by { |k, v| v }
    .map { |score, values| [score, values.map(&:first)] }
    .to_h
  end

  def random_name_among_lowest_scoring
    names_by_score_without_most_recent.min_by { |k, v| k }[1].sample
  end

  def show_image(filename, width="300px", height="auto")
    File.open(filename, "rb") do |file|
      raw_image = file.read
      encoded_image = Base64.encode64(raw_image)
      # this is a syntax that works for iterm2. It might not work in other terminal emulators...
      puts "\x1B]1337;File=inline=1;width=#{width};height=#{height}:#{encoded_image}\x07"
    end
  end

  def prompt_for_answer
    puts "Who is this?"
    gets.chomp
  end

  def game_loop
    current_student = random_name_among_lowest_scoring
    @lru.push(current_student)
    show_image(names_to_files[current_student])
    guess = prompt_for_answer
    case guess
    when "show score"
      puts JSON.pretty_generate(@score)
    when "save"
      persist_score
    when "quit"
      save_and_quit
    else
      update_score(guess, current_student)
    end
  end

  def run
    loop do
      game_loop
    end
  end
end

Flashcards.new.run
