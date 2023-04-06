# %%
import numpy as np
import pandas as pd
import subprocess
import glob
from pathlib import Path
import json 
import math
import sys  
# %%

if len(sys.argv) < 2:
    print("Usage: python profile_predicates.py <results_directory>")
    sys.exit(0)

root_path = Path(sys.argv[1])
#%%
# root_path = Path("../../performance_tests/")


# We only process the LATEST run for a given release x suite x platform. To support this function
# we loop over all of the possible CSV files and add a file to the "load" list
# only if it has a newer `testedOn` value.
datafiles = {}


def path_to_tuple(path):
    parts = path.parts

    part_suite = parts[-1]
    part_language = parts[-2]
    part_platform = parts[-3]
    part_release = parts[-4]

    release = part_release.split(",")[0].split("=")[1]
    testedOn = part_release.split(",")[1].split("=")[1]
    platform = part_platform.split("=")[1]
    language = part_language.split("=")[1]
    suite = part_suite.split(".")[0].split("=")[1].split(",")[0]

    return release, testedOn, platform, language, suite
#%%

for f in root_path.glob(f"release*/**/*datum=evaluator-log.json"):
    release, testedOn, platform, language, suite = path_to_tuple(f)

    hashEntry = {
        "release": release,
        "testedOn": testedOn,
        "platform": platform,
        "language": language,
        "suite": suite,
        "dataFile": f
    }

    if not release in datafiles.keys():
        datafiles[(release, platform, suite, language)] = hashEntry
    else:
        existing = datafiles[(release, platform, suite, language)]

        if existing["testedOn"] > testedOn:
            datafiles[(release, platform, suite, language)] = hashEntry
# %%
summary_df = pd.DataFrame(columns=[
    'Release',
    'Run',
    'Platform',
    'Language',
    'Suite',
    'Predicate',
    'Execution_Time_Ms'
])


new_rows = {
    'Release': [],
    'Run': [],
    'Platform': [],
    'Language': [],
    'Suite': [],
    'Predicate': [],
    'Execution_Time_Ms': []
}

for K, V in datafiles.items():
    print(f"Loading {str(V['dataFile'])}...", end=None)
    
    # we need to load the data file and then parse each JSON row 
    with open(V['dataFile'], 'r') as f:
        json_line_data = f.read() 
        #json_line_objects = re.split(r"(?m)^\n", json_line_data)
        json_line_objects = json_line_data.split('\n\n')
    

    print(f"Done.")

    for json_line_object in json_line_objects:
        
        #print(".", end="None")

        # quickly do this before bothering to parse the JSON
        if not ("predicateName" in json_line_object and "COMPUTE_SIMPLE" in json_line_object):
            continue 

        json_object = json.loads(json_line_object)

        if not "predicateName" in json_object:
            continue 

        if json_object["predicateName"] == "output":
            continue 


        if not json_object["evaluationStrategy"] == "COMPUTE_SIMPLE":
            continue 

        new_rows['Release'].append(V["release"])
        new_rows['Run'].append(V["testedOn"])
        new_rows['Platform'].append(V["platform"])
        new_rows['Language'].append(V["language"])
        new_rows['Suite'].append(V["suite"])
        new_rows['Predicate'].append(json_object["predicateName"])
        new_rows['Execution_Time_Ms'].append(json_object["millis"])

new_df = pd.DataFrame(new_rows)
summary_df = pd.concat([summary_df, new_df])

# %%
# %%
performance_df = pd.DataFrame(
    columns=[
        'Release',
        'Platform',
        'Language',
        'Total_Serialized_Execution_Time_Ms',
        'Mean_Predicate_Execution_Time_Ms',
        'Median_Predicate_Execution_Time_Ms',
        'Standard_Deviation_Ms',
        'Total_Serialized_Execution_Time_s',
        'Mean_Query_Execution_Time_s',
        'Median_Predicate_Execution_Time_s',
        'Percentile95_Ms',
        'Number_of_Predicates'
    ]
)

summary_df_grouped = summary_df.groupby(['Release', 'Platform', 'Language'])

for _, df_group in summary_df_grouped:

    release = df_group["Release"].iloc[0]
    platform = df_group["Platform"].iloc[0]
    language = df_group["Language"].iloc[0]

    print(f"Processing Platform={platform}, Language={language}, Release={release}")
    
    
    execution_time = df_group["Execution_Time_Ms"].sum()
    execution_time_mean = df_group["Execution_Time_Ms"].mean()
    execution_time_median = df_group["Execution_Time_Ms"].median()
    execution_time_std = df_group["Execution_Time_Ms"].std()
    percentile_95 = df_group["Execution_Time_Ms"].quantile(.95)
    num_queries = len(df_group)

    row_df = pd.DataFrame({
        'Release' : [release],
        'Platform' : [platform],
        'Language' : [language],
        'Total_Serialized_Execution_Time_Ms' : [execution_time],
        'Mean_Predicate_Execution_Time_Ms' : [execution_time_mean],
        'Median_Predicate_Execution_Time_Ms' : [execution_time_median],
        'Standard_Deviation_Ms' : [execution_time_std],
        'Total_Serialized_Execution_Time_s' : [execution_time/1000],
        'Mean_Query_Execution_Time_s' : [execution_time_mean/1000],
        'Median_Predicate_Execution_Time_s' : [execution_time_median/1000],
        'Percentile95_Ms' : [percentile_95],        
        'Number_of_Predicates' : [num_queries]
    })

    performance_df = pd.concat([performance_df, row_df])

#%%
# write out the high level performance summary
performance_df.to_csv(root_path.joinpath('performance-history,datum=predicate.csv'), index=False)
#%%
# write out all queries for every suite that are greater than the 95th
# percentile 
for _, row in performance_df.iterrows():


    release = row["Release"]
    platform = row["Platform"]
    language = row["Language"]
    percentile_95 = row["Percentile95_Ms"]

    rpl_df = summary_df[(summary_df["Release"] == release) & (summary_df["Platform"] == platform) & (summary_df["Language"] == language)]
    g95 = rpl_df[(rpl_df["Execution_Time_Ms"] >= percentile_95)]

    g95 = g95.sort_values(by='Execution_Time_Ms', ascending=False)

    g95.to_csv(root_path.joinpath(f"slow-log,datum=predicates,release={release},platform={platform},language={language}.csv"), index=False)


