import numpy as np
import matplotlib.pyplot as plt

plot_both_loss = True

num_img = 14
filter_type = 'gaus_filter'
noise_lvl = 4
noise_type = filter_type + '_' + str(noise_lvl)
#add_det = '_tv' #add more details regarding the run
#add_det = ''

### bp
loss_type1 = 'bp'  # bp/dip/mixed
num_iter1 = 2000
add_det = ''
directory1 = './results/deblur_with_ssim_bm3d/' + noise_type + '_' + loss_type1 + add_det + '/'
f = open(directory1 + 'psnr_history_%s.txt' % loss_type1, 'r')
x = f.readlines()
psnr_per_iter1 = np.zeros(int(num_iter1 / 100))
for i in range(len(x)):
    if (i*100 % 7000) < num_iter1:
        single_psnr1 = float(x[i].replace('[', '').replace(']', ''))
        j = i % (int(7000 / 100))
        psnr_per_iter1[j] += single_psnr1
psnr_per_iter1 = psnr_per_iter1 / num_img
max_iter1 = np.argmax(psnr_per_iter1)

### dip
loss_type2 = 'dip'  # bp/dip/mixed
num_iter2 = 10000
add_det = ''
directory2 = './results/deblur_with_ssim_bm3d/' + noise_type + '_' + loss_type2 + add_det + '/'
f = open(directory2 + 'psnr_history_%s.txt' % loss_type2, 'r')
x = f.readlines()
psnr_per_iter2 = np.zeros(int(num_iter2 / 100))
for i in range(len(x)):
    single_psnr2 = float(x[i].replace('[', '').replace(']', ''))
    j = i % (int(num_iter2 / 100))
    psnr_per_iter2[j] += single_psnr2
psnr_per_iter2 = psnr_per_iter2 / num_img
max_iter2 = np.argmax(psnr_per_iter2)

### bp-tv
loss_type3 = 'bp'  # bp/dip/mixed
num_iter3 = 7000
add_det = '_tv'
directory3 = './results/deblur_with_ssim_bm3d/' + noise_type + '_' + loss_type1 + add_det + '/'
f = open(directory3 + 'psnr_history_%s.txt' % loss_type3, 'r')
x = f.readlines()
psnr_per_iter3 = np.zeros(int(num_iter3 / 100))
for i in range(len(x)):
    if (i*100 % 7000) < num_iter3:
        single_psnr3 = float(x[i].replace('[', '').replace(']', ''))
        j = i % (int(7000 / 100))
        psnr_per_iter3[j] += single_psnr3
psnr_per_iter3 = psnr_per_iter3 / num_img
max_iter3 = np.argmax(psnr_per_iter3)

### dip-tv
loss_type4 = 'dip'  # bp/dip/mixed
num_iter4 = 10000
add_det = '_tv'
directory4 = './results/deblur_with_ssim_bm3d/' + noise_type + '_' + loss_type4 + add_det + '/'
f = open(directory4 + 'psnr_history_%s.txt' % loss_type4, 'r')
x = f.readlines()
psnr_per_iter4 = np.zeros(int(num_iter4 / 100))
for i in range(len(x)):
    single_psnr4 = float(x[i].replace('[', '').replace(']', ''))
    j = i % (int(num_iter4 / 100))
    psnr_per_iter4[j] += single_psnr4
psnr_per_iter4 = psnr_per_iter4 / num_img
max_iter4 = np.argmax(psnr_per_iter4)

### plot
fig = plt.figure()
ax = fig.add_subplot(111)

if noise_lvl == 0.3:
    plt.plot(np.arange(0, num_iter1, 100), psnr_per_iter1, '-b', label = (r"$\bf{" + 'BP (%0.2f dB)' + "}$") % psnr_per_iter1.max())
    plt.plot(np.arange(0, num_iter2, 100), psnr_per_iter2, '-r', label= 'LS (%0.2f dB)' % psnr_per_iter2.max())
    plt.plot(np.arange(0, num_iter3, 100), psnr_per_iter3, '-g', label = 'BP-TV (%0.2f dB)' % psnr_per_iter3.max())
    plt.plot(np.arange(0, num_iter4, 100), psnr_per_iter4, '-m', label= 'LS-TV (%0.2f dB)' % psnr_per_iter4.max())
else:
    plt.plot(np.arange(0, num_iter1, 100), psnr_per_iter1, '-b', label='BP (%0.2f dB)' % psnr_per_iter1.max())
    plt.plot(np.arange(0, num_iter2, 100), psnr_per_iter2, '-r', label='LS (%0.2f dB)' % psnr_per_iter2.max())
    plt.plot(np.arange(0, num_iter3, 100), psnr_per_iter3, '-g', label=(r"$\bf{" + 'BP-TV (%0.2f dB)' + "}$") % psnr_per_iter3.max())
    plt.plot(np.arange(0, num_iter4, 100), psnr_per_iter4, '-m', label='LS-TV (%0.2f dB)' % psnr_per_iter4.max())


plt.ylim(bottom=16)
plt.xlim(right=10000)
#ax.set_aspect(250)
plt.xlabel('Iteration number')
plt.ylabel('PSNR [dB]')
plt.legend(loc="lower right")
save_dict = './final_results/'
fig.set_size_inches(5,3)
plt.savefig(save_dict + '/%s_%.0f_1106.png' % (filter_type, noise_lvl), bbox_inches='tight')

f.close()

