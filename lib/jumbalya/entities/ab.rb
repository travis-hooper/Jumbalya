require 'digest/sha1'

module Jumbalya
  module AB
    include Essentials

    def self.encrypt(string, password)
      digest_password(password)
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
      j,k = 0,0
      for i in 0...nums.length # takes each array element and assigns 2 letter pair for each element
        y = nums[i].to_i + 100 * @counter + @counter3 + @digested_password[ (i + j + k + i * j * k) % 128 ] # y <= 660
        letters << @@letter_assign_hash[y]
        counter( set_hexnumber(i,j,0), set_hexnumber(i,j,1) )
        if i % 127 == 0
          j += 1
          if j % 127 == 0
            k += 1
          end
        end
      end
      encrypt = 'ab' + letters.inject(:+) # converts array to string ['ab','cd'] => 'abcd'
      encrypt
    end

    def self.unencrypt(string, password)
      digest_password(password)
      letters = string[2..-1].scan(/../).map { |x| @@letter_assign_hash.invert[x]}
      set_counter
      nums = Array.new
      j,k = 0,0
      for i in 0...letters.length
        y = (letters[i] - (100 * @counter) - @counter3 -  @digested_password[ (i + j + k + i * j * k) % 128 ]).to_s
        if y.length == 2
          nums << y
        else
          nums << ('0' + y)
        end
        counter( set_hexnumber(i,j,0), set_hexnumber(i,j,1) )
        if i % 127 == 0
          j += 1
          if j % 127 == 0
            k += 1
          end
        end 
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
      unencrypt = nums.map {|x| @@num_assign_hash.invert[x]}.compact.inject(:+)
      unencrypt
    end

    def self.digest_password(password)
      @digested_password = Digest::SHA512.hexdigest( password + ENV['SALT'] ).split('').map { |x| @@hexadecimal_to_decimal[x] ? @@hexadecimal_to_decimal[x] : x.to_i  }
    end

    def self.set_hexnumber( i, j, index)
      [
        @digested_password[127 - (i + i**j) % 128],
        @digested_password[127 - (i + 5 + j) % 128]
      ][index]
    end

    def self.set_counter
      i = 0
      @counter = @digested_password[24 + i]
      while @digested_password[23 + i] > 5
        i += 1
        if @digested_password[24 + i] <= 5
          @counter = @digested_password[24 + i]
        elsif i == 100
          @counter = 2
          break
        end
      end 
      @counter2 = @digested_password[ @counter + 20 ] % 4
      @counter3 = @digested_password[ @counter * @counter2 + 9 ] + @digested_password[ @counter + @counter2 + 10 ] + @digested_password[127 - @counter ** @counter2]
    end

    def self.counter(hexnumber1, hexnumber2)
      i,j = 0,0
      if hexnumber1 < 14
        @counter = hexnumber1 % 6
      else
        @counter = (hexnumber1 + hexnumber2) % 6
      end
      @counter3 = @digested_password[hexnumber1 + hexnumber2] % 5 * 10 + @digested_password[33 + hexnumber1 - hexnumber2] % 6
      while (@digested_password[hexnumber1 + hexnumber2 + i] == 15) || (@digested_password[33 + hexnumber1 - hexnumber2 + j] >= 12 )
        if @digested_password[hexnumber1 + hexnumber2 + i] == 15
          i += 1
        elsif @digested_password[33 + hexnumber1 - hexnumber2 + j] >= 12
          j += 1
        elsif i == 90 || j == 90
          @counter3 = @digested_password[hexnumber1 + hexnumber2 + 34] % 5 * 10 + @digested_password[33 + hexnumber1 - hexnumber2 + 41] % 6
        end 
        @counter3 = @digested_password[hexnumber1 + hexnumber2 + i] % 5 * 10 + @digested_password[33 + hexnumber1 - hexnumber2 + j] % 6
      end
    end
  end
end