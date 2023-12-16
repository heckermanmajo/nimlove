
# nimlang

var myseq = @[1,2,3,4,5,6,7,8,9,10];

proc push(myseq: var seq[int], value: int) =
  myseq.add(value)

proc pop(myseq: var seq[int]) =
    myseq.del(myseq.len - 1)