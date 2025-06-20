import argparse
import numpy as np

def init_argparse():
    # Configure all the arguments
    parser = argparse.ArgumentParser()

    parser.add_argument('index') # index of the output file

    ## Optional arguments
    parser.add_argument('-k', '--k_width', type=int, required=False, default=8) 
    parser.add_argument('-c', '--total_cycles', type=int, required=False, default = 24)
    
    return parser

if __name__=='__main__':
    parser = init_argparse()
    args = parser.parse_args()
    rng = np.random.default_rng()

    k = rng.integers(-8, 8, size=(8, args.k_width))

    with open('./Random inputs/kmem_'+args.index+'.txt', 'w') as f:
        for i in range(8):
            f.write(''.join([str(x)+'\t' for x in k[i]])+'\n')

    n = rng.integers(0, 256, size=(8, args.k_width//2))

    with open('./Random inputs/ndata_'+args.index+'.txt', 'w') as f:
        for i in range(8):
            f.write(''.join([str(x)+'\t' for x in n[i]])+'\n')

    q = rng.integers(-8, 8, size=(args.total_cycles, 8))

    with open('./Random inputs/qmem_'+args.index+'.txt', 'w') as f:
        for i in range(args.total_cycles):
            f.write(''.join([str(x)+'\t' for x in q[i]])+'\n')

    o = np.matmul(q, k)

    with open('./Random inputs/out_'+args.index+'.txt', 'w') as f:
        for i in range(args.total_cycles):
            f.write(''.join([str(x)+'\t' for x in o[i]])+'\n')

