| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `./madvise advice_normal   read_seq       ./big-file` | 228.8 ± 30.5 | 206.8 | 291.1 | 1.06 ± 0.15 |
| `./madvise advice_seq      read_seq       ./big-file` | 215.7 ± 8.6 | 205.8 | 233.5 | 1.00 |
| `./madvise advice_random   read_seq       ./big-file` | 229.8 ± 9.9 | 214.9 | 243.0 | 1.07 ± 0.06 |
| `./madvise advice_willneed read_seq       ./big-file` | 251.8 ± 47.8 | 201.4 | 336.7 | 1.17 ± 0.23 |
| `./madvise advice_dontneed read_seq       ./big-file` | 217.0 ± 10.3 | 206.0 | 234.0 | 1.01 ± 0.06 |
| `./madvise advice_normal   read_random    ./big-file` | 224.0 ± 13.7 | 210.0 | 253.8 | 1.04 ± 0.08 |
| `./madvise advice_seq      read_random    ./big-file` | 239.4 ± 18.8 | 205.5 | 277.0 | 1.11 ± 0.10 |
| `./madvise advice_random   read_random    ./big-file` | 232.2 ± 21.8 | 211.9 | 285.7 | 1.08 ± 0.11 |
| `./madvise advice_willneed read_random    ./big-file` | 253.8 ± 56.8 | 209.7 | 377.1 | 1.18 ± 0.27 |
| `./madvise advice_dontneed read_random    ./big-file` | 221.2 ± 13.6 | 205.1 | 243.9 | 1.03 ± 0.08 |
| `./madvise advice_normal   read_backwards ./big-file` | 237.0 ± 48.5 | 199.3 | 332.5 | 1.10 ± 0.23 |
| `./madvise advice_seq      read_backwards ./big-file` | 218.8 ± 11.9 | 200.5 | 239.1 | 1.01 ± 0.07 |
