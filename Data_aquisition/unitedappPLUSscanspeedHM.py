#! /usr/bin/env python
#
# getspectrumandpeaksplot.py
#

import sys
import os
import time
from datetime import datetime
import tkinter as tk
from tkinter import messagebox, filedialog, Spinbox, ttk
from tkinter import StringVar 

import hyperion

# --- NX-01/MACO COLOR SCHEME & STYLES ---
# Based on the highly industrial, high-contrast, blue/gray palette of Enterprise (ENT)
COLOR_BG_NX01 = "#0F1A25"      # Deep Blue-Gray Background
COLOR_TEXT_LIGHT = "#FFFFFF"   # Pure White Text (High Contrast)
COLOR_PANEL_BLUE = "#4A7A9C"   # Muted Steel Blue (Primary Panel/Action)
COLOR_PANEL_RED = "#D65050"    # Alert Red (Warnings/Status)
COLOR_ACCENT_1 = "#A9B3BD"     # Light Gray/Silver (Border/Accent)
COLOR_ACCENT_2 = "#2A4056"     # Darker Blue-Gray (Secondary Panel/Trough)
COLOR_INPUT_FIELD = "#04080B"  # Nearly Black for fields

# Fonts - Fixedsys or Courier New for a high-contrast, blocky look (non-bold)
FONT_NX01_HEADER = ("Fixedsys", 14) 
FONT_NX01_BUTTON = ("Fixedsys", 12)
FONT_NX01_DEFAULT = ("Fixedsys", 10) 
# ---------------------------------------------


def set_laser_scan_speed(h_instance, speed_hz, status_label):
    """Sets the laser scan speed (100 Hz or 1000 Hz)."""
    status_label.config(text=f"SETTING LASER SPEED TO {speed_hz} HZ... STAND BY.", fg=COLOR_ACCENT_1)
    root.update_idletasks()
    
    try:
        h_instance.laser_scan_speed = int(speed_hz)
        status_label.config(text=f"LASER SPEED SET SUCCESSFULLY. READY.", fg=COLOR_TEXT_LIGHT)
        root.update_idletasks()
        
    except Exception as e:
        status_label.config(text=f"!!! SPEED SET FAILURE !!! CHECK SYSTEM LOGS.", fg=COLOR_PANEL_RED)
        messagebox.showerror("CRITICAL ERROR", f"Could not set laser scan speed: {e}")


def acquire_and_save_data(h_instance, num_acquisitions, acquisition_interval, dest_folder, status_label, decimal_places, progress_bar):
    """Acquires spectrum data and saves it to a list of file paths in a specified folder."""
    status_label.config(text=f"--- ACQUISITION PROTOCOL STARTING FOR {num_acquisitions} DATA CYCLES ---", fg=COLOR_ACCENT_1)
    
    file_names = []
    
    format_string = f".{decimal_places}f"
    
    try:
        active_channels = range(1, h_instance.channel_count + 1)
        h_instance.active_full_spectrum_channel_numbers = active_channels
        
        for i in range(num_acquisitions):
            status_label.config(text=f"DATA CYCLE {i + 1} OF {num_acquisitions} ACQUIRED. PROCESSING...", fg=COLOR_TEXT_LIGHT)
            root.update_idletasks() 
            
            spectra = h_instance.spectra
            wavelengths = spectra.wavelengths

            timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S-%f")
            filename = f"SENSOR_DATA_{timestamp}_{i+1}.txt" 
            
            file_path = os.path.join(dest_folder, filename)
            
            with open(file_path, 'w') as f:
                header = "WAVELENGTH (NM)"
                for channel in active_channels:
                    header += f", CHANNEL {channel} (DBM)"
                f.write(header + "\n")
                
                amplitude_data_list = [spectra[channel] for channel in active_channels]
                
                for j, wavelength in enumerate(wavelengths):
                    wavelength_str = f"{wavelength:{format_string}}"
                    line = f"{wavelength_str}"
                    for amplitude_list in amplitude_data_list:
                        amplitude_str = f"{amplitude_list[j]:{format_string}}"
                        line += f",{amplitude_str}"
                    f.write(line + "\n")

            status_label.config(text=f"SENSOR DATA LOGGED TO {filename}", fg=COLOR_TEXT_LIGHT)
            
            # UPDATE PROGRESS BAR
            progress_bar['value'] = i + 1
            root.update_idletasks() 
            
            file_names.append(filename)
            
            if i < num_acquisitions - 1:
                time.sleep(acquisition_interval)
                
    except Exception as e:
        status_label.config(text="!!! ACQUISITION FAILURE !!! WARNING: UNEXPECTED ERROR.", fg=COLOR_PANEL_RED)
        messagebox.showerror("ACQUISITION TERMINATED", f"An error occurred: {e}")
        return []
    
    return file_names

