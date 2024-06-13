import os
import pandas as pd
import csv
import numpy as np
import time

from datetime import datetime
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

log_path = "/home/aayush/accelerometer/accprocess/results/confusion_matrix_output/logs"
predicted_data_path = "/home/aayush/accelerometer/accprocess/results"
# predicted_data_path = "/home/aayush/accelerometer/accprocess/test"
annotated_data_path = "/home/yacine/accel/capture24/participants/"
# annotated_data_path = "/home/aayush/accelerometer/accprocess/test"

labels_dict_location = "/home/aayush/accelerometer/accprocess/anno-label.csv"
confusion_matrix_location = "/home/aayush/accelerometer/accprocess/results/confusion_matrix_output"

class logger:
    def __init__(self) -> None:
        timestamp = datetime.now().strftime("%m-%d-%Y-%H-%M-%S")
        log = f"{log_path}/Process_data_{timestamp}.log"
        with open(log, "w") as log_file_save:
            log_file_save.write("################################################\n")
            log_file_save.write("|Timestamp| + \t + |Func| + \t + |Message|\n")
        self.log_file = log
    
    def log(self, func, message) -> None:
        with open(self.log_file, "a") as log_file_save:
            timestamp = datetime.now().strftime("%m-%d-%Y-%H-%M-%S")
            log_message = timestamp + "\t" + func + "\t" + message
            log_file_save.write(log_message + "\n")

logging = logger()

def get_files(data_path, predicted_files=False, annotated_files=False) -> None:
    total_csv_zipped = []
    for path, dirnames, filenames in os.walk(data_path):
        logging.log("get_files", f"Looking for data files in {path}.")
        for file in filenames:
            if file.endswith(".csv.gz") and predicted_files:
                # paths contains the base directory for that file.
                # dirnames contains other directories within this folder.
                # filenames contains the list of filenames within path.
                total_csv_zipped.append(os.path.join(path, file))
                logging.log("get_files", f"Found FILE:{file} in PATH:{path}.")
                
            if file.endswith(".csv") and annotated_files and file[0]!='c': #ignore the capture24 file
                # paths contains the base directory for that file.
                # dirnames contains other directories within this folder.
                # filenames contains the list of filenames within path.
                total_csv_zipped.append(os.path.join(path, file))
                logging.log("get_files", f"Found FILE:{file} in PATH:{path}.")
    logging.log("get_files", "#################################################################################")
    logging.log("get_files", f"######### Total files in the data path: {len(total_csv_zipped)} #########")
    logging.log("get_files", "#################################################################################")
    return sorted(total_csv_zipped)


def decode_activities(data_file):
    logging.log("decode_activities", f"Decode the activities from file: {data_file}.")
    df = pd.read_csv(data_file)
    
    # retrieve only the activities headers
    cp_cols = df.columns.values.tolist()[6:8]
    cp_cols.append(df.columns.values.tolist()[10])
    activities = df[cp_cols]
    
    # whichever activity is depicted by 1, use it as the predicted activity
    out = activities[activities==1].idxmax(axis=1)
    df["activity_predicted"] = out
    
    logging.log("decode_activities", f"Dropped 'nan' activity_predicted from file: {data_file}.")
    df_cleaned = df.dropna(subset=["activity_predicted"])
    return df_cleaned
    
    
def create_labels_dict():
    logging.log("create_labels_dict", "Created labels dict for mapping.")
    labels_dict = {}
    with open(labels_dict_location, "r") as annotation_dict:
        reader = csv.DictReader(annotation_dict)
        for row in reader:
            if labels_dict.get(row['annotation']) is None:
                labels_dict[row['annotation']] = [row['label:Walmsley2020']]
            else:
                labels_dict[row['annotation']].append(row['label:Walmsley2020'])
    
    # We do not have sleeping counterpart in cp values.
    labels_dict['7030 sleeping;MET 0.95'] = [pd.NA]
    
    cp_labels_dict = {'CpSB': ["sedentary"], 'CpLPA': ["light"], 'CpMVPA': ["moderate-vigorous"]}
    return labels_dict, cp_labels_dict


def parse_datetime(dt_string):
    clean_datetime_str = dt_string.split('[')[0].strip()
    dt_object = pd.to_datetime(clean_datetime_str)
    return dt_object


def parse_datetime_df_time(dt_string):
    clean_datetime_str = dt_string.split('[')[0].strip()
    clean_datetime_str = clean_datetime_str.split('+')[0].strip()
    dt_object = pd.to_datetime(clean_datetime_str)
    return dt_object


