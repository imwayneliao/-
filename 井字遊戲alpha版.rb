#將10進位轉成3進位
def three(integer)
  i = 0
  arr = [0,0,0,0,0,0,0,0,0]
  while i < 9
    arr[i] = integer % 3
    integer = integer / 3
    i += 1
  end
  return arr 
end

#判斷盤面合法性
def legality(arr)
  # 假設先手永遠是x
  x = arr.count(1)
  o = arr.count(2)
  if x == o + 1
    return 2 # 輪到o落子
  elsif x == o
    return 1 # 輪到x落子
  else
    return 0 # 不合法
  end  
end

#建邊
def initial()
  edge_table = Array.new(20000) { Array.new(13) }
  invedge_table = Array.new(20000) { Array.new(13) }
  i = 0
  
  while i < 3**9
    arr = three(i)
    isLegal = legality(arr)
    edge_table[i][12] = isLegal #最後一位存放目前換誰落子

    if isLegal == 0
      i += 1
      next
    end
    
    j = 0
    k = 0
    r = 0
    while j < 9
      if arr[j] == 0
        edge_table[i][k] = i + isLegal * (3 ** j)
        k += 1
      elsif arr[j] == 3 - isLegal
        invedge_table[i][r] = i - (3-isLegal)*(3**j)
        r += 1
      end
      j = j+1  
    end  

    edge_table[i][k] = -1 #遇到-1代表已經沒邊了
    invedge_table[i][r] = -1
    edge_table[i][11] = k #倒數第二位存放邊數
    i += 1

  end

  return edge_table, invedge_table
end

#判斷盤面勝負
def judge(faceint)

  face = three(faceint)
  whoWin = 0 #還不知道結果者為0，x贏為1，o贏為2，平手為3。

  #若沒有空格可下，先判平手，如果有勝負等一下會被寫入。
  if face.count(0) == 0
    whoWin = 3
  end 

  for i in 0..2 do
    #判橫線
    if face[3*i] == face[3*i+1] && face[3*i] == face[3*i+2]
      if face[3*i] == 1
        whoWin = 1
      elsif face[3*i] == 2
        whoWin = 2
      end
    end
    #判直線
    if face[i] == face[i+3] && face[i] == face[i+6]
      if face[i] == 1
        whoWin = 1
      elsif face[i] == 2
        whoWin = 2
      end
    end
  end
  #判對角線
  if face[2] == face[4] && face[2] == face[6]
    if face[2] == 1
      whoWin = 1
    elsif face[2] == 2
      whoWin = 2
    end
  elsif face[0] == face[4] && face[0] == face[8]
    if face[0] == 1
      whoWin = 1
    elsif face[0] == 2
      whoWin = 2
    end       
  end

  return whoWin  
end


#建立所有盤面將來的結果以及策略
def whoWin()
  edge_table, invedge_table = initial()
  whoWin = Array.new(20000)
  strategy = Array.new(20000)
  known = Array.new(20000)
  i = 0
  head = 0
  tail = 0
  temp = 0
  
  #判斷所有盤面勝負，把已經分出勝負者丟入known裏
  while i < 3**9
    if legality(three(i)) != 0
      if judge(i) != 0
        known[tail] = i 
        tail += 1     
      end
      whoWin[i] = judge(i)
    end
    i+=1
  end
  #開始建立所有結果
  while head < tail
    faceID = known[head]
    result = whoWin[faceID]
    turn = edge_table[faceID][12] #之前這已有存放換誰落子
    i = 0
    out = []
    ans = []
    if result == 0 #未知結果者，看他會連到哪裡
      while edge_table[faceID][i] != -1
        out[i] = edge_table[faceID][i] 
        ans[i] = whoWin[out[i]]
        i += 1
      end

      if ans.include? turn #如果連到的有贏，那就贏了
        whoWin[faceID] = turn
        choose = rand(ans.length) #從可以贏的支線隨機選
        while ans[choose] != turn
          choose = rand(ans.length)
        end 
        strategy[faceID] = out[choose]
      elsif ans.include? 3 #如果連到的都沒贏，但有平手，那就平手
        whoWin[faceID] = 3
        choose = rand(ans.length) #從可以平手的支線隨機選
        while ans[choose] != 3
          choose = rand(ans.length)
        end 
        strategy[faceID] = out[choose]
      else
        whoWin[faceID] = 3 - turn #如果連到的都輸，那就真的輸了
        strategy[faceID] = out[rand(out.length)]
      end
    end
    i = 0
    while invedge_table[faceID][i] != -1 #拔邊
      temp = invedge_table[faceID][i]
      edge_table[temp][11] -= 1
      if edge_table[temp][11] == 0 #如果邊沒了，就丟進known裡等判
        known[tail] = temp
        tail += 1
      end
      i += 1
    end
    head += 1
  end
  

  return whoWin, strategy
