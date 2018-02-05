#!/usr/bin/env python2
import sys
# replace . with chr_pos encoding

if len(sys.argv[1:]) != 2:
    print('Sorry I need a infile and outfile')
    sys.exit(1)

outfile = open(sys.argv[2], 'w')

with open(sys.argv[1]) as f:
    for line in f:
        bits = line.split('\t')
        try:
            # this checks for scaffold_1 type problems, should be a num
            assert int(bits[0])
            if bits[1] == '.':
                new_name = 'chr%s_%s' % (bits[0], bits[-1].strip())
                bits[1] = new_name
            outfile.write('\t'.join(bits))
        except AssertionError:
            print("Found chromosome/scaffold names in vcf!")
            print("Please ensure they only contain numbers ")
            print("so please fix the file re-run load_data")
            sys.exit(1)

outfile.close()
