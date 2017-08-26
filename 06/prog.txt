#!/usr/bin/python
# hackparser.py 

import argparse
import re, string
__author__ = 'carpajr'

# ---------------------------------
# ARGUMENTS FOR LOAD HACK ASSEMBLY
# ---------------------------------

parser = argparse.ArgumentParser(description='HACK assembly converter to machine code.')
parser.add_argument('-i', '--input', help='Assembly input file', type=argparse.FileType('r'), required=True)
parser.add_argument('-o', '--output', help='Machine code output file', type=argparse.FileType('w'), required=False)
args = parser.parse_args()

# Debug
#print ("Input file:  %s" % args.input)
#print ("Output file: %s" % args.output)

# ---------------------------------
# Variables base address
# ---------------------------------
varAddressBase = 16

# ---------------------------------
# STANDARD SYMBOL TABLE FOR HACK
# ---------------------------------
symTable = {
	'R0'    : 0,
	'R1'    : 1,
	'R2'    : 2,
	'R3'    : 3,
	'R4'    : 4,
	'R5'    : 5,
	'R6'    : 6,
	'R7'    : 7,
	'R8'    : 8,
	'R9'    : 9,
	'R10'   : 10,
	'R11'   : 11,
	'R12'   : 12,
	'R13'   : 13,
	'R14'   : 14,
	'R15'   : 15,
	'R16'   : 16,
	'SCREEN': 16384,
	'KBD'   : 24576,
	'SP'    : 0,
	'LCL'   : 1,
	'ARG'   : 2,
	'THIS'  :3,
	'THAT'  :4
	}	

# ---------------------------------
# For C-Type Instruction
# Format:
# 111a c1c2c3c4 c5c6d1d2 d3j1j2j3
# ---------------------------------

# ---------------------------------
# DESTINATION TABLE
# ---------------------------------
destTable = { # d1 d2 d3
	'0'     : '000',
	'M'     : '001',
	'D'     : '010',
	'MD'    : '011',
	'A'     : '100',
	'AM'    : '101',
	'AD'    : '110',
	'AMD'   : '111'
	}

# ---------------------------------
# OPERATIONS TABLE
# ---------------------------------
compTable = { # a c1 c2 c3 c4 c5 c6
	'0' 	: '0101010',
	'1'	    : '0111111',
	'-1'	: '0111010',
	'D'	    : '0001100',
	'A'	    : '0110000',
	'M'	    : '1110000',
	'!D'	: '0001101',
	'!A'    : '0110001',
	'!M'    : '1110001',
	'-D'    : '0001111',
	'-A'	: '0110011',
	"-M"	: '1110011',
	'D+1'	: '0011111',
	'A+1'	: '0110111',
	'M+1'	: '1110111',
	'D-1'	: '0001110',
	'A-1'	: '0110010',
	'M-1'	: '1110010',
	'D+A'	: '0000010',
	'D+M'	: '1000010',
	'D-A'	: '0010011',
	'D-M'	: '1010011',
	'A-D'	: '0000111',
	'M-D'	: '1000111',
	'D&A'	: '0000000',
	'D&M'	: '1000000',
	'D|A'	: '0010101',
	'D|M'	: '1010101'
	}
# ---------------------------------
# JUMP TABLE
# ---------------------------------
jmpTable = {  # j1 j2 j3
		'null' : '000',
		'JGT'  : '001',
		'JEQ'  : '010',
		'JGE'  : '011',
		'JLT'  : '100',
		'JNE'  : '101',
		'JLE'  : '110',
		'JMP'  : '111'
	}

input_algorithm = args.input.readlines()
undesired_chars = '()@'

i = 0
code = {} # dict

# FIRST PASS: add the label symbols to symTable
# ---------------------------------------------
for line in input_algorithm:
	line = re.sub(r"\/\/.*?\n", "", line)       # remove comments
	line = line.strip()                         # remove /n

	pattern = re.compile(r'\(.+\)')             # A-Za-z0-9
	if pattern.search(line):
		line = line.translate(string.maketrans("", "", ), undesired_chars)
		#print ("LABEL SYMBOL: %s - Position: %d" % (tmp_line,i))
		symTable[line] = i
		#i = i + 1
		# build first filtered data
	elif line != "":                            # remove blank lines
		code[i] = {'pos': i, 'mnemonic': line, 'instruction': -1}
		i = i + 1


