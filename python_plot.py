import math
import numpy as np
import matplotlib.pyplot as plt

x = np.arange(-math.pi,math.pi,0.1)

plt.scatter(x, np.sin(x), label='sin(x)',color='blue')
plt.scatter(x, np.cos(x), label='cos(x)',color='red')
plt.xlabel('x')
plt.ylabel('y')
plt.title("Same as R")
plt.legend()
plt.savefig('pretty_python_fig.pdf')
plt.close()