import argparse
import pandas as pd
import os

# data_directory = "/lustre03/project/6008063/neurohub/UKB/Bulk/90004"

def main():
    parser = argparse.ArgumentParser(description='Process cp values.')
    parser.add_argument("data_directory", help="Location where csv files are stored.")
    parser.add_argument("folder_name", help="Which folder needs to be processed?")
    parser.add_argument("output_location", help="Location to store output dataframe per input folder.")
    args = parser.parse_args()
    
    return args.data_directory, args.folder_name, args.output_location


def get_csv_list(data_directory, process_folder):
    source_files = os.path.join(data_directory, process_folder)
    csv_list = []
    for path, dirnames, filenames in os.walk(source_files):
        for file in filenames:
            if file.endswith(".csv"):
                csv_list.append(os.path.join(path, file))
    print(f"There are {len(csv_list)} files to be processed.")
    return sorted(csv_list)

def process_files(csv_list):
    output = []
    for file_name in csv_list:
        eid = file_name.split("/")[-1].split("_")[0]
        df = pd.read_csv(file_name)
        out_df = funcCP(df, eid)
        output.append(out_df)
        print(f"Processed file {file_name}")
    return pd.concat(output)
    

def funcCP(df, eid):
    # Count of non-missing below 50
    SB = (df.iloc[:,0] <= 50).sum()
    
    # Count of values between 50 and 100
    LPA = ((df.iloc[:,0] > 50) & (df.iloc[:,0] < 100)).sum()
    
    # Count of values greater than or equal to 125
    MVPA = (df.iloc[:,0] >= 125).sum()
    
    # Count of values greater than or equal to 100
    MVPA2 = (df.iloc[:,0] >= 100).sum()
    
    # Count of values greater than or equal to 150
    MVPA3 = (df.iloc[:,0] >= 150).sum()
    
    # Count of values greater than or equal to 400
    VPA = (df.iloc[:,0] >= 400).sum()
    
    # Total number of rows
    total = len(df)
    
    # Count of missing values
    missing = df.iloc[:,0].isna().sum()
    
    # Calculate mean while ignoring NaNs
    meanENMO = df.iloc[:,0].mean()
    
    # Create a DataFrame to store the results
    result = pd.DataFrame({
        'eid': [eid],
        'SB': [SB],
        'LPA': [LPA],
        'MVPA': [MVPA],
        'MVPA2': [MVPA2],
        'MVPA3': [MVPA3],
        'total': [total],
        'missing': [missing],
        'MVPA_total': [MVPA / total], # proportion over total, each observation is 5 sec
        'MVPA2_total': [MVPA2 / total], # proportion over total, each observation is 5 sec
        'MVPA3_total': [MVPA3 / total], # proportion over total, each observation is 5 sec
        'VPA_total': [VPA / total],
        'LPA_total': [LPA / total],
        'SB_total': [SB / total],
        'meanENMO': [meanENMO]
    })
    
    return result

        
if __name__ == "__main__":
## how to run?
## python cp_calculate.py "/lustre03/project/6008063/neurohub/UKB/Bulk/90004" "10"
    data_directory, process_folder, output_location = main()
    csv_list = get_csv_list(data_directory, process_folder)
    output = process_files(csv_list)
    print("Processed all csv files.")
    destination = os.path.join(output_location, process_folder+".csv")
    output.to_csv(destination, index=False)