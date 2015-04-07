require_relative '../spec_helper.rb'

let(:uppercase) { ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'] }
let(:lowercase) { ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'] }
let(:numbers) { [0,1,2,3,4,5,6,7,8,9] }


it 'can encrypt with a set of random passwords'
  for i in 0..100
    length = 6 + rand(9)
    (0...length).map { ('a'..'z').to_a[rand(26)] }.join
  end
end
