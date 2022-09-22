#It may be possible to bound these with code from here:
#https://stackoverflow.com/questions/36063533/clipping-a-voronoi-diagram-python
#requires shapely
box = Polygon([[0, 0], [0, x_max], [x_max, y_max], [x_max, 0]])

# colorize
for region in shapes_ind:
    polygon = verts[region]
    # Clipping polygon
    poly = Polygon(polygon)
    poly = poly.intersection(box)
    polygon = [p for p in poly.exterior.coords]

    return(polygon)
