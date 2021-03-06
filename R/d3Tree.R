#' Creates a D3 JavaScript Reingold-Tilford Tree network graph.
#'
#'
#' @param List a hierarchical list object with a root node and children.

#' @param height numeric height for the network graph's frame area in pixels.
#' @param width numeric width for the network graph's frame area in pixels.
#' @param fontsize numeric font size in pixels for the node text labels.
#' @param linkColour character string specifying the colour you want the link lines to be. Multiple formats supported (e.g. hexadecimal).
#' @param nodeColour character string specifying the colour you want the node circles to be. Multiple formats supported (e.g. hexadecimal).
#' @param textColour character string specifying the colour you want the text to be before they are clicked. Multiple formats supported (e.g. hexadecimal).
#' @param opacity numeric value of the proportion opaque you would like the graph elements to be.
#' @param diameter numeric diameter for the network in pixels.
#' @param zoom logical, whether or not to enable the ability to use the mouse scroll-wheel to zoom in and out of the graph.
#' @param standAlone logical, whether or not to return a complete HTML document (with head and foot) or just the script.
#' @param file a character string of the file name to save the resulting graph. If a file name is given a standalone webpage is created, i.e. with a header and footer. If \code{file = NULL} then result is returned to the console. 
#' @param iframe logical. If \code{iframe = TRUE} then the graph is saved to an external file in the working directory and an HTML \code{iframe} linking to the file is printed to the console. This is useful if you are using Slidify and many other HTML slideshow framworks and want to include the graph in the resulting page. If you set the knitr code chunk \code{results='asis'} then the graph will be rendered in the output. Usually, you can use \code{iframe = FALSE} if you are creating simple knitr Markdown or HTML pages. Note: you do not need to specify the file name if \code{iframe = TRUE}, however if you do, do not include the file path.
#' @param d3Script a character string that allows you to specify the location of the d3.js script you would like to use. The default is \url{http://d3js.org/d3.v3.min.js}.
#'
#' 
#' @examples
#' ## Create tree from R list
#' # Create hierarchical list
#' CanadaPC <- list(name = "Canada", children = list(list(name = "Newfoundland",
#'                     children = list(list(name = "St. John's"))),
#'                list(name = "PEI",
#'                     children = list(list(name = "Charlottetown"))),
#'                list(name = "Nova Scotia",
#'                     children = list(list(name = "Halifax"))),
#'                list(name = "New Brunswick",
#'                     children = list(list(name = "Fredericton"))),
#'                list(name = "Quebec",
#'                     children = list(list(name = "Montreal"),
#'                                     list(name = "Quebec City"))),
#'                list(name = "Ontario", 
#'                     children = list(list(name = "Toronto"), 
#'                                     list(name = "Ottawa"))),
#'                list(name = "Manitoba",
#'                     children = list(list(name = "Winnipeg"))),
#'                list(name = "Saskatchewan",
#'                     children = list(list(name = "Regina"))),
#'                list(name = "Nunavuet",
#'                     children = list(list(name = "Iqaluit"))),
#'                list(name = "NWT",
#'                     children = list(list(name = "Yellowknife"))),
#'                list(name = "Alberta",
#'                     children = list(list(name = "Edmonton"))),
#'                list(name = "British Columbia",
#'                     children = list(list(name = "Victoria"),
#'                                     list(name = "Vancouver"))),
#'                list(name = "Yukon",
#'                     children = list(list(name = "Whitehorse")))
#' ))
#' 
#' # Create tree
#' d3Tree(List = CanadaPC, fontsize = 10, diameter = 500)
#' 
#' ## Create tree from JSON formatted data
#' ## dontrun
#' ## Download JSON data
#' # library(RCurl)
#' # URL <- "https://raw.github.com/christophergandrud/d3Network/master/JSONdata/flare.json"
#' # Flare <- getURL(URL)
#' 
#' ## Convert to list format
#' # Flare <- rjson::fromJSON(Flare)
#' 
#' ## Recreate Bostock example from http://bl.ocks.org/mbostock/4063550
#' # d3Tree(List = Flare, file = "Flare.html", 
#' #        fontsize = 10, opacity = 0.9, diameter = 1000)
#' 
#' @source Reingold. E. M., and Tilford, J. S. (1981). Tidier Drawings of Trees. IEEE Transactions on Software Engineering, SE-7(2), 223-228.
#' 
#' Mike Bostock \url{http://bl.ocks.org/mbostock/4063550}.
#' 
#' @importFrom whisker whisker.render
#' @importFrom rjson toJSON
#' @export
#' 
d3Tree <- function(List, height = 600, width = 900, fontsize = 10, linkColour = "#ccc", nodeColour = "#3182bd", textColour = "#3182bd", opacity = 0.9, diameter = 980, zoom = FALSE, standAlone = TRUE, file = NULL, iframe = FALSE, d3Script = "http://d3js.org/d3.v3.min.js"){
	if (!isTRUE(standAlone) & isTRUE(iframe)){
		stop("If iframe = TRUE then standAlone must be TRUE.")
	}
	# If no file name is specified create random name to avoid conflicts
	if (is.null(file) & isTRUE(iframe)){
		Random <- paste0(sample(c(0:9, letters, LETTERS), 5, replace=TRUE), collapse = "")
		file <- paste0("NetworkGraph", Random, ".html")
	}

	# Create iframe dimensions larger than graph dimensions
	FrameHeight <- height + height * 0.07
	FrameWidth <- width + width * 0.03

	# Create link opacity at 50% of overall opacity
	linkOpacity <- opacity * 0.5

	# Create mouseover font size
	fontsizeBig <- fontsize * 1.9

	# Convert hierarchical list to JSON
	if (class(List) != "list"){
		stop("List must be a list class object.")
	}
	RootList <- toJSON(List)
	RootList <- paste("var root =", RootList, "; \n")

	# Create webpage head
  	PageHead <- BasicHead()

	# Create Style Sheet
	NetworkCSS <- whisker.render(TreeStyleSheet())

	# Main scripts for creating the graph
	if (!isTRUE(zoom)){
		MainScript1 <- whisker.render(MainRTTree1())
		MainScript2 <- whisker.render(MainRTTree2())
	} 
	else if (isTRUE(zoom)){
		MainScript1 <- whisker.render(ZoomRTTree1())
		MainScript2 <- whisker.render(ZoomRTTree2())		
	}

	if (is.null(file) & !isTRUE(standAlone)){
		cat(NetworkCSS, MainScript1, RootList, 
			MainScript2)
	} 
	else if (is.null(file) & isTRUE(standAlone)){
		cat(PageHead, NetworkCSS, MainScript1, RootList, 
			MainScript2, "</body>")
	} 
	else if (!is.null(file) & !isTRUE(standAlone)){
		cat(NetworkCSS, MainScript1, RootList, 
			MainScript2, file = file)
	}
	else if (!is.null(file) & !isTRUE(iframe)){
		cat(PageHead, NetworkCSS, MainScript1, RootList, 
			MainScript2, "</body>", file = file)
	}
	else if (!is.null(file) & isTRUE(iframe)){
		cat(PageHead, NetworkCSS, MainScript1, RootList, 
			MainScript2, "</body>", file = file)
		cat("<iframe src=\'", file, "\'", " height=", FrameHeight, " width=", FrameWidth, 
		    "></iframe>", sep="")  
	}
}
