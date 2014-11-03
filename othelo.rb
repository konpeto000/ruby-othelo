# -*- coding: utf-8 -*-

$player_color = 0
$pass_count = 0
$max_put = Array.new

class Reversi

  # color = 1:white -1:black
  SQUARES = 8

  # @field = 1:white -1:black 0:non
  
  def initialize
    @field = Array.new(SQUARES+2){Array.new(SQUARES+2,0)}
    @field[4][4],@field[5][4],@field[5][5],@field[4][5] = 1,-1,1,-1

  end
  
  def color_choice

    p "Choose your color (b or w)"
    while 1
      clr = gets.chop
      case clr
      when "b"
        $player_color = -1
        break
      when "w"
        $player_color = 1
        break
      else
        p "You entry b or w"
        redo
      end
    end

  end

  def showBoard
    
    print "  1 2 3 4 5 6 7 8\n"

    for j in 1..SQUARES
      print "#{j}"
      for i in 1..SQUARES

        case @field[i][j]
          when 0
          print "\e[32m"
          print(" □")
          print "\e[0m"
          when 1
          print(" ○")
          when -1
          print(" ●")
        end

      end
      print ("\n")
    end
    
  end

  def around_check(nx,ny)

    x_root = Array.new
    y_root = Array.new
    @dx_root = Array.new
    @dy_root = Array.new
    max_count = 0

    for j in 0..2
      for i in 0..2
        if @field[nx+i-1][ny+j-1] == -1 * $player_color
          x_root << i-1
          y_root << j-1
        end
      end
    end

    if x_root.length <= 0
      return false
    end

    for count in 0..x_root.length - 1

      empty_flag = 0
      x = x_root[count]
      y = y_root[count]
      dx = nx
      dy = ny
      while 1
        dx += x
        dy += y

        if dx > 8 || dy > 8 || dx < 1 || dy < 1
          empty_flag = 1
          break
        end

        if @field[dx][dy] == 0
          empty_flag = 1
          break
        end
        if @field[dx][dy] == $player_color
          break
        end

      end

      if empty_flag == 0
        max_count += 1
        @dx_root << x_root[count]
        @dy_root << y_root[count]
      end

    end
      
    if @dx_root.length > 0
      $max_put << max_count
      return true
    else
      return false
    end

  end

  def stone_put(nx,ny)

    @field[nx][ny] = $player_color

    for count in 0..@dx_root.length - 1
      x = @dx_root[count]
      y = @dy_root[count]
      dx = nx
      dy = ny
      while 1
        dx += x
        dy += y

        if @field[dx][dy] == $player_color
          break
        end

        @field[dx][dy] = -1 * @field[dx][dy]
      end
    end

  end

  def player_put

    if $pass_count >= 2
      return true
    end

    if $player_color == 1
      if pass_check
        p "White PASS!"
        return false
      end
      
      p "White you choose number (xy)[1 to 8]"
    else
      if pass_check
        p "Black PASS!"
        return false
      end

      p "Black you choose number (xy)[1 to 8]"
    end

    $pass_count = 0

    while 1
      
      # number check
      num = gets.chop
      if num[1] == nil
        p "Entry (xy)"
        redo
      end
      nx = num[0].to_i
      ny = num[1].to_i

      if !(nx > 0 && ny > 0 && nx < SQUARES + 1 && ny < SQUARES + 1)
        p "Choose number [1 to 8]"
        redo
      end

      # put check
      if !(@field[nx][ny] == 0) || !(around_check(nx,ny))
        p "Can't put"
        redo
      end 
      
      break
      
    end

    stone_put(nx,ny)
    return false
    
  end

  def pass_check

    for j in 1..SQUARES
      for i in 1..SQUARES
        if @field[i][j] != 0
          next
        end
        if around_check(i,j)
          return false
        end
      end
    end

    $pass_count += 1

    return true

  end

    
  def gameset

    w_count = 0
    b_count = 0

    for j in 1..SQUARES
      for i in 1..SQUARES
        case @field[i][j]
        when 1
          w_count += 1
        when -1
          b_count += 1
        end
      end
    end
    

    if w_count == b_count
      print "W:#{w_count} B:#{b_count} Draw!\n" 
      return true
    end
    
    if w_count > b_count
      print "W:#{w_count} B:#{b_count} White win!\n"
    else
      print "W:#{w_count} B:#{b_count} Black win!\n"
    end

  end

  def cpu

    $max_put = Array.new
    max_x = Array.new
    max_y = Array.new
    random = rand(100)

    if $pass_count >= 2
      return true
    end

    if $player_color == 1
      if pass_check
        p "White PASS!"
        return false
      end
      
    else
      if pass_check
        p "Black PASS!"
        return false
      end
    end

    $pass_count = 0

    for j in 1..SQUARES
      for i in 1..SQUARES
        if @field[i][j] != 0
          next
        end
        if around_check(i,j)
          max_x << i
          max_y << j
        end
      end
    end

    $max_put.shift
    if random > 10
      n = $max_put.index($max_put.max)
    else
      n = 0
    end
      

    if around_check(max_x[n],max_y[n])
      stone_put(max_x[n],max_y[n])
    end

    p "CPU put (#{max_x[n]},#{max_y[n]})"

    return false

  end

end


go = Reversi.new

go.color_choice

while 1

  go.showBoard

  if go.player_put
    go.gameset
    break
  end
  $player_color = -1 * $player_color

  if go.cpu
    go.gameset
    break
  end
  $player_color = -1 * $player_color

end
