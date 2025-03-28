#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 12 14:25:43 2024

@author: vincentcalia-bogan
"""

## Functions that generate an overlap dict, as well as all the required dicts we need 
# reading parquets 

# passing arguments that themselves are no longer variables-- as this is best practice to not do that lol

import os, os.path
import polars as pl

def read_parquet_files_into_dict(parquet_path):
    parquet_files = [f for f in os.listdir(parquet_path) if f.endswith('.parquet')]
    dataframes_dict = {}
    for file in parquet_files:
        file_path = os.path.join(parquet_path, file)
        file_name = os.path.splitext(file)[0]  # Remove the file extension
        dataframes_dict[file_name] = pl.read_parquet(file_path)
    return dataframes_dict

def all_nrns_to_df(all_parquet_path):
    parquet_files = [f for f in os.listdir(all_parquet_path) if f.endswith('.parquet')]
    all_dataframes = []
    for parquet_file in parquet_files:
        file_path = os.path.join(all_parquet_path, parquet_file)
        df = pl.read_parquet(file_path)
        all_dataframes.append(df)
    if all_dataframes:
        all_nrns_df = pl.concat(all_dataframes, rechunk=True)
        return all_nrns_df
    else:
        return pl.DataFrame()