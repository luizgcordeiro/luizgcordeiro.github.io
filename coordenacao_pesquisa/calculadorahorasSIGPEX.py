import tkinter as tk
from tkinter import ttk
from tkcalendar import DateEntry
from datetime import datetime, timedelta
import locale

# Set the locale to Portuguese
locale.setlocale(locale.LC_TIME, 'pt_PT.utf8')


class ProjectCalculator:
    def __init__(self, master):
        self.master = master
        self.master.title("Calculadora de horas semestrais de projetos")

        self.create_widgets()

    def create_widgets(self):
# Explanation Label
        explanation_text = (
            "Este programa calcula o número médio de horas/semana/semestre que você deve "+\
            "registrar no SIGPEX para que o PAAD seja importado corretamente. "+\
            "Selecione as datas e a média de horas que você dedicará ao projeto "+\
            "durante a realização do mesmo."
        )
        self.explanation_label = ttk.Label(self.master, text=explanation_text, wraplength=400, justify='center', font=('Arial', 10))
        self.explanation_label.grid(row=0, column=0, columnspan=2, padx=10, pady=10)


        # Initial Date
        self.label_start_date = ttk.Label(self.master, text="Data de início:")
        self.label_start_date.grid(row=1, column=0, padx=10, pady=10)

        self.entry_start_date = DateEntry(
            self.master, width=12, background='darkblue', foreground='white', borderwidth=2,
            date_pattern="dd/MM/yyyy", locale="pt_PT", firstweekday='sunday'
        )
        self.entry_start_date.grid(row=1, column=1, padx=10, pady=10)

        # Final Date
        self.label_end_date = ttk.Label(self.master, text="Data de término:")
        self.label_end_date.grid(row=2, column=0, padx=10, pady=10)

        self.entry_end_date = DateEntry(
            self.master, width=12, background='darkblue', foreground='white', borderwidth=2,
            date_pattern="dd/MM/yyyy", locale="pt_PT", firstweekday='sunday'
        )
        self.entry_end_date.grid(row=2, column=1, padx=10, pady=10)

        # Average Hours
        self.label_avg_hours = ttk.Label(self.master, text="Média de horas/semana:")
        self.label_avg_hours.grid(row=3, column=0, padx=10, pady=10)

        self.entry_avg_hours = ttk.Entry(self.master)
        self.entry_avg_hours.grid(row=3, column=1, padx=10, pady=10)

        # Calculate Button
        self.calculate_button = ttk.Button(self.master, text="Calcular", command=self.calculate_hours)
        self.calculate_button.grid(row=4, column=0, columnspan=2, pady=20)

        # Result Table
        self.result_table = ttk.Label(self.master, text="")
        self.result_table.grid(row=5, column=0, columnspan=2, pady=10)

    def calculate_hours(self):
        start_date = self.entry_start_date.get_date()
        end_date = self.entry_end_date.get_date()
        avg_hours_str = self.entry_avg_hours.get()

        try:
            avg_hours = float(avg_hours_str)
        except ValueError:
            self.result_table.config(text="Entrada inválida. Por favor, verifique o formato de horas.")
            return

        semester_hours = []
        while start_date <= end_date:
            if start_date.month <= 6:
                days_in_semester = (start_date.replace(month=6, day=30) - start_date.replace(month=1, day=1)).days + 1
                semester = 1
                days_worked = (min(end_date, start_date.replace(month=6, day=30)) - start_date).days + 1
                hours_per_week = avg_hours * days_worked / days_in_semester
                semester_hours.append((start_date.year, semester, round(hours_per_week, 2)))
                start_date = start_date.replace(month=7, day=1)
            else:
                days_in_semester = (start_date.replace(month=12, day=31) - start_date.replace(month=7, day=1)).days + 1
                semester = 2
                days_worked = (min(end_date, start_date.replace(month=12, day=31)) - start_date).days + 1
                hours_per_week = avg_hours * days_worked / days_in_semester
                semester_hours.append((start_date.year, semester, round(hours_per_week, 2)))
                start_date = start_date.replace(year=start_date.year + 1, month=1, day=1)

        result_text = "\n".join([f"{year}/{semester}: {hours} horas/semana" for year, semester, hours in semester_hours])
        self.result_table.config(text=result_text)


def main():
    root = tk.Tk()
    app = ProjectCalculator(root)
    root.mainloop()


if __name__ == "__main__":
    main()
