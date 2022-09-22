import sys
import matplotlib as mpl
#NOTE: if you save the first script somewhere else, you need to update this next line to that location
sys.path.append("~/ccbb_projects/cmm522_code/")
import pyart

#You can change any of the default arguments in this function to make new plots
#If you want to re-draw a plot you know the seed for, set 'num_plots=1' and 'nonrandom=[whatever seed you want]'
#An example: make_some_art(num_plots=1,nonrandom=2000,bkgd_color='green',outdir = "~/ccbb_projects")
pyart.make_some_art()
pyart.make_some_art(fill_colors=mpl.cm.cool)
pyart.make_some_art(fill_colors=mpl.cm.viridis)
pyart.make_some_art(fill_colors=mpl.cm.YlGnBu)
pyart.make_some_art(line_colors=mpl.cm.viridis)