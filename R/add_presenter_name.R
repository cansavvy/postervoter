
#' Add presenter name to qr_code
#' @description This returns a random jumble of letters and numbers that are used as poster ids
#' @param presenter_name The name of the presenter you'd like to add to the qr code
#' @param png a file path to a png you'd like to add a label to
#' @returns A png with a name label on the top
#' @import ggplot2
#' @export
#'
add_presenter_name <- function(presenter_name, png) {

image <- png::readPNG(png)

df <- data.frame(presenter_name = presenter_name, x = 0, y = 1)


ggplot2::ggplot(df) +
  ggplot2::annotation_raster(image, xmin = 0, xmax = 1, ymin = 0, ymax = 1) +
  ggplot2::labs(title = "VOTE HERE",
                subtitle = presenter_name) +
  ggplot2::theme(plot.title = ggplot2::element_text(color = "red", hjust = 0.5, size = rel(5), face = "bold"), 
                 plot.subtitle = ggplot2::element_text(hjust = 0.5, size = rel(3)))

ggplot2::ggsave(png)

}
