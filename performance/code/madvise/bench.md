| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `./madvise advice_normal   read_seq       ./big-file` | 191.8 ± 6.5 | 181.3 | 200.8 | 1.00 |
| `./madvise advice_seq      read_seq       ./big-file` | 235.7 ± 9.3 | 228.4 | 259.5 | 1.23 ± 0.06 |
| `./madvise advice_random   read_seq       ./big-file` | 256.1 ± 14.7 | 232.0 | 273.7 | 1.34 ± 0.09 |
| `./madvise advice_willneed read_seq       ./big-file` | 240.5 ± 9.3 | 227.6 | 259.1 | 1.25 ± 0.06 |
| `./madvise advice_dontneed read_seq       ./big-file` | 240.5 ± 11.6 | 227.5 | 262.2 | 1.25 ± 0.07 |
| `./madvise advice_normal   read_random    ./big-file` | 245.5 ± 10.3 | 236.9 | 269.2 | 1.28 ± 0.07 |
| `./madvise advice_seq      read_random    ./big-file` | 246.3 ± 11.1 | 235.3 | 274.3 | 1.28 ± 0.07 |
| `./madvise advice_random   read_random    ./big-file` | 211.6 ± 7.5 | 200.3 | 222.0 | 1.10 ± 0.05 |
| `./madvise advice_willneed read_random    ./big-file` | 216.8 ± 10.9 | 206.6 | 233.0 | 1.13 ± 0.07 |
| `./madvise advice_dontneed read_random    ./big-file` | 217.3 ± 9.8 | 201.8 | 231.6 | 1.13 ± 0.06 |
| `./madvise advice_normal   read_backwards ./big-file` | 216.0 ± 13.4 | 197.2 | 236.4 | 1.13 ± 0.08 |
| `./madvise advice_seq      read_backwards ./big-file` | 203.8 ± 13.9 | 171.4 | 219.9 | 1.06 ± 0.08 |
| `./madvise advice_random   read_backwards ./big-file` | 209.1 ± 12.2 | 184.2 | 225.7 | 1.09 ± 0.07 |
| `./madvise advice_willneed read_backwards ./big-file` | 219.0 ± 14.2 | 202.0 | 240.3 | 1.14 ± 0.08 |
| `./madvise advice_dontneed read_backwards ./big-file` | 212.3 ± 12.8 | 197.9 | 237.2 | 1.11 ± 0.08 |
