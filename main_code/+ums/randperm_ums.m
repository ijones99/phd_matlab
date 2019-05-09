function y = randperm(n)
  % Return a random permutation of the integers 1 to N.
  %
  % Example:
  % randperm(5)'
  % ans = 1 4 5 3 2
  [ordered_nums, y] = sort(rand(n,1));
end