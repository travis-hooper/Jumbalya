require_relative '../spec_helper.rb'

describe 'ab' do

  let(:charaters) { [('0'..'9'),('a'..'z'),('A'..'Z')].map(&:to_a).flatten }

  it 'can encrypt with a set of random passwords' do
    for i in 0..100
      length = 6 + rand(9)
      password = ''
      for j in 0..length
        password += charaters[rand(62)]
      end
      message = ''
      for j in 0..400
        message += charaters[rand(62)]
      end
      expect(Jumbalya::AB.unencrypt(Jumbalya::AB.encrypt(message, password), password)).to eq(message)
    end
  end
end