def rename_files(file_list, conc_value, dest_folder, status_label, naming_convention):
    """Renames files based on a concentration value, measurement number, and convention."""
    status_label.config(text="RENAMING PROTOCOL ACTIVE.", fg=COLOR_ACCENT_1)
    
    for old_filename in file_list:
        try:
            parts = old_filename.split('_')
            measurement_str = parts[-1].split('.')[0]
            measurement_number = int(measurement_str)
            
            # --- New Naming Logic ---
            if naming_convention == "Detection":
                new_filename = f"measurement{conc_value}_measurement{measurement_number}.txt" 
            elif naming_convention == "Calibration (RI)":
                new_filename = f"RI{conc_value}_{measurement_number}.txt" 
            else:
                new_filename = old_filename 
            # --- End Naming Logic ---
            
            old_path = os.path.join(dest_folder, old_filename)
            new_path = os.path.join(dest_folder, new_filename)
            
            os.rename(old_path, new_path)
            status_label.config(text=f"FILE RENAME COMPLETE: {new_filename}", fg=COLOR_TEXT_LIGHT)
            root.update_idletasks()
            
        except (ValueError, IndexError) as e:
            status_label.config(text=f"!!! NAME MISMATCH - SKIPPING FILE !!!", fg=COLOR_PANEL_RED)
            messagebox.showerror("RENAMING ERROR", f"Skipping file '{old_filename}' due to naming format mismatch. Error: {e}")
        except FileNotFoundError:
            status_label.config(text=f"!!! FILE NOT FOUND !!!", fg=COLOR_PANEL_RED)


def start_acquisition():
    """Main function to handle all button click logic."""
    ip_address = entry_ip.get()
    
    # 1. Get input values and validate
    try:
        num_points = int(entry_num_points.get())
        interval_seconds = float(entry_interval.get())
        conc = entry_conc.get()
        decimal_places = int(spinbox_decimal_places.get())
        
        naming_choice = rename_var.get()
        scan_speed_choice = scan_speed_var.get() 
        
        if not conc:
            messagebox.showerror("INPUT ERROR", "ENTER CONCENTRATION VALUE.")
            return
        if not naming_choice:
            messagebox.showerror("INPUT ERROR", "SELECT FILE NAMING PROTOCOL.")
            return

    except ValueError:
        messagebox.showerror("INPUT ERROR", "INPUT VALUE MISMATCH. CHECK PARAMETERS.")
        return
    
    # Reset progress bar before starting
    progress_bar['value'] = 0
    progress_bar['maximum'] = num_points
    root.update_idletasks()

    # 2. Select destination folder
    destination_folder = filedialog.askdirectory(title="SELECT DATA LOG DESTINATION")
    if not destination_folder:
        return # User canceled the dialog
    
    # 3. Connect and run acquisition
    h1 = None
    try:
        status_label.config(text=f"ATTEMPTING CONNECTION TO HYPERION {ip_address}...", fg=COLOR_ACCENT_1)
        root.update_idletasks()
        h1 = hyperion.Hyperion(ip_address)

        set_laser_scan_speed(h1, scan_speed_choice, status_label)

        saved_files = acquire_and_save_data(h1, num_points, interval_seconds, destination_folder, status_label, decimal_places, progress_bar)
        
        if saved_files:
            rename_files(saved_files, conc, destination_folder, status_label, naming_choice)
        
        status_label.config(text="*** MISSION COMPLETE: ALL SYSTEMS NOMINAL ***", fg=COLOR_PANEL_BLUE)
        messagebox.showinfo("SUCCESS", "DATA ACQUISITION COMPLETE! LOGS FILED.")

    except Exception as e:
        status_label.config(text="!!! CATASTROPHIC FAILURE !!! SYSTEMS RED ALERT.", fg=COLOR_PANEL_RED)
        messagebox.showerror("GENERAL SYSTEM FAILURE", f"A fatal error occurred: {e}")
    finally:
        if 'h1' in locals() and h1 is not None:
            try:
                h1.comm.close()
                status_label.config(text="CONNECTION TERMINATED. SYSTEM STANDBY.", fg=COLOR_TEXT_LIGHT)
            except Exception:
                status_label.config(text="CONNECTION TERMINATED. SYSTEM STANDBY.", fg=COLOR_TEXT_LIGHT)
        
        # Final cleanup of progress bar
        progress_bar['value'] = 0
        root.update_idletasks()


