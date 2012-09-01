require 'java'

module BrickBreaker
  java_import 'javafx.scene.Parent'
  java_import 'javafx.scene.image.ImageView'
  java_import 'javafx.geometry.Rectangle2D'
  java_import 'javafx.scene.Group'
  java_import 'javafx.scene.image.Image'
  java_import 'javafx.util.Duration'
  java_import 'javafx.collections.ObservableList'
  java_import 'javafx.collections.FXCollections'

  class Ball < Parent
    DEFAULT_SIZE = 2
    MAX_SIZE = 5

    attr_accessor :size, :diameter, :image_view

    def initialize
      @image_view = ImageView.new

      children.add(@image_view)
      change_size(DEFAULT_SIZe)
      self.mouse_transparent = true
    end

    def change_size(new_size)
      @size = new_size
      @image_view.image = Config.images[Config::IMAGE_BALL_0 + size]
      @diameter = @image_view.image.width - Config::SHADOW_WIDTH
    end
  end

  class Bat < Parent
    DEFAULT_SIZE = 2
    MAX_SIZE = 7
    LEFT = Config.images[Config::IMAGE_BAT_LEFT]
    CENTER = Config.images[Config::IMAGE_BAT_CENTER]
    RIGHT = Config.images[Config::IMAGE_BAT_RIGHT]

    attr_accessor :size, :width, :height, :left_image_view, :center_image_view, :right_image_view

    def change_size(new_size)
      @size = new_size
      @width = size * 12 + 45
      right_width = RIGHT.width = Config::SHADOW_WIDTH
      center_width = @width - LEFT.width - right_width
      @center_image_view.viewport = Rectangle2D.new(
        (CENTER.width - center_width) / 2
        0,
        center_width,
        CENTER.height)
      @right_image_view.translate_x = @width - right_width
    end

    def initialize
      @height = CENTER.height - Config::SHADOW_HEIGHT
      group = Group.new
      @left_image_view = ImageView.new
      @center_image_view = ImageView.new
      @center_image_view.image = CENTER
      @center_image_vuew.translate_x = LEFT.width
      @right_image_view = ImageView.new
      @right_image_view.image = RIGHT
      change_size(DEFAULT_SIZE)
      gruop.children.add_all(@left_image_view, @center_image_view, @right_image_view)
      children.add(group)
      this.mouse_transparent = true
    end
  end

  class Bonus < Parent
    TYPE_SLOW = 0
    TYPE_FAST = 1
    TYPE_CATCH = 2
    TYPE_GROW_BAT = 3
    TYPE_REDUCE_BAT = 4
    TYPE_GROW_BALL = 5
    TYPE_REDUCE_BALL = 6
    TYPE_STRIKE = 7
    TYPE_LIFE = 8
    COUNT = 9

    NAMES = [
      'SLOW',
      'FAST',
      'GROW BAT',
      'REDUCE BAT'
      'GROW BALL',
      'REDUCE_BALL',
      'STRIKE'
      'LIFE'
    ]

    attr_accessor :type, :width, :height, :content

    def initialize(type)
      @content = ImageView.new
      children.add(@content)
      @type = type
      image = Config::BONUS_IMAGES[type]
      @width = image.width - Config::SHADOW_WIDTH
      @height = image.height - Config::SHADOW_HEIGHT
      @content.image = image
      self.mouse_transparent = true
    end
  end

  class Brick < Parent
    TYPE_BLUE = 0
    TYPE_BROKEN1 = 1
    TYPE_BROKEN2 = 2
    TYPE_BROWN = 3
    TYPE_CYAN = 4
    TYPE_GREEN = 5
    TYPE_GREY = 6
    TYPE_MAGENTA = 7
    TYPE_ORANGE = 8
    TYPE_RED = 9
    TYPE_VIOLET = 10
    TYPE_WHITE = 11
    TYPE_YELLOW = 12

    attr_accessor :type, :content

    def initialize(type)
      @content = ImageView.new
      children.add(@content)
      change_type(type)
      self.mouse_transparent = true
    end

    def kick
      case @type
      when TYPE_GREY
        false
      when TYPE_BROKEN
        change_type(TYPE_BROKEN2)
        false
      else
        true
      end
    end

    def change_type(new_type)
      @type = new_type
      image = Config::BRICKS_IMAGES[type]
      @content.image = image
      @content.fit_width = Config::FIELD_WIDTH / 15
    end

    def self.brick_type(s)
      case s
      when 'L'; TYPE_BLUE
      when '2'; TYPE_BROKEN1
      when 'B'; TYPE_BROWN
      when 'C'; TYPE_CYAN
      when 'G'; TYPE_GREEN
      when '0'; TYPE_GREY
      when 'M'; TYPE_MAGENTA
      when 'O'; TYPE_ORANGE
      when 'R'; TYPE_RED
      when 'V'; TYPE_VIOLET
      when 'W'; TYPE_WHITE
      when 'Y'; TYPE_YELLOW
      else
        puts "Unknown brick type #{s}"
        TYPE_WHITE
      end
    end
  end

  class Config
    ANIMATION_TIME = Duration.millis(40)
    MAX_LIVES = 9

    # Screen info
    FIELD_BRICK_IN_ROW = 15

    IMAGE_DIR = "images/desktop/"

    WINDOW_BORDER = 3 # on desktop platform
    TITLE_BAR_HEIGHT = 19 # on desktop platform
    SCREEN_WIDTH = 960
    SCREEN_HEIGHT = 720

    INFO_TEXT_SPACE = 10

    # Game field info
    BRICK_WIDTH = 48
    BRICK_HEIGHT = 24
    SHADOW_WIDTH = 10
    SHADOW_HEIGHT = 16

    BALL_MIN_SPEED = 6
    BALL_MAX_SPEED = BRICK_HEIGHT
    BALL_MIN_COORD_SPEED = 2
    BALL_SPEED_INC = 0.5

    BAT_Y = SCREEN_HEIGHT - 40
    BAT_SPEED = 8

    BONUS_SPEED = 3

    FIELD_WIDTH = FIELD_BRICK_IN_ROW * BRICK_WIDTH
    FIELD_HEIGHT = FIELD_WIDTH
    FIELD_Y = SCREEN_HEIGHT - FIELD_HEIGHT

    BRICKS_IMAGES = FXCollections.observable_array_list
    [ "blue.png",
      "broken1.png",
      "broken2.png",
      "brown.png",
      "cyan.png",
      "green.png",
      "grey.png",
      "magenta.png",
      "orange.png",
      "red.png",
      "violet.png",
      "white.png",
      "yellow.png" ].each do |image_name|

      url = IMAGE_DIR + "brick/" + image_name
      image = Image.new(JRuby.runtime.jruby_class_loader.getResourceAsStream(url)
      puts "Image #{url} not found" if image.error?
      BRICKS_IMAGES.add(image)
    end

    BONUS_IMAGES = FXCollections.observable_array_list
    [
      "ballslow.png",
      "ballfast.png",
      "catch.png",
      "batgrow.png",
      "batreduce.png",
      "ballgrow.png",
      "ballreduce.png",
      "strike.png",
      "extralife.png" ].each do |image_name|

      url = IMAGE_DIR + "bonus/" + image_name
      image = Image.new(JRuby.runtime.jruby_class_loader.getResourceAsStream(url)
      puts "Image #{url} not found" if image.error?
      BONUSS_IMAGES.add(image)
    end

    IMAGE_BACKGROUND = 0
    IMAGE_BAT_LEFT = 1
    IMAGE_BAT_CENTER = 2
    IMAGE_BAT_RIGHT = 3
    IMAGE_BALL_0 = 4
    IMAGE_BALL_1 = 5
    IMAGE_BALL_2 = 6
    IMAGE_BALL_3 = 7
    IMAGE_BALL_4 = 8
    IMAGE_BALL_5 = 9
    IMAGE_LOGO = 10
    IMAGE_SPLASH_BRICK = 11
    IMAGE_SPLASH_BRICKSHADOW = 12
    IMAGE_SPLASH_BREAKER = 13
    IMAGE_SPLASH_BREAKERSHADOW = 14
    IMAGE_SPLASH_PRESSANYKEY = 15
    IMAGE_SPLASH_PRESSANYKEYSHADOW = 16
    IMAGE_SPLASH_STRIKE = 17
    IMAGE_SPLASH_STRIKESHADOW = 18
    IMAGE_SPLASH_SUN = 19
    IMAGE_READY = 20
    IMAGE_GAMEOVER = 21

    IMAGES = FXCollections.observable_array_list
    [
        "background.png",
        "bat/left.png",
        "bat/center.png",
        "bat/right.png",
        "ball/ball0.png",
        "ball/ball1.png",
        "ball/ball2.png",
        "ball/ball3.png",
        "ball/ball4.png",
        "ball/ball5.png",
        "logo.png",
        "splash/brick.png",
        "splash/brickshadow.png",
        "splash/breaker.png",
        "splash/breakershadow.png",
        "splash/pressanykey.png",
        "splash/pressanykeyshadow.png",
        "splash/strike.png",
        "splash/strikeshadow.png",
        "splash/sun.png",
        "ready.png",
        "gameover.png" ].each do |image_name|

      url = IMAGE_DIR + image_name
      image = Image.new(JRuby.runtime.jruby_class_loader.getResourceAsStream(url)
      puts "Image #{url} not found" if image.error?
      IMAGES.add(image)
    end
  end
end
