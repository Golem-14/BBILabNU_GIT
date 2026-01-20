import os
import numpy as np
import pandas as pd
from scipy.signal import butter, lfilter
from statsmodels.tsa.stattools import adfuller

# --- 1. Constants and Setup ---

# MAIN DATA PARAMETERS
# Use raw string (r"...") for Windows paths to avoid issues with backslashes
PATH_TO_DATA = r"C:\Users\User\Documents\Lyubov\Readings\Calib 28 (2nd RECalib for C21, set 18) LV 190625 Tau"
N_CONC = 6         # Number of Conc. values
N_VAL = 20         # Number of times each Conc. was sampled
CHAN_NUMBER = 6    # The channel being analysed (MATLAB uses 1-based indexing, we will use 1-based here for consistency with original script)
CALIBRATION = 1    # Calibration (1) or detection files (0)

# SPECTRAL PROCESSING PARAMETERS
TRANSIENT = 1000   # Length of filter transient
FBG_LEFT = 11000   # Leftmost part of the FBG spectrum
FBG_RIGHT = 12000  # Rightmost part of the FBG spectrum
PV_FOUND = 0       # 1 if peaks/valleys found, 0 for randomization
MPP = 1.5          # Min. peak prominence for find_peaks (if PV_FOUND=1)

# FILTER PARAMETERS (Default from MATLAB script)
FILTER_ORDER = 5
CUTOFF_FREQ = 0.05 
B, A = butter(FILTER_ORDER, CUTOFF_FREQ, btype='low', analog=False)

# ADFULLER PARAMETERS
ALPHA = 0.05
TARGET_WAVELENGTH_INDEX = 3455 # Wavelength index to extract time series (0-based: 3454)

# --- 2. Core Functions ---

