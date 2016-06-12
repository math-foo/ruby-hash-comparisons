# ruby-hash-comparisons
TL;DR: Quick and dirty performance comparisons of various hashing methods in Ruby

I needed to make **non-cryptographic** hashes of a family of strings. I wanted something fast, with a low chance of collisions; but didn't need cryptographic strength.

I wrote this script to compare performance across different available algorithms, mostly focusing on the murmur family of hashing methods.
