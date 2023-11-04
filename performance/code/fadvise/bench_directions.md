| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./fadvise advice_normal   read_seq       ./2G` | 1.191 ± 0.489 | 0.745 | 2.145 | 1.00 |
| `./fadvise advice_normal   read_random    ./2G` | 4.215 ± 0.691 | 3.761 | 5.919 | 3.54 ± 1.57 |
| `./fadvise advice_normal   read_backwards ./2G` | 12.533 ± 1.658 | 11.207 | 15.937 | 10.53 ± 4.55 |
