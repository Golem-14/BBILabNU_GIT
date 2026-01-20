import os
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
from scipy.signal import butter, lfilter
from statsmodels.tsa.stattools import adfuller

# --- 1. Constants and Setup ---

# MAIN DATA PARAMETERS
# IMPORTANT: Update this path to your actual data folder
PATH_TO_DATA = r"C:\Users\User\Documents\Lyubov\Readings\Calib 28 (2nd RECalib for C21, set 18) LV 190625 Tau"
N_CONC = 6         
N_VAL = 20         
CALIBRATION = 1    

# FILTER PARAMETERS (Default)
FILTER_ORDER = 5
CUTOFF_FREQ = 0.05 
B, A = butter(FILTER_ORDER, CUTOFF_FREQ, btype='low', analog=False)

# ADFULLER PARAMETERS
ALPHA = 0.05
N_HEADER_LINES = 5  # <--- Set this to the correct number of header/metadata lines

# --- 2. Core Functions (Same robust logic as before) ---

def apply_butterworth_filter(data_matrix: np.ndarray, b: np.ndarray, a: np.ndarray) -> np.ndarray:
    """Applies the Butterworth filter to each row of the data matrix."""
    filtered_matrix = np.zeros_like(data_matrix, dtype=float)
    for i in range(data_matrix.shape[0]):
        filtered_matrix[i, :] = lfilter(b, a, data_matrix[i, :])
    return filtered_matrix

def adfuller_test_report(timeseries: np.ndarray, alpha: float = 0.05) -> str:
    """Performs the ADFuller test and returns a formatted report string."""
    model_map = {
        'AR (No Drift, No Trend)': 'nc',
        'ARD (Drift/Constant)': 'c',
        'TS (Trend Stationary)': 'ct'
    }

    report_lines = ["\n--- ADFuller Stationarity Test Report ---"]
    report_lines.append(f"Significance Level (Alpha): {alpha}")
    report_lines.append("------------------------------------------")

    for model_name, regression_option in model_map.items():
        try:
            result = adfuller(timeseries, regression=regression_option, autolag='AIC')
            p_value = result[1]
            critical_values = result[4]
            
            is_stationary = "[STATIONARY] Reject H0" if p_value <= alpha else "[NON-STATIONARY] Fail H0"
            
            report_lines.append(f"Model: {model_name}")
            report_lines.append(f"  P-value: {p_value:.5f}")
            report_lines.append(f"  Result: {is_stationary}")
            report_lines.append(f"  Critical Value (5%): {critical_values['5%']:.4f}")
            report_lines.append("")
            
        except Exception as e:
            report_lines.append(f"Model: {model_name}")
            report_lines.append(f"  Error: Failed to run test ({str(e)})")
            report_lines.append("")

    return "\n".join(report_lines)

def load_and_clean_data(fname: str, N_HEADER_LINES: int) -> np.ndarray:
    """Robustly reads and cleans delimited data from a text file."""
    cleaned_lines = []
    
    with open(fname, 'r') as f:
        for _ in range(N_HEADER_LINES):
            try:
                next(f)
            except StopIteration:
                raise ValueError(f"File ended unexpectedly while skipping {N_HEADER_LINES} header lines.")
            
        for line in f:
            clean_line = ' '.join(line.strip().split())
            if not clean_line:
                continue
                
            try:
                numeric_elements = [float(x) for x in clean_line.split(' ')]
                cleaned_lines.append(numeric_elements)
            except ValueError:
                continue 

    if not cleaned_lines:
        raise ValueError(f"No numeric data found after skipping {N_HEADER_LINES} lines.")

    return np.array(cleaned_lines)

# --- 3. Main Analysis Logic (Separate from GUI) ---

