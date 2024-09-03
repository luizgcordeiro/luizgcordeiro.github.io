import tkinter as tk
from tkinter import ttk

# Funções de operação na matriz
def apply_modulo(matrix, p):
    return [[str(int(element) % p) for element in row] for row in matrix]

def multiply_row(matrix, row, factor, p):
    if p!=0:
        matrix[row] = [str((int(element) * factor) % p) for element in matrix[row]]
    else:
        matrix[row] = [str(int(element) * factor) for element in matrix[row]]
    return matrix

def add_rows(matrix, row1, factor, row2, p):
    if p!=0:
        matrix[row1] = [str((int(matrix[row1][i]) + factor * int(matrix[row2][i])) % p) for i in range(len(matrix[row1]))]
    else:
        matrix[row1] = [str(int(matrix[row1][i]) + factor * int(matrix[row2][i])) for i in range(len(matrix[row1]))]
    return matrix

def swap_rows(matrix, row1, row2):
    matrix[row1], matrix[row2] = matrix[row2], matrix[row1]
    return matrix

# Função para criar a matriz com entradas nulas
def create_matrix():
    try:
        global matrix_entries, num_rows, num_cols
        matrix_entries = []
        num_rows = int(row_input.get())
        num_cols = int(col_input.get())
        for widget in matrix_frame.winfo_children():
            widget.destroy()
        for i in range(num_rows):
            row_entries = []
            for j in range(num_cols):
                entry = tk.Entry(matrix_frame, width=5)
                entry.insert(0, "0")
                entry.grid(row=i, column=j, padx=5, pady=5)
                row_entries.append(entry)
            matrix_entries.append(row_entries)
        update_operation_widgets()
    except ValueError:
        pass

# Função para aplicar operações
def apply_operations():
    try:
        p = int(mod_input.get()) if mod_input.get()!="" else 0
        matrix = [[entry.get() for entry in row] for row in matrix_entries]
        if operation.get() == "Multiplicar linha":
            row = int(row1.get()[2:]) - 1
            factor = int(factor_entry.get())
            matrix = multiply_row(matrix, row, factor, p)
        elif operation.get() == "Somar linhas":
            row1_index = int(row1.get()[2:]) - 1
            row2_index = int(row2.get()[2:]) - 1
            factor = int(factor_entry.get()) if (factor_entry.get() != "") else 1
            matrix = add_rows(matrix, row1_index, factor, row2_index, p)
        elif operation.get() == "Trocar linhas":
            row1_index = int(row1.get()[2:]) - 1
            row2_index = int(row2.get()[2:]) - 1
            matrix = swap_rows(matrix, row1_index, row2_index)
        for i, row in enumerate(matrix):
            for j, value in enumerate(row):
                matrix_entries[i][j].delete(0, tk.END)
                matrix_entries[i][j].insert(0, value)
    except ValueError:
        pass

# Função para atualizar os widgets de operação conforme a matriz
def update_operation_widgets():
    row_values = [f"L_{i+1}" for i in range(num_rows)]
    row1_menu['values'] = row_values
    row2_menu['values'] = row_values
    row1_menu.current(0)
    row2_menu.current(1)

    operation_label.grid(row=num_rows + 1, column=0, pady=10)
    mod_label.grid(row=num_rows + 1, column=1)
    mod_input.grid(row=num_rows + 1, column=2)
    operation_menu.grid(row=num_rows + 2, column=0, pady=10)
    apply_button.grid(row=num_rows + 2, column=5, padx=5)

    update_operation_fields()

# Função para atualizar os campos de operação conforme a seleção
def update_operation_fields(*args):
    for widget in operation_frame.grid_slaves():
        if widget not in {operation_menu, apply_button, mod_label, mod_input, operation_label}:
            widget.grid_forget()

    if operation.get() == "Multiplicar linha":
        row1_menu.grid(row=num_rows + 2, column=1)
        factor_label.grid(row=num_rows + 2, column=2)
        factor_entry.grid(row=num_rows + 2, column=3)
        factor_label.config(text="*=")
    elif operation.get() == "Somar linhas":
        row1_menu.grid(row=num_rows + 2, column=1)
        factor_label.config(text="+=")
        factor_label.grid(row=num_rows + 2, column=2)
        factor_entry.grid(row=num_rows + 2, column=3)
        row2_menu.grid(row=num_rows + 2, column=4)
    elif operation.get() == "Trocar linhas":
        row1_menu.grid(row=num_rows + 2, column=1)
        factor_label.config(text="↔")
        factor_label.grid(row=num_rows + 2, column=2)
        row2_menu.grid(row=num_rows + 2, column=3)

# Configuração da interface
root = tk.Tk()
root.title("Escalonamento de Matrizes Modulo n")
root.geometry("600x600")

top_frame = tk.Frame(root)
top_frame.pack(pady=10)

tk.Label(top_frame, text="ordem:").pack(side=tk.LEFT)
row_input = tk.Entry(top_frame, width=5)
row_input.pack(side=tk.LEFT)
tk.Label(top_frame, text="x").pack(side=tk.LEFT)
col_input = tk.Entry(top_frame, width=5)
col_input.pack(side=tk.LEFT)
create_button = tk.Button(top_frame, text="Criar", command=create_matrix)
create_button.pack(side=tk.LEFT, padx=5)

matrix_frame = tk.Frame(root)
matrix_frame.pack(pady=10)

operation_frame = tk.Frame(root)
operation_frame.pack(pady=10)

operation = tk.StringVar()
operation.set("Multiplicar linha")

operation.trace_add("write", update_operation_fields)

operation_label = tk.Label(operation_frame, text="Operações:")
mod_label = tk.Label(operation_frame, text="módulo:")
mod_input = tk.Entry(operation_frame, width=5)

operation_menu = ttk.Combobox(operation_frame, textvariable=operation, values=["Multiplicar linha", "Somar linhas", "Trocar linhas"],state='readonly')
row1 = tk.StringVar()
row1_menu = ttk.Combobox(operation_frame, textvariable=row1, state='readonly')
factor_label = tk.Label(operation_frame, text="fator:")
factor_entry = tk.Entry(operation_frame, width=5)
row2 = tk.StringVar()
row2_menu = ttk.Combobox(operation_frame, textvariable=row2, state='readonly')
apply_button = tk.Button(operation_frame, text="APLICAR", command=apply_operations)

root.mainloop()