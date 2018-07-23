
#!/usr/bin/python
# -*-coding:Latin-1 -*
import os
import subprocess
from Tkinter import *
def donothing():
   filewin = Toplevel(root)
   button = Button(filewin, text="Do nothing button")
   button.pack()
def page_accueil(event=None):
	os.system('firefox google.fr')
def messagerie_int(event=None):
	os.system('rocketchat /dev/null &')
def messagerie_ext(event=None):
	os.system('messagerie')
def wiki_perso(event=None):
	os.system('zim')
def terminal(event=None):
	os.system('terminator')
def atom(event=None):
	os.system('atom')
def virtualb(event=None):
	os.system('virtualbox')
def youtube(event=None):
	os.system('firefox -new-tab youtube.fr')
def google(event=None):
	os.system('firefox -new-tab google.fr')
def telechargement(event=None):
	os.system('xdg-open /home/oki/T\él\échargements')
root = Tk()
root.title('Xav\'s Bar')
root.bell()
root.maxsize(width=200, height=30)
root.lift()
menubar = Menu(root,background='#338cff',foreground='white',activebackground='#004c99', activeforeground='white')
totomenu = Menu(menubar, tearoff=0,background='#338cff',foreground='white',activebackground='#004c99',activeforeground='white')
totomenu.add_command(label="Firefox (tout)", command=page_accueil, accelerator="Ctrl+f")
root.bind('', page_accueil)
totomenu.add_command(label="Messagerie int", command=messagerie_int, accelerator="Ctrl+m")
root.bind('', messagerie_int)
totomenu.add_command(label="Messagerie ext", command=messagerie_ext, accelerator="Ctrl+c")
root.bind('', messagerie_ext)
totomenu.add_command(label="Wiki perso", command=wiki_perso, accelerator="Ctrl+w" )
root.bind('', wiki_perso)
totomenu.add_command(label="Terminal", command=terminal, accelerator="Ctrl+t")
root.bind('', terminal)
totomenu.add_command(label="Atom editeur", command=atom, accelerator="Ctrl+o")
root.bind('', atom)
totomenu.add_command(label="VirtualBox", command=virtualb, accelerator="Ctrl+u")
root.bind('', virtualb)
totomenu.add_separator()
totomenu.add_command(label="Exit", command=root.quit)
menubar.add_cascade(label="Basiques", menu=totomenu)
editmenu = Menu(menubar, tearoff=0,background='#338cff',foreground='white',activebackground='#004c99',activeforeground='white')
editmenu.add_command(label="Google", command=google)
editmenu.add_command(label="Youtube", command=youtube)
editmenu.add_command(label="Telechargements", command=telechargement)
editmenu.add_command(label="Delete", command=donothing)
editmenu.add_command(label="Select All", command=display)
menubar.add_cascade(label="Persos", menu=editmenu)
helpmenu = Menu(menubar, tearoff=0,background='#338cff',foreground='white',activebackground='#004c99',activeforeground='white')
helpmenu.add_command(label="Help Index", command=donothing)
helpmenu.add_command(label="About...", command=donothing)
menubar.add_cascade(label="Help", menu=helpmenu)
root.config(menu=menubar)
root.mainloop()
