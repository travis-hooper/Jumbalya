require 'digest/sha1'

module Jumbalya
  module AA
    include Essentials

    def self.encrypt(string, password)
      digest_password_SHA1(password)
      nums = string.split('').map {|x| @@NumAssignHash[x] if @@NumAssignHash[x] != nil}.compact.inject(:+).split('') # takes string splits into individual characters and assigns a value from num_assign_hash. removes illegal characters, returns array containing one digit string integers
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

    def self.unencrypt(string, password)
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
      unencrypt = nums.map {|x| @@NumAssignHash.invert[x]}.compact.inject(:+)
      unencrypt
    end

  def self.digest_password_SHA1(password)
    @digested_password = Digest::SHA1.hexdigest( password + '"' + ENV['SALT'] + '"' ).split('').map { |x| @@HexadecimalToDecimal[x] ? @@HexadecimalToDecimal[x] : x.to_i  }
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