end

# display the board
def display_board(board)
  puts " #{board[0]} | #{board[1]} | #{board[2]} "
  puts "-----------"
  puts " #{board[3]} | #{board[4]} | #{board[5]} "
  puts "-----------"
  puts " #{board[6]} | #{board[7]} | #{board[8]} "
end

def main()
  # 井字遊戲

  # setting
  num_of_steps = 0
  board = [" "," "," "," "," "," "," "," "," "]
  turn = 0
  curface = 0 
  whoWin, strategy = whoWin() 

  i = 0
  j = 0

  # 正式遊戲開始

  # 遊戲規則解說

  puts "這是個井字遊戲，誰先連成一直線誰就贏了!"
  puts "從左到右，上到下分別是0,1,2,3,4,5,6,7,8"
  puts "先手執x，後手執o"
  display_board(board)

  # 玩家選擇先後手

  print "您要選擇先手還是後手？先首選1，後手選2"
  turn = Integer(gets)
  while turn != 1 && turn != 2
    puts "請不要亂選！"
    print "您要選擇先手還是後手？先首選1，後手選2"
    turn = Integer(gets)
  end

  # 玩家後手情形，電腦先下
  if turn == 2
    # 電腦下
    temp = strategy[curface]
    place = 0
    chess = (temp - curface)
    while chess % 3 == 0
      chess = chess / 3
      place += 1
    end
    if chess == 1
      board[place] = "x"
    else
      board[place] = "o"
    end
    display_board(board)
    curface = temp
    num_of_steps += 1
  end

  # start playing
  while num_of_steps < 9
  #玩家下棋
      
    # 玩家選擇位置
      
    print "請您選擇您要下的位置："
    player = Integer(gets) % 9
      
      
    #  確認玩家下棋的有效性，有效則畫出來

    while board[player] != " "
      print "此位置已有棋子，請重新選擇您要下的位置："
      player = Integer(gets) % 9
    end

    if num_of_steps % 2 == 0
      board[player] = "x"
      display_board(board)
      curface += 1 * (3**player)
    else
      board[player] = "o"
      display_board(board)
      curface += 2 * (3**player)
    end
    num_of_steps += 1
      
      # 玩家下完判斷一次勝負
      
    if judge(curface) == turn 
      puts "You win!"
      break
    elsif judge(curface) == 3
      puts "Tie!"
      break
    end
      

    # 電腦下
    temp = strategy[curface]
    place = 0
    chess = (temp - curface)
    while chess % 3 == 0
      chess = chess / 3
      place += 1
    end
    if chess == 1
      board[place] = "x"
    else
      board[place] = "o"
    end
    display_board(board)
    curface = temp
    num_of_steps += 1
      
    # 電腦下完判斷一次勝負
    if judge(curface) == 3 - turn
      puts "Oh, you lose!"
      break
    elsif judge(curface) == 3
      puts "Tie!"
      break
    end
  end 
end

main()