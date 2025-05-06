import matplotlib.pyplot as plt


### CPU mesh generation
### FPS - MESH Resolution fixed iteration
CPU_MESH_ITERATION_FIXED_FPSY_MESH_RESOLUTIONX = { 
    "FPS" : [260,120,60,20],
    "MESH RESOLUTION": [10,50,100,200]
}
CPU_MESH_ITERATION_FIXED_FPSY_MESH_RESOLUTIONX_TITLE = 'Performance'


### FPS - Iteration fixed mesh resolution
CPU_MESH_MESH_RESOLUTION_FIXED_FPSY_ITERATIONX = {
    "FPS" : [280,170,95,60],
    "ITERATION":[10,30,60,100]
}

### GPU mesh generation

### FPS-Camera distance
GPU_MESH_TESSELATED_FPSY_DISTANCEX = {
    "FPS" : [270,230,170,170,175],
    "DISTANCE":[24,17,10,5,1]

}
### FPS - Tesselation factor


GPU_MESH_RESOLUTION_FPSY_ITERATION = {

    "FPS" : [320,280,270,220,180],
    "ITERATION": [10,30,60,80,100]
} 




CURRENT_PLOT_ = GPU_MESH_RESOLUTION_FPSY_ITERATION
CURRENT_TITLE_= CPU_MESH_ITERATION_FIXED_FPSY_MESH_RESOLUTIONX_TITLE

CURRENT_PLOT_2 = CPU_MESH_MESH_RESOLUTION_FIXED_FPSY_ITERATIONX

KEY1= list(CURRENT_PLOT_.keys())[1]
KEY2 = list(CURRENT_PLOT_.keys())[0]

KEY3 = list(CURRENT_PLOT_2.keys())[1]
KEY4 = list(CURRENT_PLOT_2.keys())[0]
# Create a line chart
plt.plot(CURRENT_PLOT_[KEY1], CURRENT_PLOT_[KEY2], marker='o', linestyle='-', color='b',label = 'GPU Generated')
plt.plot(CURRENT_PLOT_2[KEY3], CURRENT_PLOT_2[KEY4], marker='s', linestyle='--', color='r',label = 'CPU Generate')

# Add titles and labels
plt.title(CURRENT_TITLE_)
plt.xlabel(KEY1)
plt.ylabel(KEY2)


plt.legend()
#plt.text(200, 175, f'Iteration: {100}', fontsize=12, ha='right')
# Show the chart
plt.show()
