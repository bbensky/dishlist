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
  
  def add_ingredient(ingredient) 
    @ingredients << ingredient
  end
  
  def add_directions(string)
    @directions = string
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
    @recipes = List.new.read
  end
  
  def session
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
    end
    goodbye_message
  end
  
  def user_menu_choice
    choice = nil
    loop do
      puts "Please choose an option:"
      puts "View a recipe (Enter a recipe number)"
      puts "Enter a new recipe (N)"
      puts "Exit the program (Q)"
      puts ""
      choice = gets.chomp.downcase
      break if valid_menu_options.include?(choice)
      puts "Sorry, invalid answer."
    end
    @choice = choice
  end
  
  def valid_menu_options
    menu_options = ['n', 'q']
    (1..@recipes.count).each { |num| menu_options << num.to_s }
    menu_options
  end

  def display_recipes
    @recipes.each_with_index do |recipe, idx|
      puts "#{idx+1}. #{recipe[:title]}"
    end
    puts ""
  end
  
  def display_single_recipe
    @current_recipe = Recipe.new
    @current_recipe.info = @recipes[@choice.to_i - 1]
    puts @current_recipe
    puts ""
    puts "Press Enter to return to the main menu."
    gets.chomp
  end
  
  def enter_new_recipe
    loop do
      @new_recipe = Recipe.new
      @new_recipe.title = user_input('recipe')
      p @new_recipe.title
      enter_recipe_ingredients
      @new_recipe.add_directions(user_input('directions'))
      @new_recipe.display
      puts ""
      p @new_recipe.info                            # Method no longer exists
      @recipes << @new_recipe.info                  # Use List#add(recipe_object) instead.
      puts "Enter another recipe? (y/n)"
      answer = nil
      loop do 
        answer = gets.chomp.downcase[0]
        break if ['y', 'n'].include?(answer)
        puts "Sorry, that is not a valid answer."
      end
      break if answer == 'n'
    end
  end
  
  def user_input(category)
    answer = nil
    loop do
      puts "What is the name of the #{category}?"
      answer = gets.chomp
      break if !answer.length.zero? && answer[0] != ' '
      puts "Sorry, that is not a valid #{category}."
      puts ""
    end
    puts ""
    answer
  end
  
  def enter_recipe_ingredients
    loop do
      ingredient = Ingredient.new
      ingredient.name = user_input('ingredient')
      puts ""
      ingredient.unit = user_input('unit of measurement')
      puts ""
      ingredient.quantity = user_input('quantity').to_f
      puts ""
      @new_recipe.add_ingredient(ingredient)
      @new_recipe.display
      puts "Enter another ingredient? (y/n)"
      answer = nil
      loop do 
        answer = gets.chomp.downcase[0]
        break if ['y', 'n'].include?(answer)
        puts "Sorry, that is not a valid answer."
      end
      break if answer == 'n'
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