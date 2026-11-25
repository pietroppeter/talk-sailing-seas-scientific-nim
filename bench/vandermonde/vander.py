# The Vandermonde matrix with for loops in Python, and with NumPy's np.vander.
# Run by run.sh: `python3 vander.py <case> <m> <n> <calls> <repeat>` times `calls` calls
# of vander on m points with n columns, best of `repeat`, and prints one CSV line per
# implementation: case, implementation, milliseconds, checksum (the sum of the last matrix).
import sys
import timeit
import numpy as np

# >>> vander
def vander(x, n):
    v = [[1.0] * n for _ in x]
    for i in range(len(x)):
        for j in range(1, n):
            v[i][j] = v[i][j-1] * x[i]
    return v
# <<< vander

case = sys.argv[1]
m, n, calls, repeat = map(int, sys.argv[2:6])
x = [0.9 + 0.2 * i / m for i in range(m)]  # in [0.9, 1.1): no overflow, no denormals
xa = np.array(x)

v = vander(x, n)
va = np.vander(xa, n, increasing=True)  # the same matrix: powers 0 .. n-1
assert np.array_equal(np.array(v), va)

def best(f):
    return min(timeit.repeat(f, number=calls, repeat=repeat)) * 1e3

print(f"{case},Python loops,{best(lambda: vander(x, n)):.4f},{sum(map(sum, v)):.6f}")
print(f"{case},NumPy np.vander,{best(lambda: np.vander(xa, n, increasing=True)):.4f},{va.sum():.6f}")