# SECOND PASS: add var symbols to symTable
# ---------------------------------------------
for k,v in code.items():
	pattern = re.compile(r'\@.+')               #print (k,v) #print v.get('mnemonic')
	line = v.get('mnemonic')
	
	if pattern.search(line):
		line = line.translate(string.maketrans("", "", ), undesired_chars)
		#print ("VAR SYMBOL: %s - Position: %d" % (line,k))
		if not line in symTable and line.isdigit() is False:
			#print ("Adding not existing var symbol in symTable...")
			symTable[line] = varAddressBase
			varAddressBase = varAddressBase + 1

#pretty(code)

# THIRD PASS: identify type of instruction and do apropriated action
# ---------------------------------------------

for k,v in code.items():
	patternAType = re.compile(r'\@.+')                          # A-Type
	patternCType = re.compile(r'.+(;|=){1}.+')                  # C-Type
	instrCOpt = '0'                                          # C-Type Option
	instrCDst = '0'                                             # C-Type Destination
	instrCJmp = 'null'                                          # C-Type Jump type

	if patternAType.search(v.get('mnemonic')):
		#print ('A-TYPE %s' % v.get('mnemonic'))
		instruction = v.get('mnemonic').translate(string.maketrans("", "", ), undesired_chars)
		if instruction.isdigit() is True:
			convInst = format(int(instruction), '#017b') # 017b = 15bits + 2 for '0b'
			code[k]['instruction'] = convInst.replace('0b','0');
		else:
			convInst = format(int(symTable[instruction]),'#017b') # str(bin(int(symTable[instruction])))
			code[k]['instruction'] = convInst.replace('0b', '0');

	elif patternCType.search(v.get('mnemonic')):
		#print("C-TYPE %s" % v.get('mnemonic'))
		posEqual = v.get('mnemonic').find('=')
		posSemic = v.get('mnemonic').find(';')
		if posEqual != -1: # AM=M+1
			instrCOpt = v.get('mnemonic')[posEqual+1:]
			instrCDst = v.get('mnemonic')[:posEqual]
			print v.get('mnemonic')

			code[k]['instruction'] = '111' + compTable[instrCOpt] + destTable[instrCDst] + jmpTable[instrCJmp]
		elif posSemic != -1: # D; JGT
			instrCJmp = v.get('mnemonic')[posSemic+1:]
			instrCOpt = v.get('mnemonic')[:posSemic]
			code[k]['instruction'] = '111' + compTable[instrCOpt] + destTable[instrCDst] + jmpTable[instrCJmp]

		print("Decoding %s: dest %s | operation %s | jump %s" % (v.get('mnemonic'),instrCDst, instrCOpt, instrCJmp))
		print("Decoding %s: dest %s | operation %s | jump %s" % (v.get('mnemonic'), destTable[instrCDst], compTable[instrCOpt], jmpTable[instrCJmp]))


# PROCESSED FILE GENERATION
# ---------------------------------------------
try:
	outputFileName = args.output.name
except:
	outputFileName = args.input.name + ".processed"

with open(outputFileName, "w") as outputFile:
	for k,v in code.items():
		outputFile.write(v.get('instruction') + '\n')
	print("HACK ASSEMBLY HAS BEEN PROCESSED SUCCESSFULLY.")
	print("Generated file: %s" % outputFileName)


# Just to print dict pretty -
def pretty(d, indent=0): # https://stackoverflow.com/questions/3229419/pretty-printing-nested-dictionaries-in-python
   for key, value in d.iteritems():
	  print '\t' * indent + str(key)
	  if isinstance(value, dict):
		 pretty(value, indent+1)
	  else:
		 print '\t' * (indent+1) + str(value)

#print "Symbol table"
#print symTable
#print pretty(code)