def process_annotated_data(annotated_data_file):
    logging.log("process_annotated_data", f"Process annotated data file: {annotated_data_file}.")
    
    annotated_data = pd.read_csv(annotated_data_file)
    # Take the timestamp after every thirty seconds
    actual_labels = annotated_data[["annotation", "time"]][0::3000]
    
    # Convert to datetime object
    actual_time = actual_labels["time"].apply(parse_datetime)
    actual_labels["time"] = actual_time
    
    return actual_labels
    
def filtering_data(df_cleaned, actual_labels, labels_dict, cp_labels_dict):
    
    # Convert to datetime object
    df_cleaned_time = df_cleaned['time'].apply(parse_datetime_df_time)
    df_cleaned['time_cleaned'] = df_cleaned_time
    
    # Filter out all those timestamps which do not exist in df_cleaned_time
    actual_labels = actual_labels[actual_labels["time"].isin(df_cleaned_time)]
    
    # replace the annotated labels with the same format of strings as predicted labels using mapping from labels_dict
    flat_dict = {k: v[0] for k, v in labels_dict.items()}
    actual_labels['annotation'].replace(flat_dict, inplace=True)
    
    # drop all 'nan' rows from actual labels    
    actual_labels_cleaned = actual_labels.dropna(subset=['annotation'])
    
    # remove timestamps from predicted data for all those rows for which we do not have actual predictions
    df_cleaned_filtered = df_cleaned[df_cleaned['time_cleaned'].isin(actual_labels_cleaned["time"])]
    
    # replace the cp values with string labels which can be compared to actual labels
    flat_dict = {k: v[0] for k, v in cp_labels_dict.items()}
    df_cleaned_filtered['activity_predicted'].replace(flat_dict, inplace=True)
    
    return actual_labels_cleaned, df_cleaned_filtered


def create_confusion_matrix(actual_labels_cleaned, df_cleaned_filtered):
    assert len(actual_labels_cleaned) == len(df_cleaned_filtered), "DataFrames must be of the same length"

    true_labels = actual_labels_cleaned['annotation']
    predicted_labels = df_cleaned_filtered['activity_predicted']

    # Generate confusion matrix
    cm = confusion_matrix(true_labels, predicted_labels, labels=['light', 'moderate-vigorous', 'sedentary'])
    
    logging.log("create_confusion_matrix", "Created confusion matrix.")
    return cm


def display_confusion_matrix(cm, normalize=True):
    logging.log("display_confusion_matrix", "Display confusion matrix.")
    import matplotlib.pyplot as plt
    
    if normalize:
    # Normalize by true values
        cm = cm.astype(float)
        row_sums = cm.sum(axis=1)

        # Avoid division by zero; replace zeros with ones (or a very small number) in the denominator
        row_sums[row_sums == 0] = 1

        # Normalize each row
        cm = cm / row_sums[:, np.newaxis]

    # Display the confusion matrix
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=['light', 'mod-vigorous', 'sedentary'])
    disp.plot(cmap='Blues')
    plt.savefig(os.path.join(confusion_matrix_location, datetime.now().strftime("%m-%d-%Y-%H-%M-%S") + ".png"))
    


if __name__ == "__main__":
    # get data files
    predicted_data_files = get_files(data_path=predicted_data_path, predicted_files=True)
    annotated_data_files = get_files(data_path=annotated_data_path, annotated_files=True)
    assert len(predicted_data_files) == len(annotated_data_files), "Number of predicted and annotated data files should be the same."
    
    labels_dict, cp_labels_dict = create_labels_dict()
    
    labels = ["light", "moderate-vigorous", "sedentary"]
    combined_cm = np.zeros((len(labels), len(labels)), dtype=float)
    
    for predicted_file, annotated_file in zip(predicted_data_files, annotated_data_files):
        logging.log("main", f"Processing predicted_file: {predicted_file} and annotated_file:{annotated_file}")
        df_cleaned = decode_activities(predicted_file)
        actual_labels = process_annotated_data(annotated_file)
        actual_labels_cleaned, df_cleaned_filtered = filtering_data(df_cleaned, actual_labels, labels_dict, cp_labels_dict)
        cm = create_confusion_matrix(actual_labels_cleaned, df_cleaned_filtered)
        logging.log("main", f"create confusion matrix: {cm}")
        logging.log("main", f"combined confusion matrix: {combined_cm}")
        
        combined_cm += cm

    
    logging.log("main", f"combined confusion matrix is: {combined_cm}")        
    
    display_confusion_matrix(combined_cm, normalize=True)
    time.sleep(1)
    display_confusion_matrix(combined_cm, normalize=False)