def apply_butterworth_filter(data_matrix: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    """Applies the Butterworth filter to each row of the data matrix."""
    filtered_matrix = np.zeros_like(data_matrix, dtype=float)
    for i in range(data_matrix.shape[0]):
        # lfilter applies the filter to the data
        filtered_matrix[i, :] = lfilter(b, a, data_matrix[i, :])
    return filtered_matrix

def adfuller_test_report(timeseries: np.ndarray, alpha: float = 0.05) -> pd.DataFrame:
    """
    Performs the ADFuller test using specified models and generates a report.
    This function is reusable for any time series input.
    """
    # Mapping to statsmodels regression options
    # 'ar' -> 'nc', 'ard' -> 'c', 'ts' -> 'ct'
    model_map = {
        'AR (No Drift, No Trend)': 'nc',
        'ARD (Drift/Constant)': 'c',
        'TS (Trend Stationary)': 'ct'
    }

    results = []

    for model_name, regression_option in model_map.items():
        try:
            # autolag='AIC' selects optimal lags
            result = adfuller(timeseries, regression=regression_option, autolag='AIC')
            test_statistic = result[0]
            p_value = result[1]
            critical_values = result[4]
            
            # Interpretation: Reject H0 (Stationary) if p-value <= alpha
            is_stationary = 'Yes' if p_value <= alpha else 'No'
            
            results.append({
                'Test Model': model_name,
                'P-value': f'{p_value:.5f}',
                f'Stationary (P-value <= {alpha*100:.0f}%)': is_stationary,
                'Test Statistic': f'{test_statistic:.4f}',
                'Critical Value (5%)': f'{critical_values["5%"]:.4f}',
            })
            
        except Exception as e:
            results.append({
                'Test Model': model_name,
                'P-value': 'Error',
                'Stationary (P-value)': 'Error',
                'Test Statistic': 'Error',
                'Critical Value (5%)': 'Error',
                'Notes': str(e)
            })

    return pd.DataFrame(results)


# --- 3. Main Execution Block ---

def load_and_clean_data(fname: str, N_HEADER_LINES: int = 5) -> np.ndarray:
    """
    Reads a file line-by-line, stripping common errors like inconsistent whitespace
    and headers, then returns a cleaned NumPy array.
    """
    cleaned_lines = []
    
    with open(fname, 'r') as f:
        # Skip header lines
        for _ in range(N_HEADER_LINES):
            try:
                next(f)
            except StopIteration:
                raise ValueError(f"File ended unexpectedly while skipping {N_HEADER_LINES} header lines.")
            
        # Process data lines
        for line in f:
            # 1. Strip leading/trailing whitespace
            # 2. Split line by whitespace, then join with a single space (cleans up multiple spaces)
            clean_line = ' '.join(line.strip().split())
            
            # Skip empty lines
            if not clean_line:
                continue
                
            # Convert string elements to numbers (float)
            try:
                # Split by space and convert
                numeric_elements = [float(x) for x in clean_line.split(' ')]
                cleaned_lines.append(numeric_elements)
            except ValueError:
                # Silently skip lines that contain non-numeric data (e.g., comments/footers)
                continue 

    if not cleaned_lines:
        raise ValueError(f"No numeric data found after skipping {N_HEADER_LINES} lines in {fname}")

    # Convert the list of lists into a NumPy array
    return np.array(cleaned_lines)


# --- 3. Main Execution Block ---

if __name__ == "__main__":
    
    # --- Data Loading setup and loop initiation remain the same ---
    print("--- 1. Loading and Organizing Data ---")
    all_channels_data = {}
    total_measurements = N_CONC * N_VAL
    
    # Define N_HEADER_LINES here to be used by the new function
    N_HEADER_LINES = 5  # <--- ADJUST THIS NUMBER BASED ON YOUR FILE'S ACTUAL HEADER/METADATA COUNT

    for i in range(1, total_measurements + 1):
        ii = (i - 1) // N_VAL + 1 
        jj = (i - 1) % N_VAL + 1  
        
        if CALIBRATION == 1:
            fname = os.path.join(PATH_TO_DATA, f'RI{ii}_{jj}.txt')
        else:
            fname = os.path.join(PATH_TO_DATA, f'concentration{ii}_measurement{jj}.txt')

        try:
            # ---------------------------------------------------
            # *** REPLACED PANDAS CALL WITH ROBUST FUNCTION ***
            # ---------------------------------------------------
            data_matrix = load_and_clean_data(fname, N_HEADER_LINES=N_HEADER_LINES)
            
            # Use data_matrix.shape[1] for column count
            if data_matrix.shape[1] < 2:
                 raise ValueError(f"File {fname} has fewer than 2 data columns.")

            # The first column is Wavelength
            if i == 1:
                WAVELENGTH = data_matrix[:, 0]
            
            # Load intensity channels 1 to 8 
            for k in range(1, 9):
                if k not in all_channels_data:
                    all_channels_data[k] = []
                
                # Check if the column exists
                if k < data_matrix.shape[1]:
                    all_channels_data[k].append(data_matrix[:, k])
                else:
                    # Pad with zeros if channel data is missing
                    all_channels_data[k].append(np.zeros(len(WAVELENGTH)))
                    
        except FileNotFoundError:
            print(f"Warning: File not found at {fname}. Skipping.")
        except Exception as e:
            # This will catch the ValueError from load_and_clean_data
            print(f"Error loading {fname}: {e}. Skipping.")
##############################
    
    # Convert lists of arrays into NumPy matrices (N_total x N_wavelength)
    for k in all_channels_data.keys():
        all_channels_data[k] = np.array(all_channels_data[k])
        ########################################

        
    # --- 3.2 Filtering and Channel Selection ---
    
    # Apply filter to all loaded channels
    filtered_channels_data = {}
    for k, data_matrix in all_channels_data.items():
        filtered_channels_data[k] = apply_butterworth_filter(data_matrix, B, A)

    # Select the target channel data (1-based index)
    try:
        channel_data = filtered_channels_data[CHAN_NUMBER]
    except KeyError:
        print(f"Error: Channel {CHAN_NUMBER} not found or data loading failed.")
        exit()
        
    # --- 3.3 Spectral Selection (Used for ADFuller Test) ---
    
    # The MATLAB script uses CH6(:, 3455) for the time series
    # In 0-based Python indexing, this is channel_data[:, 3454]
    
    # Extract the time series for the specific wavelength index
    # We use the raw data CHX in the MATLAB script, not the filtered CHF
    # To strictly match the MATLAB test, we use the raw data before filtering:
    raw_channel_data = all_channels_data[CHAN_NUMBER]
    
    # Check if the index is valid
    if TARGET_WAVELENGTH_INDEX >= raw_channel_data.shape[1] or TARGET_WAVELENGTH_INDEX < 0:
         print(f"Error: Wavelength index {TARGET_WAVELENGTH_INDEX} is out of bounds (0-{raw_channel_data.shape[1]-1}).")
         exit()
         
    sensor_timeseries = raw_channel_data[:, TARGET_WAVELENGTH_INDEX]

    # --- 3.4 Stationarity Assessment (ADFuller Test) ---

    print("\n--- 2. ADFuller Stationarity Test Report ---")
    
    # Call the reusable function with the extracted time series
    stationarity_report = adfuller_test_report(sensor_timeseries, alpha=ALPHA)
    
    # Print the report in a markdown/table format for easy reading
    print(stationarity_report.to_markdown(index=False))

    # --- 3.5 Spectal Peak/Valley Identification (Optional, simplified) ---
    # The full MATLAB logic for P/V identification and plotting is complex and skipped here
    # but the necessary data (WAVELENGTH, channel_data) is available above.