# --- GUI Setup ---
root = tk.Tk()
root.title("NX-01: MICRON OPTICS DATA ACQUISITION TERMINAL")
root.geometry("700x750") 
root.resizable(False, False)

# Set NX-01 Blue-Gray Background
root.configure(bg=COLOR_BG_NX01)


# Style for ttk (Progressbar) - High-contrast red on dark blue/gray
style = ttk.Style()
style.theme_use('clam') 
style.configure("TProgressbar", 
                foreground=COLOR_PANEL_RED, 
                background=COLOR_PANEL_RED, 
                troughcolor=COLOR_ACCENT_2, # Darker blue-gray trough
                bordercolor=COLOR_ACCENT_1,
                thickness=15)
style.map('TProgressbar', background=[('active', COLOR_PANEL_RED)])


# Main frame for padding, simulating the main console area
main_frame = tk.Frame(root, padx=20, pady=20, bg=COLOR_BG_NX01) 
main_frame.pack(expand=True)

# Helper function for NX-01 labeling
def create_nx01_label(parent, text, row, column, sticky="w", pady=2, font=FONT_NX01_DEFAULT, bg_color=COLOR_BG_NX01):
    # Text is displayed in ALL CAPS
    return tk.Label(parent, text=text.upper(), bg=bg_color, fg=COLOR_TEXT_LIGHT, font=font).grid(row=row, column=column, sticky=sticky, pady=pady)

# Helper function for input fields (high-contrast border)
def create_nx01_entry(parent, row, column, initial_text=""):
    # High-contrast dark field with sharp RIDGE border and blue cursor
    entry = tk.Entry(parent, bg=COLOR_INPUT_FIELD, fg=COLOR_TEXT_LIGHT, insertbackground=COLOR_PANEL_BLUE, 
                     relief=tk.RIDGE, bd=2, font=FONT_NX01_DEFAULT)
    # ipady is passed here correctly to .grid()
    entry.grid(row=row, column=column, sticky="ew", pady=5, ipady=3) 
    entry.insert(0, initial_text)
    return entry

# --- Input Fields Frame (Main Control Panel) ---
# Use secondary accent color with a strong border
input_panel = tk.Frame(main_frame, bg=COLOR_ACCENT_2, padx=15, pady=15, 
                       relief=tk.RIDGE, bd=3, highlightbackground=COLOR_ACCENT_1, highlightthickness=1)
input_panel.grid(row=0, column=0, columnspan=2, sticky="ew", pady=(0, 15))

# Use the frame's background color for labels within it
create_nx01_label(input_panel, "HYPERION IP ADDRESS:", 0, 0, bg_color=COLOR_ACCENT_2)
entry_ip = create_nx01_entry(input_panel, 0, 1, "10.0.0.55")

