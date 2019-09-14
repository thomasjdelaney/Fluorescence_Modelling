# For testing how the ode solver works

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import ode

def f(t, u):
    return [u[1], 3.*(1. - u[0]*u[0])*u[1] - u[0]]

r = ode(f).set_integrator('vode', method='adams', order=10, rtol=0, atol=1e-6, with_jacobian=False)
u0 = [2.0, 0.0]
r.set_initial_value(u0, 0)
T = 30
dt = T/150.

u = np.array([])
t = np.array([])

while r.successful() and r.t <= T:
    r.integrate(r.t + dt)
    u = np.append(u, [r.y])
    t = np.append(t, [r.t])

u = u.reshape(151, 2)

plt.figure(1)
ax = plt.plot(t, u[:, 0], 'b')
ax = plt.plot(t, u[:, 1], 'orange')
plt.show()
