import scipy.io as sio
import sys

args = sys.argv

mat_file = sio.loadmat(args[1])

print(mat_file.keys())

print(len(mat_file['mask']))
print(mat_file['mask'])

#print(len(mat_file['candidate']))
#print(mat_file['candidate'])
