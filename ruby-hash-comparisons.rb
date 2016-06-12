require 'benchmark'
require 'digest'
require 'digest/murmurhash'
require 'base64'

class RubyHashComparisons
  def initialize(source, hash, repeat)
    @source = source
    @hash = hash
    @repeat = repeat
  end

  def test_hash
    seen = {}
    collisions = 0
    entries = (0...@repeat).collect{ @source.next } 
    results = Benchmark.measure {
      entries.each do |x|
        y = @hash.func.call(x)
        if !seen[y].nil? && x != seen[y]
          collisions += 1
        else
         seen[y] = x
        end
      end
    }
    puts "#{@hash.name} hashing #{@source.name}: #{collisions} collisions"
    puts results
  end
end

# Setting up hash methods to compare

class NamedHash
  attr_reader :name, :func
  
  def initialize(name, hash_func)
    @name = name
    @func = hash_func
  end
end

sha_256_hash_func = lambda { |x| Digest::SHA256.base64digest(x) }
sha_256_hash = NamedHash.new('SHA 256 hash', sha_256_hash_func)

md5_hash_func = lambda { |x| Digest::MD5.base64digest(x) }
md5_hash = NamedHash.new('MD5 hash', md5_hash_func)

murmur1_hash_func = lambda { |x| Digest::MurmurHash1.base64digest(x) }
murmur1_hash = NamedHash.new('Murmur1 hash', murmur1_hash_func)

murmur2_hash_func = lambda { |x| Digest::MurmurHash2.base64digest(x) }
murmur2_hash = NamedHash.new('Murmur2 hash', murmur2_hash_func)

murmur2A_hash_func = lambda { |x| Digest::MurmurHash2A.base64digest(x) }
murmur2A_hash = NamedHash.new('Murmur2A hash', murmur2A_hash_func)

murmur64A_hash_func = lambda { |x| Digest::MurmurHash64A.base64digest(x) }
murmur64A_hash = NamedHash.new('Murmur64A hash', murmur64A_hash_func)

murmur64B_hash_func = lambda { |x| Digest::MurmurHash64B.base64digest(x) }
murmur64B_hash = NamedHash.new('Murmur64B hash', murmur64B_hash_func)

murmur3_32_hash_func = lambda { |x| Digest::MurmurHash3_x86_32.base64digest(x) }
murmur3_32_hash = NamedHash.new('Murmur3 32 bit hash', murmur3_32_hash_func)

murmur3_128_hash_func = lambda { |x| Digest::MurmurHash3_x86_128.base64digest(x) }
murmur3_128_hash = NamedHash.new('Murmur3 128 bit (32 bit platform) hash', murmur3_128_hash_func)

murmur3_128_64_hash_func = lambda { |x| Digest::MurmurHash3_x64_128.base64digest(x) }
murmur3_128_64_hash = NamedHash.new('Murmur3 128 bit (64 bit platform) hash', murmur3_128_64_hash_func)

builtin_murmur_hash_func = lambda { |x| Base64.encode64(x.hash.to_s).strip }
builtin_murmur_hash = NamedHash.new('Builtin Murmur hash', builtin_murmur_hash_func)


hashes_to_test = [sha_256_hash,
                  md5_hash, murmur1_hash,
                  murmur2_hash,
                  murmur2A_hash,
                  murmur64A_hash,
                  murmur64B_hash,
                  murmur3_32_hash,
                  murmur3_128_hash,
                  murmur3_128_64_hash,
                  builtin_murmur_hash]

# Setting up sources of data to compare
class ZipCodes
  attr_reader :name

  def initialize
    @name = '5-digit zip codes'
  end

  def next
    chars = '0123456789'
    phone_number = ''
    10.times { phone_number << chars[rand(chars.size)] }
    phone_number
  end
end

class EnglishWords
  attr_reader :name

  def initialize
    @name = 'Common English Words'
    @words = File.foreach('wordlist.10000.txt').map{|entry| entry}
    @index = -1
  end

  def next
    @index += 1
    if @index >= 10000
      @index %= 10000
    end
    return @words[@index]
  end
end

class FakeUUIDs
  attr_reader :name

  def initialize
    @name = 'FakeUUIDS'
  end

  def next
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ0123456789=+_'
    uuid = ''
    44.times { uuid << chars[rand(chars.size)] }
    uuid
  end
end

sources = [ZipCodes.new, EnglishWords.new, FakeUUIDs.new]

hashes_to_test.each do |hash|
  sources.each do |source|
    hash_comp = RubyHashComparisons.new(source, hash, 10000)
    hash_comp.test_hash
  end
end
