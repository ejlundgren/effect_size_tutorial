#
#
# Create a silly hex
#
#
library("hexSticker")

file.exists("figures/illustration_icons/doggo.png")
file.exists("figures/flowcharts_diagrams/temp_logo.png")

imgurl <- system.file("figures/illustration_icons/doggo.png")
sticker("figures/illustration_icons/doggo.png", 
        h_fill = "magenta1",
        package="Effect This!", p_size=18, s_x=1, s_y=.75, s_width=.5,
        filename="figures/flowcharts_diagrams/temp_logo.png")