create_nx01_label(input_panel, "NUMBER OF DATA POINTS:", 1, 0, bg_color=COLOR_ACCENT_2)
entry_num_points = create_nx01_entry(input_panel, 1, 1)

create_nx01_label(input_panel, "ACQUISITION INTERVAL (s):", 2, 0, bg_color=COLOR_ACCENT_2)
entry_interval = create_nx01_entry(input_panel, 2, 1)

create_nx01_label(input_panel, "CONCENTRATION/RI VALUE:", 3, 0, bg_color=COLOR_ACCENT_2)
entry_conc = create_nx01_entry(input_panel, 3, 1)

create_nx01_label(input_panel, "DECIMAL PRECISION (1-10):", 4, 0, bg_color=COLOR_ACCENT_2)
# Spinbox needs the same border styling
spinbox_decimal_places = Spinbox(input_panel, from_=1, to=10, bg=COLOR_INPUT_FIELD, fg=COLOR_TEXT_LIGHT, 
                                 relief=tk.RIDGE, bd=2, font=FONT_NX01_DEFAULT, insertbackground=COLOR_PANEL_BLUE)
spinbox_decimal_places.grid(row=4, column=1, sticky="ew", pady=5, ipady=3)
spinbox_decimal_places.delete(0, "end")
spinbox_decimal_places.insert(0, "4")


# --- Options Frame (Side-by-Side Panels) ---
options_frame = tk.Frame(main_frame, bg=COLOR_BG_NX01)
options_frame.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(15, 10))

# --- Laser Scan Speed Option (Left: Speed Frame) ---
# Primary action color with sharp RIDGE border
speed_frame = tk.Frame(options_frame, padx=15, pady=10, bg=COLOR_PANEL_BLUE, bd=3, relief=tk.RIDGE) 
speed_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 15), anchor="n") 

tk.Label(speed_frame, text="LASER SCAN SPEED", font=FONT_NX01_HEADER, fg=COLOR_TEXT_LIGHT, bg=COLOR_PANEL_BLUE).grid(row=0, column=0, sticky="w", pady=(0, 10))

# Variable to hold the selected scan speed
scan_speed_var = StringVar(value="1000") 

# Radio Button styling 
tk.Radiobutton(speed_frame, text="1000 HZ", variable=scan_speed_var, value="1000", 
               bg=COLOR_PANEL_BLUE, fg=COLOR_TEXT_LIGHT, selectcolor=COLOR_PANEL_BLUE, font=FONT_NX01_DEFAULT, 
               activebackground=COLOR_PANEL_BLUE, activeforeground=COLOR_ACCENT_1, relief=tk.FLAT, bd=0).grid(row=1, column=0, sticky="w")

# Radio Button for 100 Hz
tk.Radiobutton(speed_frame, text="100 HZ", variable=scan_speed_var, value="100", 
               bg=COLOR_PANEL_BLUE, fg=COLOR_TEXT_LIGHT, selectcolor=COLOR_PANEL_BLUE, font=FONT_NX01_DEFAULT,
               activebackground=COLOR_PANEL_BLUE, activeforeground=COLOR_ACCENT_1, relief=tk.FLAT, bd=0).grid(row=2, column=0, sticky="w")

# --- File Naming Option (Right: Naming Frame) ---
# Secondary accent color with sharp RIDGE border
naming_frame = tk.Frame(options_frame, padx=15, pady=10, bg=COLOR_ACCENT_2, bd=3, relief=tk.RIDGE) 
naming_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(15, 0), anchor="n") 

tk.Label(naming_frame, text="FILE NAMING PROTOCOL", font=FONT_NX01_HEADER, fg=COLOR_TEXT_LIGHT, bg=COLOR_ACCENT_2).grid(row=0, column=0, sticky="w", pady=(0, 10))

# Variable to hold the selected option
rename_var = StringVar(value="Detection") 

