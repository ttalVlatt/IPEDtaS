## -----------------------------------------------------------------------------
##
##' [PROJ: IPEDtaS]
##' [FILE: Create hex icon]
##' [INIT: March 25th 2024]
##' [AUTH: Matt Capaldi] @ttalVlatt
##
## -----------------------------------------------------------------------------

library(hexSticker)
library(fontawesome)
library(magick)

cap <- image_read_svg(fa("graduation-cap",
                         fill = "white",
                         ))
data <- image_read_svg(fa("database",
                          fill = "white"))
cap_data <- c(cap, data)
cap_data <- image_append(image_scale(cap_data, "100"), stack = TRUE)

# h/t https://www.youtube.com/watch?v=O34vzdHOaEk
sticker(subplot = cap_data,
        package = "IPEDtaS",
        s_width = 0.85,
        s_height = 0.85,
        s_x = 1,
        s_y = 0.75,
        p_size = 30,
        h_fill = "#FA4616",
        h_color = "#343741",
        url = "capaldi.info/IPEDtaS",
        u_size = 8,
        u_color = "white",
        spotlight = TRUE,
        l_x = 1,
        l_y = 0.8,
        filename = "Icon.png")

## -----------------------------------------------------------------------------
##' *END SCRIPT*
## -----------------------------------------------------------------------------
