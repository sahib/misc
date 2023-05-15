| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./fadvise advice_normal   read_seq       ./2G` | 2.489 ± 0.181 | 2.149 | 2.657 | 1.00 |
| `./fadvise advice_seq      read_seq       ./2G` | 2.749 ± 0.198 | 2.450 | 2.933 | 1.10 ± 0.11 |
| `./fadvise advice_random   read_seq       ./2G` | 35.923 ± 1.120 | 35.182 | 38.897 | 14.43 ± 1.14 |
| `./fadvise advice_willneed read_seq       ./2G` | 3.440 ± 0.309 | 2.824 | 3.645 | 1.38 ± 0.16 |
| `./fadvise advice_dontneed read_seq       ./2G` | 3.781 ± 0.361 | 2.929 | 4.288 | 1.52 ± 0.18 |
