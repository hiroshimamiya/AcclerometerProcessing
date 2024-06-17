#!/bin/sh

# This script is an example to specificaly extract Data-Field 41281: Date of first in-patient diagnosis - ICD9

# Commands to run to use the "xsv" command in Beluga
module load rust
export PATH=~/.cargo/bin:$PATH

# Grep the "41271" UDI
cd /lustre03/project/6008063/neurohub/UKB/Tabular
xsv headers current.csv | grep 41271

# Grep the columns containing eids and  UDI 41271 
xsv select 1,19562-19608 current.csv | grep
