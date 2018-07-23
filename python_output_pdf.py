#!/usr/lib/python
from fpdf import FPDF
monPdf = FPDF()
monPdf.add_page()
monPdf.set_font("Arial", size=10)
monPdf.cell(200, 10, txt="Bonjour les visiteurs", ln=1, align="C")
monPdf.output("mon_fichier.pdf")
