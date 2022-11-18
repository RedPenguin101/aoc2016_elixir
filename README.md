Day7
----
IPv7
Which support TLS
ABBA: 4char seq, ABBA (A!=B), but NOT in sqbrk

abba[mnop]qrst: yes
abcd[bddb]xyxx: no

ioxxoj[asdfgh]zxcvbn: yes

Divide string into 3 parts: pre-mid-post
Iterate through each string char list, looking for abba pattern.
Result generated {true false false} or something
Match on tf? -> t, ?ft -> t

Actually, not so simple: examples are XYX (where X is non-sqbrk, Y is sqbrk)
But actual input can have 0, 1, 2 or 3 sqbracks
(But no sequence starts or ends with sqbrk)

So this means checking proc will have to be different:

1. Check each sub-seq for ABBA pattern, producing [bool]
2. divide the resulting sequence into two. the Interleaved nature will mean the non-sqbrk will end up in the first output X, the sqbrk into the second output Y
3. if some X and none Y, then valid, else not.