def run_analysis(chan_number: int, target_wavelength_index: int) -> str:
    """Handles data loading and analysis based on user input."""
    
    all_channels_data = {}
    total_measurements = N_CONC * N_VAL
    WAVELENGTH = None
    
    # 3.1 Data Loading Loop
    for i in range(1, total_measurements + 1):
        ii = (i - 1) // N_VAL + 1 
        jj = (i - 1) % N_VAL + 1  
        
        if CALIBRATION == 1:
            fname = os.path.join(PATH_TO_DATA, f'RI{ii}_{jj}.txt')
        else:
            fname = os.path.join(PATH_TO_DATA, f'concentration{ii}_measurement{jj}.txt')

        try:
            data_matrix = load_and_clean_data(fname, N_HEADER_LINES=N_HEADER_LINES)
            
            if data_matrix.shape[1] < 2:
                 raise ValueError(f"File {fname} has fewer than 2 data columns.")

            if i == 1:
                WAVELENGTH = data_matrix[:, 0]
            
            for k in range(1, 9):
                if k not in all_channels_data:
                    all_channels_data[k] = []
                
                if k < data_matrix.shape[1]:
                    all_channels_data[k].append(data_matrix[:, k])
                else:
                    if WAVELENGTH is not None:
                        all_channels_data[k].append(np.zeros(len(WAVELENGTH)))
                    else:
                        # Cannot pad without knowing length, critical error
                        raise RuntimeError("Wavelength data could not be initialized.")
                    
        except FileNotFoundError:
            return f"Error: File not found at {fname}. Please check PATH_TO_DATA constant."
        except Exception as e:
            return f"Error loading data for RI{ii}_{jj}.txt: {str(e)}"

    for k in all_channels_data.keys():
        try:
            all_channels_data[k] = np.array(all_channels_data[k])
        except ValueError:
            return f"Error: Data for channel {k} is inconsistent in length across files."

    # --- 3.2 Extract Time Series ---
    
    try:
        # NOTE: We use the raw data before filtering for the stationarity test
        raw_channel_data = all_channels_data[chan_number]
    except KeyError:
        return f"Error: Channel {chan_number} data is missing or out of range (1-8)."
        
    if target_wavelength_index >= raw_channel_data.shape[1] or target_wavelength_index < 0:
         return f"Error: Wavelength index {target_wavelength_index} is out of bounds (Max: {raw_channel_data.shape[1]-1})."
         
    sensor_timeseries = raw_channel_data[:, target_wavelength_index]

    if len(sensor_timeseries) < 10:
        return "Error: Time series is too short to run ADFuller test."

    # --- 3.3 Stationarity Assessment ---
    return adfuller_test_report(sensor_timeseries, alpha=ALPHA)


# --- 4. Tkinter Application Class ---

class ADFullerApp:
    def __init__(self, master):
        self.master = master
        master.title("ADFuller Sensor Data Analyzer")
        master.geometry("600x450")

        # Configure style
        style = ttk.Style()
        style.configure('TFrame', padding=10)
        style.configure('TLabel', padding=5)
        style.configure('TButton', padding=5)
        
        # --- Input Frame ---
        input_frame = ttk.Frame(master)
        input_frame.pack(pady=10, padx=10, fill='x')

        # Channel Input
        ttk.Label(input_frame, text="Channel No. (1-8):").grid(row=0, column=0, padx=5, sticky='w')
        self.channel_var = tk.StringVar(value='6')
        self.channel_entry = ttk.Entry(input_frame, textvariable=self.channel_var, width=10)
        self.channel_entry.grid(row=0, column=1, padx=5, sticky='w')
        
        # Index Input
        ttk.Label(input_frame, text="Wavelength Index (0-based):").grid(row=1, column=0, padx=5, sticky='w')
        self.index_var = tk.StringVar(value='3454') # Default to 3455th point (index 3454)
        self.index_entry = ttk.Entry(input_frame, textvariable=self.index_var, width=10)
        self.index_entry.grid(row=1, column=1, padx=5, sticky='w')
        
        # Run Button
        self.run_button = ttk.Button(input_frame, text="Run ADFuller Test", command=self.run_test)
        self.run_button.grid(row=0, column=2, rowspan=2, padx=20, sticky='nsew')

        # --- Output Frame ---
        ttk.Label(master, text="Analysis Report:").pack(padx=10, anchor='w')
        self.report_text = scrolledtext.ScrolledText(master, wrap=tk.WORD, width=60, height=20)
        self.report_text.pack(padx=10, pady=5, fill='both', expand=True)
        self.report_text.insert(tk.END, f"Ready. Current data path: {PATH_TO_DATA}\n")

    def run_test(self):
        self.report_text.delete('1.0', tk.END)
        self.report_text.insert(tk.END, "Running analysis...\n")
        
        try:
            chan_num = int(self.channel_var.get())
            index_num = int(self.index_var.get())
        except ValueError:
            messagebox.showerror("Input Error", "Channel and Index must be integers.")
            self.report_text.insert(tk.END, "Failed: Input must be integer.")
            return

        # Simple input validation
        if not (1 <= chan_num <= 8):
            messagebox.showerror("Input Error", "Channel number must be between 1 and 8.")
            self.report_text.insert(tk.END, "Failed: Channel out of range.")
            return

        # Disable button during run
        self.run_button.config(state=tk.DISABLED, text="Running...")
        self.master.update()

        # Run the core analysis logic
        report = run_analysis(chan_num, index_num)

        # Re-enable button
        self.run_button.config(state=tk.NORMAL, text="Run ADFuller Test")

        # Display the report
        self.report_text.insert(tk.END, report)

if __name__ == "__main__":
    root = tk.Tk()
    app = ADFullerApp(root)
    root.mainloop()