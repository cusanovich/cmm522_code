import os
import random
import numpy as np
from scipy.spatial import Voronoi

import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
import matplotlib as mpl

def make_some_art(num_plots = 5, num_points = 200, percent_to_fill = 0.5, n_fill_lines = 5, min_scalar = 0.1, fill_colors='none',
                  line_colors = 'black', line_widths = 1.5, x_max = 16, y_max = 16, debug = False, outdir = "./",
                  nonrandom = None):
    
    outdir = os.path.expanduser(outdir)
    outdir = os.path.join(outdir,"pyart")
    os.makedirs(outdir,exist_ok=True)
    for i in range(num_plots):
        if nonrandom is not None:
            rando = nonrandom
        else:
            rando = np.random.randint(1000,9999,1)[0]
        random.seed(rando)
        x = np.random.uniform(0,x_max, size=num_points).reshape((num_points, 1))
        y = np.random.uniform(0,y_max, size=num_points).reshape((num_points, 1))
        pts = np.hstack([x, y])
    
        vor = Voronoi(pts)
        verts = vor.vertices
        shapes_ind = vor.regions
    
        shapes_ind = [s+s[0:1] for s in shapes_ind if len(s)>0 and -1 not in s]
        shapes = [verts[s] for s in shapes_ind]
    
        n_shapes_to_fill = int(percent_to_fill*len(shapes))
        fill_id = np.random.choice(np.arange(len(shapes)), size=n_shapes_to_fill, replace=False).tolist()
        shapes_to_fill = [shapes[i] for i in fill_id]
    
        fill = []
    
        for s in shapes_to_fill:
            center = np.mean(s, axis=0)
            for scaler in np.linspace(1, min_scalar, num=n_fill_lines, endpoint=False):
                scaled = scaler*(s - center) + center
                fill.append(scaled)

        fig, ax = plt.subplots(figsize=(x_max-1,y_max-1))
        ax.set_aspect('equal')
        
        if not debug:
            plt.xticks([])
            plt.yticks([])

        ax.set_xlim(1,x_max-1)
        ax.set_ylim(1,y_max-1)
        try:
            multi_colors = fill_colors(range(len(shapes)))
            fill_id_expanded = [fill_id[i] for i in range(len(fill_id)) for j in range(n_fill_lines)]
            new_colors = tuple([multi_colors[i,:] for i in fill_id_expanded])
            final_colors = np.vstack((multi_colors,new_colors))
            ax.set_facecolor(final_colors[0,:])
        except TypeError:
            final_colors = fill_colors
            ax.set_facecolor(final_colors)
        try:
            multi_line_colors = line_colors(range(len(shapes)))
            fill_id_expanded = [fill_id[i] for i in range(len(fill_id)) for j in range(n_fill_lines)]
            new_colors = tuple([multi_line_colors[i,:] for i in fill_id_expanded])
            final_line_colors = np.vstack((multi_line_colors,new_colors))
        except TypeError:
            final_line_colors = line_colors
        lc = PolyCollection(shapes+fill,edgecolors=final_line_colors,linewidths=line_widths,facecolors=final_colors)
        ax.add_collection(lc)
        fig.savefig(os.path.join(outdir, 'Pyart_' + str(rando) + '.pdf'))
        plt.close(fig)
        print('File ' + str(i+1) + ': ' + os.path.join(outdir, 'Pyart_' + str(rando) + '.pdf'))