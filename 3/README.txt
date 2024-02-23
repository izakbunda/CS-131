Performance based on: "/usr/local/cs/jdk-21.0.2/lib/modules" - default

Running gzip... -> ratio: 2.95        
real    0m8.200s        |  real    0m8.240s        |  real    0m7.973s
user    0m7.901s        |  user    0m7.753s        |  user    0m7.836s
sys     0m0.150s        |  sys     0m0.160s        |  sys     0m0.063s

Running pigz... -> ratio: 2.94
real    0m2.307s        |  real    0m2.280s        |  real    0m2.234s
user    0m8.179s        |  user    0m8.186s        |  user    0m8.122s
sys     0m0.136s        |  sys     0m0.132s        |  sys     0m0.126s

Running Java Pigzj... -> ratio: 2.94
real    0m2.858s        |  real    0m2.796s        |  real    0m2.906s
user    0m8.446s        |  user    0m8.411s        |  user    0m8.363s
sys     0m0.472s        |  sys     0m0.425s        |  sys     0m0.567s


Performance based on: "/usr/local/cs/jdk-21.0.2/lib/modules" - 2 processors

Running pigz...
real    0m8.388s        |  real    0m8.154s        |  real    0m8.854s
user    0m8.023s        |  user    0m8.104s        |  user    0m7.648s
sys     0m0.124s        |  sys     0m0.115s        |  sys     0m0.663s

Running pigzj...
real    0m8.812s        |  real    0m10.123s       |  real    0m8.517s
real    0m8.231s        |  user    0m8.301s        |  user    0m8.289s
sys     0m0.206s        |  sys     0m0.224s        |  sys     0m0.198s

Performance based on: "/usr/local/cs/jdk-21.0.2/lib/modules" - 10 processors

Running pigz...
real    0m3.521s        |  real    0m3.587s        |  real    0m3.465s
user    0m8.102s        |  user    0m8.098s        |  user    0m8.106s
sys     0m0.103s        |  sys     0m0.107s        |  sys     0m0.109s

Running pigzj...
real    0m7.963s        |  real    0m8.342s        |  real    0m8.215s
user    0m8.512s        |  user    0m8.531s        |  user    0m8.489s
sys     0m0.402s        |  sys     0m0.387s        |  sys     0m0.413s


Analysis:

1. Default case:
    The result of this is as expected. gzip is runs on a single thread so it makes sense that it is slowest than 
    pigz and pigzj which are both multithreaded. Now comparing pigz and pigzj, my implementation of pigzj is +/- 0.5s 
    faster/slower than pigz which makes sense since they are similarly implemented.

2. Two processors:
    The result of this is expected again. Since pigz and pigzj are implemented in a similar way and are expected to
    act similarly, then it makes sense for them to have the same or similar timed results.

3. Ten processors:
    This is where I'm a little bit confused. I expected pigz and pigzj to still act the same, but the only reason I have is that
    maybe pigz is more optimized in a lower level way that we didn't touch in the implementation of pigzj. When I was looking
    around for how to implement multi-threading, I saw that there were a lot of other libraries and other versions of the
    same methods I was using so maybe that's why it's a lot faster.


Strace test based on: "/usr/local/cs/jdk-21.0.2/lib/modules"

System calls count for gzip:
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.007621           1      4460         2 total

System calls count for pigz:
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.168906          85      1965         7 total

System calls count for Pigzj:
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.503290        2503       201        83 total

Analysis:
    So, looking at the system calls for gzip, pigz, and Pigzj, it's pretty interesting to analyze what's happening. 
    Gzip is making a lot of system calls (4460) which explains why it's lagging behind the others. 
    Pigz cuts down on those calls by more than half due to to its multi-threadedness and it gives us that speed boost
    that gzip is lacking. Then, pigzj has wayyyy fewer calls and a bit of an error spike.  I think this is due to 
    the JVM or Java Virtual Machine and bytecode compilation. I think that the JVM optimizes a lot of system calls
    that pigz has to be very explicit about due to it being written in C++.


Potential Problems:
1. Number of threads scale up:
    I think for this one, it's a mixed bag. I'm not really certain why pigz and pigzj have such different results for
    the trial with 10 processors. I assumed it would be the same since they are implemented the same, but I was wrong. 
2. File size:
    I think that this is definitely a problem with gzip, pigz, and pigzj. When I was testing my code with a really small
    example like "987654321", it would do it really fast and there would be no different. But then, when I tested it on
    "/usr/local/cs/jdk-21.0.2/lib/modules", my code would really slow down. This shows that the larger the file size, the
    more time our code will take. I think what's most important to know and the basis of this assignment is that pigz and
    pigzj are faster than gzip because they are multithreaded.





    