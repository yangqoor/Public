# -*- coding: utf-8 -*-
"""
Created on Mon Apr 15 09:57:21 2019

Editor:
    Shihao Ran
    STIM Laboratory
"""

#%%
# Calculate the sphere scattering coefficients
def coeff_b(l, k, n, a):
    jka = sp.special.spherical_jn(l, k * a)
    jka_p = sp.special.spherical_jn(l, k * a, derivative=True)
    jkna = sp.special.spherical_jn(l, k * n * a)
    jkna_p = sp.special.spherical_jn(l, k * n * a, derivative=True)

    yka = sp.special.spherical_yn(l, k * a)
    yka_p = sp.special.spherical_yn(l, k * a, derivative=True)

    hka = jka + yka * 1j
    hka_p = jka_p + yka_p * 1j

    bi = jka * jkna_p * n
    ci = jkna * jka_p
    di = jkna * hka_p
    ei = hka * jkna_p * n

    # return ai * (bi - ci) / (di - ei)
    return (bi - ci) / (di - ei)

scatter_line_gt = scatter_matrix[:int(simRes/2), 0, :]

B = coeff_b(l, k, 1.25, 2)
# calculate every order of the integration
Sum_t = scatter_matrix_line * B
# integrate through all the orders to get the farfield in the Fourier Domain
E_scatter_fft_line = np.sum(Sum_t, axis = -1) * scale_factor

#%%
plt.figure()
plt.plot(np.real(E_scatter_fft_line[::-1]), label='Line')
plt.plot(np.real(E_scatter_fft[:, 0]), label='Ground Truth')
plt.legend()


#%%
n = E_t_bandpass[int(simRes/2), int(simRes/2):]
F = E_near_line
F_n = (F-np.mean(F))/np.std(F)
n_n = (n-np.mean(n))/np.std(n)
x = np.linspace(-simFov/2, simFov/2, simRes)[int(simRes/2):]
plt.figure()
#plt.subplot(121)
plt.plot(Ex,np.real(F_n), label='Transformed')
plt.plot(x,np.real(n_n), label='Ground Truth')
plt.ylabel('Intensity')
plt.xlabel('Field of View/um')
plt.legend()
plt.title('Sphere #2, NA_in=0.3, NA_out=0.6')