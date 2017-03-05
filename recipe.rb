require 'pry'

# Display list of recipes
# Prompt user to add a recipe
# Recipes consist of ingredients, quantities, units of measurement
# Verbs:
# Add ingredients and quantities to a recipe
require 'yaml'

class Recipe
  attr_accessor :title, :directions, :ingredients, :tags
  
  def initialize
    @title = ""
    @name = ""
    @ingredients = [ ]
    @directions = ""
    @tags = [ ]
  end
  
  def info=(recipe_hash)
    @title = recipe_hash[:title]
    @ingredients = recipe_hash[:ingredients]
    @directions = recipe_hash[:directions]
    @tags = recipe_hash[:tags]
  end  

  def add_title(title)
    @title = title
  end
  
  def add_ingredient(ingredient) 
    @ingredients << ingredient
  end
  
  def add_directions(string)
    @directions = string
  end

  def add_tag(tag)
    @tags << tag
  end
  
  def retrieve
    # Not sure if this method belongs in this class.
  end

  def to_s 
    "\n#{@title.upcase}\n\nIngredients:\n#{@ingredients.join("\n")}\n\n" \
    "Directions: #{@directions}\n\nTags: #{@tags.join(', ')}\n"
  end
    
end

class List  # could contain logic for loading and saving the list, as well as manipulating the list (such as sorting recipes by name)
  def initialize
    @list = YAML.load(File.read("recipes_list.yml")) 
  end

  def read
    @list
  end
  
  def add(recipe_object)
    new_recipe = { title: recipe_object.title, 
                   ingredients: recipe_object.ingredients, 
                   directions: recipe_object.directions,
                   tags: recipe_object.tags }
    @list << new_recipe
  end
  
  def write
    File.open("recipes_list.yml", "w") { |file| file.write(@list.to_yaml) }
  end
end

class RecipeSession
  
  def initialize
    # Separated out the List#read method to allow recipes to be added to the list.
    @recipes = List.new
    @access_recipes = @recipes.read 
    @current_user_input = nil
  end
  
  def session
    system 'clear'
    welcome_message
    loop do 
      display_recipes
      user_menu_choice
      case @choice
      when 'q'
        break
      when 'n'
        enter_new_recipe
      else
        display_single_recipe
      end
      system 'clear'
    end
    goodbye_message
  end
  
  def user_menu_choice
    choice = nil
    loop do
      puts "Please choose an option:"
      puts "View a recipe (Enter a recipe number)"
      puts "Add a new recipe (press N)"
      puts "Exit the program (press Q)"
      puts ""
      choice = gets.chomp.downcase
      break if valid_menu_options.include?(choice)
      puts "Sorry, invalid answer."
    end
    @choice = choice
  end
  
  def valid_menu_options
    menu_options = ['n', 'q']
    (1..@access_recipes.count).each { |num| menu_options << num.to_s }
    menu_options
  end

  def display_recipes
    @access_recipes.each_with_index do |recipe, idx|
      puts "#{idx+1}. #{recipe[:title]}"
    end
    puts ""
  end
  
  def display_single_recipe
    system 'clear'
    @current_recipe = Recipe.new
    @current_recipe.info = @access_recipes[@choice.to_i - 1]
    puts @current_recipe
    puts ""
    loop do
      puts "Press Enter to return to the main menu."
      answer = gets.chomp
      break if answer.size.zero?
      puts "Sorry, invalid answer." 
    end
  end
  
  def enter_new_recipe
    loop do
      @new_recipe = Recipe.new

      @new_recipe.add_title(user_input('What is the name of the recipe?'))

      enter_ingredients

      @new_recipe.add_directions(user_input('What are the directions?'))

      enter_tags
      
      @recipes.add(@new_recipe)

      puts "Enter another recipe? (y/n)"
      answer = nil
      loop do 
        answer = gets.chomp.downcase[0]
        break if ['y', 'n'].include?(answer)
        puts "Sorry, that is not a valid answer."
      end
      break if answer == 'n'
    end
    puts ""
  end
  
  def user_input(question)
    answer = nil
    loop do
      puts question
      answer = gets.chomp
      break if !answer.length.zero? && answer[0] != ' '
      puts "Sorry, that is not a valid answer."
      puts ""
    end
    puts ""
    answer
  end
  
  def enter_ingredients
    @current_user_input = nil
    loop do
      loop do
        puts "Please enter an ingredient or 'd' for done."
        puts "Example: 1/4 cup milk"
        puts ""
        @current_user_input = gets.chomp
        break if !@current_user_input.length.zero? && 
                 @current_user_input[0] != ' '
        puts "Sorry, that is not a valid ingredient."
      end
      break if @current_user_input == 'd' 
      @new_recipe.add_ingredient(@current_user_input)
      puts ""
    end
  end

  def enter_tags
  @current_user_input = nil
    loop do
      loop do
        puts "Please enter a tag or 'd' for done."
        puts "Example: breakfast"
        puts ""
        @current_user_input = gets.chomp
        break if !@current_user_input.length.zero? && 
                 @current_user_input[0] != ' '
        puts "Sorry, that is not a valid tag."
      end
      break if @current_user_input == 'd' 
      @new_recipe.add_tag(@current_user_input)
      puts ""
    end
  end
  
  def welcome_message
    puts "Welcome to the Recipe List."
    puts
  end
  
  def goodbye_message
    puts "Goodbye!"
  end
end

RecipeSession.new.session