# Radio Button for Detection
tk.Radiobutton(naming_frame, text="DETECTION (concentrationX_measurementY)", variable=rename_var, value="Detection", 
               bg=COLOR_ACCENT_2, fg=COLOR_TEXT_LIGHT, selectcolor=COLOR_ACCENT_2, font=FONT_NX01_DEFAULT,
               activebackground=COLOR_ACCENT_2, activeforeground=COLOR_PANEL_BLUE, relief=tk.FLAT, bd=0).grid(row=1, column=0, sticky="w")

# Radio Button for Calibration (RI)
tk.Radiobutton(naming_frame, text="CALIBRATION (RIX_Y)", variable=rename_var, value="Calibration (RI)", 
               bg=COLOR_ACCENT_2, fg=COLOR_TEXT_LIGHT, selectcolor=COLOR_ACCENT_2, font=FONT_NX01_DEFAULT,
               activebackground=COLOR_ACCENT_2, activeforeground=COLOR_PANEL_BLUE, relief=tk.FLAT, bd=0).grid(row=2, column=0, sticky="w")


# --- Progress Bar (Row 2) ---
progress_bar = ttk.Progressbar(main_frame, orient='horizontal', mode='determinate', style="TProgressbar")
progress_bar.grid(row=2, column=0, columnspan=2, sticky="ew", pady=(10, 5))


# Status Label (Row 3) - Dark background, sharp RIDGE border
status_label = tk.Label(main_frame, text="*** TERMINAL ONLINE: AWAITING COMMAND ***", 
                        bd=2, relief=tk.RIDGE, anchor="w", 
                        bg=COLOR_INPUT_FIELD, # Dark background for status bar
                        fg=COLOR_PANEL_BLUE, # Blue text for general status
                        font=FONT_NX01_DEFAULT)
status_label.grid(row=3, column=0, columnspan=2, sticky="ew", pady=5, ipady=3) 

# Start button (Row 4) - Sharp RIDGE border, high contrast
start_button = tk.Button(main_frame, text="ENGAGE ACQUISITION", 
                         command=start_acquisition, 
                         bg=COLOR_PANEL_BLUE, 
                         fg=COLOR_TEXT_LIGHT, 
                         activebackground=COLOR_ACCENT_1, 
                         activeforeground=COLOR_INPUT_FIELD, 
                         font=FONT_NX01_BUTTON,
                         relief=tk.RIDGE, bd=3)
start_button.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(15, 5), ipady=10)


# --- Instructions Section ---
instructions_frame = tk.Frame(root, padx=20, pady=10, bg=COLOR_BG_NX01)
instructions_frame.pack(fill="both", expand=True)

tk.Label(instructions_frame, text="PROTOCOL INSTRUCTIONS", font=FONT_NX01_HEADER, fg=COLOR_ACCENT_1, bg=COLOR_BG_NX01).pack(anchor="w", pady=(0, 5))

# Text area (dark background, sharp RIDGE border)
instructions_text = tk.Text(instructions_frame, wrap=tk.WORD, height=8, width=50, state="normal", 
                            bg=COLOR_INPUT_FIELD, fg=COLOR_TEXT_LIGHT, relief=tk.RIDGE, bd=2, font=FONT_NX01_DEFAULT,
                            insertbackground=COLOR_PANEL_BLUE)
instructions_text.pack(fill="both", expand=True)

instructions_content = """
1. Ensure the Hyperion interrogator is connected.
2. Enter acquisition details (Points, Interval, Concentration).
3. Select the desired **Laser Scan Speed (100 Hz or 1000 Hz)**.
4. Select the desired File Naming Convention (Detection or Calibration).
5. Click 'ENGAGE ACQUISITION' and select the destination folder.
6. The **Progress Bar** will now show acquisition progress.
7. Reading will stop after all data points are saved, then you can enter next concentration, confirm folder and proceed.
"""

instructions_text.insert(tk.END, instructions_content)
instructions_text.config(state="disabled") 

# Run the GUI
root.mainloop()