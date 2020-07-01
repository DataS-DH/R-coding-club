#install.packages('hexSticker')
library(hexSticker)

#set path to image, could be a url
imgpath <- "docs/coffee_pipe_steam.png"
sticker(subplot = imgpath
        , s_x = 1.05
        , s_y = 1.05
        , s_width = 0.7 #leave s_height blank to maintain aspect ratio
        , package = " " #leave blank, or separate words with 6 spaces to accommodate steam ()
        , p_x = 0.975                     
        , p_y = 1.385
        , p_color = "#222222" #package (title) text colour
        , p_family = "Aller_Rg"
        , p_size = 5
        , h_size = 1.2
        , h_fill = "#00ad93" #hex background colour
        , h_color = "#006652" #hex edge colour
        # , spotlight = TRUE
        # , l_x = 1
        # , l_y = 0.8
        # , l_width = 3
        # , l_alpha = 0.3
        , url = "DHSC Coffee & Coding"
        , u_x = 1
        , u_y = 0.08
        , u_color = "#006652" #url text colour
        , u_family = "Aller_Rg"
        , u_size = 4
        , filename = "docs/c&c_dhsc_hex_symbol.png")
