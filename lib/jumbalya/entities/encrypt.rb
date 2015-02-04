require 'digest/sha1'

module Jumbalya

  def self.encrypt(string, password)
    begin
      eab(string, password)
    rescue
      eaa(string, password)
    end
  end

  def self.unencrypt(string, password)
    version = string[0..1]
    puts version
    if version == 'aa'
      uaa(string, password)
    elsif version == 'ab'
      uab(string, password)
    end
  end

  private

  def self.eab(string, password)
    digest_password_512(password)
    nums = string.split('').map {|x| @@num_assign_hash[x] if @@num_assign_hash[x] != nil}.compact.inject(:+).split('') # takes string splits into individual characters and assigns a value from num_assign_hash. removes illegal characters, returns array containing one digit string integers
    nums = nums.unshift(nums.last)
    nums.pop # takes array of string integers, moves last index to front of array, ['1','2','3','4'] => ['4','1','2','3']
    even, odd = [],[]
    for i in 0...nums.length
      if i % 2 == 0
        even << nums[i]
      else
        odd << nums[i]
      end
    end
    nums = even.reverse.concat(odd)
    nums = nums.inject(:+).scan(/../) # converts ['4','1','2','3'] => ['41','23']
    set_counter_ab
    letters = Array.new
    for i in 0...nums.length # takes each array element and assigns 2 letter pair for each element
      y = (nums[i].to_i * @counter) + @counter3 + @digested_password[i%128]
      letters << @@letter_assign_hash[y]
      counter_ab(@digested_password[127 - i % 128], @digested_password[127 - (i + 5) % 128])
    end
    letters
    encrypt = 'ab' + letters.inject(:+) # converts array to string ['ab','cd'] => 'abcd'
    encrypt
  end

  def self.uab(string, password)
    digest_password_512(password)
    letters = string[2..-1].scan(/../).map { |x| @@letter_assign_hash.invert[x]}
    set_counter_ab
    nums = Array.new
    for i in 0...letters.length
      y = ((letters[i] - @counter3 - @digested_password[i%128])/@counter).to_s
      if y.length == 2
        nums << y
      else
        nums << ('0' + y)
      end
      counter_ab(@digested_password[127 - i % 128], @digested_password[127 - (i + 5) % 128])
    end
    nums = nums.inject(:+).split('')
    even = nums[0...nums.length.to_f/2].reverse
    odd = nums[nums.length.to_f/2..-1]
    nums = []
    for i in 0...even.length
      nums << even[i]
      nums << odd[i]
    end
    nums << nums[0]
    nums.shift
    nums = nums.inject(:+).scan(/../)
    uencrypt = nums.map {|x| @@num_assign_hash.invert[x]}.compact.inject(:+)
    uencrypt
  end

  def self.eaa(string, password)
    digest_password_SHA1(password)
    nums = string.split('').map {|x| @@num_assign_hash[x] if @@num_assign_hash[x] != nil}.compact.inject(:+).split('') # takes string splits into individual characters and assigns a value from num_assign_hash. removes illegal characters, returns array containing one digit string integers
    nums = nums.unshift(nums.last)
    nums.pop # takes array of string integers, moves last index to front of array, ['1','2','3','4'] => ['4','1','2','3']
    even, odd = [],[]
    for i in 0...nums.length
      if i % 2 == 0
        even << nums[i]
      else
        odd << nums[i]
      end
    end
    nums = even.reverse.concat(odd)
    nums = nums.inject(:+).scan(/../) # converts ['4','1','2','3'] => ['41','23']
    set_counter
    letters = Array.new
    for i in 0...nums.length # takes each array element and assigns 2 letter pair for each element
      y = (nums[i].to_i * @counter) + @counter3 + @digested_password[i%40]
      letters << @@letter_assign_hash[y]
      counter(@digested_password[39 - i%40], @digested_password[39 - (i+5)%40])
    end
    letters
    encrypt = 'aa' + letters.inject(:+) # converts array to string ['ab','cd'] => 'abcd'
    encrypt
  end

  def self.uaa(string, password)
    digest_password_SHA1(password)
    letters = string[2..-1].scan(/../).map { |x| @@letter_assign_hash.invert[x]}
    set_counter
    nums = Array.new
    for i in 0...letters.length
      y = ((letters[i] - @counter3 - @digested_password[i%40])/@counter).to_s
      if y.length == 2
        nums << y
      else
        nums << ('0' + y)
      end
      counter(@digested_password[39 - i % 40], @digested_password[39 - (i + 5) % 40])
    end
    nums = nums.inject(:+).split('')
    even = nums[0...nums.length.to_f/2].reverse
    odd = nums[nums.length.to_f/2..-1]
    nums = []
    for i in 0...even.length
      nums << even[i]
      nums << odd[i]
    end
    nums << nums[0]
    nums.shift
    nums = nums.inject(:+).scan(/../)
    uencrypt = nums.map {|x| @@num_assign_hash.invert[x]}.compact.inject(:+)
    uencrypt
  end

  @@hexadecimal_to_decimal = {'a'=>10, 'b'=>11, 'c'=>12, 'd'=>13, 'e'=>14, 'f'=>15}
  @@num_assign_hash = {"!"=>"99", "'"=>"98", "Q"=>"97", "A"=>"96", "Z"=>"95", "@"=>"94", "W"=>"93", "S"=>"92", "X"=>"91", "#"=>"90", "E"=>"89", "D"=>"88", "C"=>"87", "$"=>"86", "R"=>"85", "F"=>"84", "V"=>"83", "%"=>"82", "T"=>"81", "G"=>"80", "B"=>"79", "^"=>"78", "Y"=>"77", "H"=>"76", "N"=>"75", "&"=>"74", "U"=>"73", "J"=>"72", "M"=>"71", "*"=>"70", "I"=>"69", "K"=>"68", "<"=>"67", "("=>"66", "O"=>"65", "L"=>"64", ">"=>"63", ")"=>"62", "P"=>"61", ":"=>"60", "?"=>"59", "{"=>"58", "+"=>"57", "}"=>"56", " "=>"55", "1"=>"54", "q"=>"53", "a"=>"52", "z"=>"51", "2"=>"50", "w"=>"49", "s"=>"48", "x"=>"47", "3"=>"46", "e"=>"45", "d"=>"44", "c"=>"43", "4"=>"42", "r"=>"41", "f"=>"40", "v"=>"39", "5"=>"38", "t"=>"37", "g"=>"36", "b"=>"35", "6"=>"34", "y"=>"33", "h"=>"32", "n"=>"31", "7"=>"30", "u"=>"29", "j"=>"28", "m"=>"27", "8"=>"26", "i"=>"25", "k"=>"24", ","=>"23", "9"=>"22", "o"=>"21", "l"=>"20", "."=>"19", "0"=>"18", "p"=>"17", ";"=>"16", "/"=>"15", "-"=>"14", "["=>"13", "="=>"12", "]"=>"11", '"'=>"10", "|"=>"09", "_"=>"08"}
  @@letter_assign_hash = {1=>"zj", 2=>"zi", 3=>"zh", 4=>"zg", 5=>"zf", 6=>"ze", 7=>"zd", 8=>"zc", 9=>"zb", 10=>"za", 11=>"yz", 12=>"yy", 13=>"yx", 14=>"yw", 15=>"yv", 16=>"yu", 17=>"yt", 18=>"ys", 19=>"yr", 20=>"yq", 21=>"yp", 22=>"yo", 23=>"yn", 24=>"ym", 25=>"yl", 26=>"yk", 27=>"yj", 28=>"yi", 29=>"yh", 30=>"yg", 31=>"yf", 32=>"ye", 33=>"yd", 34=>"yc", 35=>"yb", 36=>"ya", 37=>"xz", 38=>"xy", 39=>"xx", 40=>"xw", 41=>"xv", 42=>"xu", 43=>"xt", 44=>"xs", 45=>"xr", 46=>"xq", 47=>"xp", 48=>"xo", 49=>"xn", 50=>"xm", 51=>"xl", 52=>"xk", 53=>"xj", 54=>"xi", 55=>"xh", 56=>"xg", 57=>"xf", 58=>"xe", 59=>"xd", 60=>"xc", 61=>"xb", 62=>"xa", 63=>"wz", 64=>"wy", 65=>"wx", 66=>"ww", 67=>"wv", 68=>"wu", 69=>"wt", 70=>"ws", 71=>"wr", 72=>"wq", 73=>"wp", 74=>"wo", 75=>"wn", 76=>"wm", 77=>"wl", 78=>"wk", 79=>"wj", 80=>"wi", 81=>"wh", 82=>"wg", 83=>"wf", 84=>"we", 85=>"wd", 86=>"wc", 87=>"wb", 88=>"wa", 89=>"vz", 90=>"vy", 91=>"vx", 92=>"vw", 93=>"vv", 94=>"vu", 95=>"vt", 96=>"vs", 97=>"vr", 98=>"vq", 99=>"vp", 100=>"vo", 101=>"vn", 102=>"vm", 103=>"vl", 104=>"vk", 105=>"vj", 106=>"vi", 107=>"vh", 108=>"vg", 109=>"vf", 110=>"ve", 111=>"vd", 112=>"vc", 113=>"vb", 114=>"va", 115=>"uz", 116=>"uy", 117=>"ux", 118=>"uw", 119=>"uv", 120=>"uu", 121=>"ut", 122=>"us", 123=>"ur", 124=>"uq", 125=>"up", 126=>"uo", 127=>"un", 128=>"um", 129=>"ul", 130=>"uk", 131=>"uj", 132=>"ui", 133=>"uh", 134=>"ug", 135=>"uf", 136=>"ue", 137=>"ud", 138=>"uc", 139=>"ub", 140=>"ua", 141=>"tz", 142=>"ty", 143=>"tx", 144=>"tw", 145=>"tv", 146=>"tu", 147=>"tt", 148=>"ts", 149=>"tr", 150=>"tq", 151=>"tp", 152=>"to", 153=>"tn", 154=>"tm", 155=>"tl", 156=>"tk", 157=>"tj", 158=>"ti", 159=>"th", 160=>"tg", 161=>"tf", 162=>"te", 163=>"td", 164=>"tc", 165=>"tb", 166=>"ta", 167=>"sz", 168=>"sy", 169=>"sx", 170=>"sw", 171=>"sv", 172=>"su", 173=>"st", 174=>"ss", 175=>"sr", 176=>"sq", 177=>"sp", 178=>"so", 179=>"sn", 180=>"sm", 181=>"sl", 182=>"sk", 183=>"sj", 184=>"si", 185=>"sh", 186=>"sg", 187=>"sf", 188=>"se", 189=>"sd", 190=>"sc", 191=>"sb", 192=>"sa", 193=>"rz", 194=>"ry", 195=>"rx", 196=>"rw", 197=>"rv", 198=>"ru", 199=>"rt", 200=>"rs", 201=>"rr", 202=>"rq", 203=>"rp", 204=>"ro", 205=>"rn", 206=>"rm", 207=>"rl", 208=>"rk", 209=>"rj", 210=>"ri", 211=>"rh", 212=>"rg", 213=>"rf", 214=>"re", 215=>"rd", 216=>"rc", 217=>"rb", 218=>"ra", 219=>"qz", 220=>"qy", 221=>"qx", 222=>"qw", 223=>"qv", 224=>"qu", 225=>"qt", 226=>"qs", 227=>"qr", 228=>"qq", 229=>"qp", 230=>"qo", 231=>"qn", 232=>"qm", 233=>"ql", 234=>"qk", 235=>"qj", 236=>"qi", 237=>"qh", 238=>"qg", 239=>"qf", 240=>"qe", 241=>"qd", 242=>"qc", 243=>"qb", 244=>"qa", 245=>"pz", 246=>"py", 247=>"px", 248=>"pw", 249=>"pv", 250=>"pu", 251=>"pt", 252=>"ps", 253=>"pr", 254=>"pq", 255=>"pp", 256=>"po", 257=>"pn", 258=>"pm", 259=>"pl", 260=>"pk", 261=>"pj", 262=>"pi", 263=>"ph", 264=>"pg", 265=>"pf", 266=>"pe", 267=>"pd", 268=>"pc", 269=>"pb", 270=>"pa", 271=>"oz", 272=>"oy", 273=>"ox", 274=>"ow", 275=>"ov", 276=>"ou", 277=>"ot", 278=>"os", 279=>"or", 280=>"oq", 281=>"op", 282=>"oo", 283=>"on", 284=>"om", 285=>"ol", 286=>"ok", 287=>"oj", 288=>"oi", 289=>"oh", 290=>"og", 291=>"of", 292=>"oe", 293=>"od", 294=>"oc", 295=>"ob", 296=>"oa", 297=>"nz", 298=>"ny", 299=>"nx", 300=>"nw", 301=>"nv", 302=>"nu", 303=>"nt", 304=>"ns", 305=>"nr", 306=>"nq", 307=>"np", 308=>"no", 309=>"nn", 310=>"nm", 311=>"nl", 312=>"nk", 313=>"nj", 314=>"ni", 315=>"nh", 316=>"ng", 317=>"nf", 318=>"ne", 319=>"nd", 320=>"nc", 321=>"nb", 322=>"na", 323=>"mz", 324=>"my", 325=>"mx", 326=>"mw", 327=>"mv", 328=>"mu", 329=>"mt", 330=>"ms", 331=>"mr", 332=>"mq", 333=>"mp", 334=>"mo", 335=>"mn", 336=>"mm", 337=>"ml", 338=>"mk", 339=>"mj", 340=>"mi", 341=>"mh", 342=>"mg", 343=>"mf", 344=>"me", 345=>"md", 346=>"mc", 347=>"mb", 348=>"ma", 349=>"lz", 350=>"ly", 351=>"lx", 352=>"lw", 353=>"lv", 354=>"lu", 355=>"lt", 356=>"ls", 357=>"lr", 358=>"lq", 359=>"lp", 360=>"lo", 361=>"ln", 362=>"lm", 363=>"ll", 364=>"lk", 365=>"lj", 366=>"li", 367=>"lh", 368=>"lg", 369=>"lf", 370=>"le", 371=>"ld", 372=>"lc", 373=>"lb", 374=>"la", 375=>"kz", 376=>"ky", 377=>"kx", 378=>"kw", 379=>"kv", 380=>"ku", 381=>"kt", 382=>"ks", 383=>"kr", 384=>"kq", 385=>"kp", 386=>"ko", 387=>"kn", 388=>"km", 389=>"kl", 390=>"kk", 391=>"kj", 392=>"ki", 393=>"kh", 394=>"kg", 395=>"kf", 396=>"ke", 397=>"kd", 398=>"kc", 399=>"kb", 400=>"ka", 401=>"jz", 402=>"jy", 403=>"jx", 404=>"jw", 405=>"jv", 406=>"ju", 407=>"jt", 408=>"js", 409=>"jr", 410=>"jq", 411=>"jp", 412=>"jo", 413=>"jn", 414=>"jm", 415=>"jl", 416=>"jk", 417=>"jj", 418=>"ji", 419=>"jh", 420=>"jg", 421=>"jf", 422=>"je", 423=>"jd", 424=>"jc", 425=>"jb", 426=>"ja", 427=>"iz", 428=>"iy", 429=>"ix", 430=>"iw", 431=>"iv", 432=>"iu", 433=>"it", 434=>"is", 435=>"ir", 436=>"iq", 437=>"ip", 438=>"io", 439=>"in", 440=>"im", 441=>"il", 442=>"ik", 443=>"ij", 444=>"ii", 445=>"ih", 446=>"ig", 447=>"if", 448=>"ie", 449=>"id", 450=>"ic", 451=>"ib", 452=>"ia", 453=>"hz", 454=>"hy", 455=>"hx", 456=>"hw", 457=>"hv", 458=>"hu", 459=>"ht", 460=>"hs", 461=>"hr", 462=>"hq", 463=>"hp", 464=>"ho", 465=>"hn", 466=>"hm", 467=>"hl", 468=>"hk", 469=>"hj", 470=>"hi", 471=>"hh", 472=>"hg", 473=>"hf", 474=>"he", 475=>"hd", 476=>"hc", 477=>"hb", 478=>"ha", 479=>"gz", 480=>"gy", 481=>"gx", 482=>"gw", 483=>"gv", 484=>"gu", 485=>"gt", 486=>"gs", 487=>"gr", 488=>"gq", 489=>"gp", 490=>"go", 491=>"gn", 492=>"gm", 493=>"gl", 494=>"gk", 495=>"gj", 496=>"gi", 497=>"gh", 498=>"gg", 499=>"gf", 500=>"ge", 501=>"gd", 502=>"gc", 503=>"gb", 504=>"ga", 505=>"fz", 506=>"fy", 507=>"fx", 508=>"fw", 509=>"fv", 510=>"fu", 511=>"ft", 512=>"fs", 513=>"fr", 514=>"fq", 515=>"fp", 516=>"fo", 517=>"fn", 518=>"fm", 519=>"fl", 520=>"fk", 521=>"fj", 522=>"fi", 523=>"fh", 524=>"fg", 525=>"ff", 526=>"fe", 527=>"fd", 528=>"fc", 529=>"fb", 530=>"fa", 531=>"ez", 532=>"ey", 533=>"ex", 534=>"ew", 535=>"ev", 536=>"eu", 537=>"et", 538=>"es", 539=>"er", 540=>"eq", 541=>"ep", 542=>"eo", 543=>"en", 544=>"em", 545=>"el", 546=>"ek", 547=>"ej", 548=>"ei", 549=>"eh", 550=>"eg", 551=>"ef", 552=>"ee", 553=>"ed", 554=>"ec", 555=>"eb", 556=>"ea", 557=>"dz", 558=>"dy", 559=>"dx", 560=>"dw", 561=>"dv", 562=>"du", 563=>"dt", 564=>"ds", 565=>"dr", 566=>"dq", 567=>"dp", 568=>"do", 569=>"dn", 570=>"dm", 571=>"dl", 572=>"dk", 573=>"dj", 574=>"di", 575=>"dh", 576=>"dg", 577=>"df", 578=>"de", 579=>"dd", 580=>"dc", 581=>"db", 582=>"da", 583=>"cz", 584=>"cy", 585=>"cx", 586=>"cw", 587=>"cv", 588=>"cu", 589=>"ct", 590=>"cs", 591=>"cr", 592=>"cq", 593=>"cp", 594=>"co", 595=>"cn", 596=>"cm", 597=>"cl", 598=>"ck", 599=>"cj", 600=>"ci", 601=>"ch", 602=>"cg", 603=>"cf", 604=>"ce", 605=>"cd", 606=>"cc", 607=>"cb", 608=>"ca", 609=>"bz", 610=>"by", 611=>"bx", 612=>"bw", 613=>"bv", 614=>"bu", 615=>"bt", 616=>"bs", 617=>"br", 618=>"bq", 619=>"bp", 620=>"bo", 621=>"bn", 622=>"bm", 623=>"bl", 624=>"bk", 625=>"bj", 626=>"bi", 627=>"bh", 628=>"bg", 629=>"bf", 630=>"be", 631=>"bd", 632=>"bc", 633=>"bb", 634=>"ba", 635=>"az", 636=>"ay", 637=>"ax", 638=>"aw", 639=>"av", 640=>"au", 641=>"at", 642=>"as", 643=>"ar", 644=>"aq", 645=>"ap", 646=>"ao", 647=>"an", 648=>"am", 649=>"al", 650=>"ak", 651=>"aj", 652=>"ai", 653=>"ah", 654=>"ag", 655=>"af", 656=>"ae", 657=>"ad", 658=>"ac", 659=>"ab", 660=>"aa"}

  def self.digest_password_SHA1(password)
    @digested_password = Digest::SHA1.hexdigest( password + '"' + ENV['SALT'] + '"' ).split('').map { |x| @@hexadecimal_to_decimal[x] ? @@hexadecimal_to_decimal[x] : x.to_i  }
  end

  def self.digest_password_512(password)
    @digested_password = Digest::SHA512.hexdigest( password + ENV['SALT'] ).split('').map { |x| @@hexadecimal_to_decimal[x] ? @@hexadecimal_to_decimal[x] : x.to_i  }
  end

  def self.set_counter_ab
    i = 0
    if @digested_password[13 + i] <= 11
      @counter = @digested_password[13 + i]
    else
      while @digested_password[13 + i] > 11
        i += 1
        if i == 100
          @counter = 3
          break
        end
      end
    end
    @counter2 = @digested_password[@counter + 20] % 4
    @counter3 = @digested_password[@counter2 + 9] + @digested_password[@counter2 + 10] + @digested_password[@counter2 + 11] + @counter2
  end

  def self.counter_ab(hexnumber1, hexnumber2)
    @counter -= hexnumber1 % 4
    @counter2 += hexnumber2 % 2
    if @counter <= 0
      @counter = 6
    end
    if @counter2 == 4
      @counter2 = 0
      @counter3 += 1
    end
    if @counter3 == 21 + hexnumber1 + hexnumber2
      @counter3 = 0
    end
  end

  def self.set_counter
    @counter = (@digested_password[4] % 6) + 1
    @counter2 = @digested_password[@counter + 20] % 4
    @counter3 = @digested_password[@counter2 + 9] + @digested_password[@counter2 + 10] + @digested_password[@counter2 + 11] + @counter2
  end

  def self.counter(hexnumber1, hexnumber2)
    @counter -= hexnumber1 % 2
    @counter2 += hexnumber2 % 2
    if @counter == 0
      @counter = 6
    end
    if @counter2 == 4
      @counter2 = 0
      @counter3 += 1
    end
    if @counter3 == 21 + hexnumber1 + hexnumber2
      @counter3 = 0
    end
  end
end